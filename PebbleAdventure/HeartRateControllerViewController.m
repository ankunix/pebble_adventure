//
//  HeartRateControllerViewController.m
//  PebbleAdventure
//
//  Created by Darran Hall on 3/27/16.
//
//

#import "HeartRateControllerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Filter.h"
#import "PulseDetector.h"
#import <Pulse2SDK/HMNPulse2API.h>

typedef NS_ENUM(NSUInteger, CURRENT_STATE) {
    STATE_PAUSED,
    STATE_SAMPLING
};

@interface HeartRateControllerViewController ()
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *camera;
@property(nonatomic, strong) Filter *filter;
@property(nonatomic, assign) CURRENT_STATE currentState;
@property(nonatomic, assign) int validFrameCounter;
@property(nonatomic, strong) PulseDetector *pulseDetector;
@property(nonatomic) float pulseRateSaved;
@property (assign) SystemSoundID beatSound;
@property (nonatomic) int checkSpot;
@property (nonatomic, weak) NSTimer *updateTimer;

@end

@implementation HeartRateControllerViewController
#define MIN_FRAMES_FOR_FILTER_TO_SETTLE 10

- (void)viewDidLoad {
    [super viewDidLoad];
    self.checkSpot = 0;
    
    [self initPulse];
    self.filter = [[Filter alloc] init];
    self.pulseDetector = [[PulseDetector alloc] init];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    
    [self captureHeartRate];
    
}

-(void)timerEngage {
    
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:[self heartRateTimer] target:self selector:@selector(animateLights) userInfo:nil repeats:YES];
    NSLog(@"%f", [self heartRateTimer]);
    
    [aTimer fire];
    
}


-(void)viewWillDisappear:(BOOL)animated {
    
    [self pause];
    [self.session stopRunning];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(float)heartRateTimer{
    
    return 60/self.pulseRateSaved;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // if we're paused don't do anything
    if(self.currentState==STATE_PAUSED) {
        // reset our frame counter
        self.validFrameCounter=0;
        return;
    }
    // this is the image buffer
    CVImageBufferRef cvimgRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the image buffer
    CVPixelBufferLockBaseAddress(cvimgRef,0);
    // access the data
    size_t width=CVPixelBufferGetWidth(cvimgRef);
    size_t height=CVPixelBufferGetHeight(cvimgRef);
    // get the raw image bytes
    uint8_t *buf=(uint8_t *) CVPixelBufferGetBaseAddress(cvimgRef);
    size_t bprow=CVPixelBufferGetBytesPerRow(cvimgRef);
    // and pull out the average rgb value of the frame
    float r=0,g=0,b=0;
    for(int y=0; y<height; y++) {
        for(int x=0; x<width*4; x+=4) {
            b+=buf[x];
            g+=buf[x+1];
            r+=buf[x+2];
        }
        buf+=bprow;
    }
    r/=255*(float) (width*height);
    g/=255*(float) (width*height);
    b/=255*(float) (width*height);
    // convert from rgb to hsv colourspace
    float h,s,v;
    RGBtoHSV(r, g, b, &h, &s, &v);
    // do a sanity check to see if a finger is placed over the camera
    if(s>0.5 && v>0.5) {
        // increment the valid frame count
        self.validFrameCounter++;
        // filter the hue value - the filter is a simple band pass filter that removes any DC component and any high frequency noise
        float filtered=[self.filter processValue:h];
        // have we collected enough frames for the filter to settle?
        if(self.validFrameCounter > MIN_FRAMES_FOR_FILTER_TO_SETTLE) {
            // add the new value to the pulse detector
            [self.pulseDetector addNewValue:filtered atTime:CACurrentMediaTime()];
        }
    } else {
        self.validFrameCounter = 0;
        // clear the pulse detector - we only really need to do this once, just before we start adding valid samples
        [self.pulseDetector reset];
    }
}

-(void)captureHeartRate {
    
    self.session = [[AVCaptureSession alloc] init];
    
    // Get the default camera device
    self.camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // switch on torch mode - can't detect the pulse without it
    if([self.camera isTorchModeSupported:AVCaptureTorchModeOn]) {
        [self.camera lockForConfiguration:nil];
        self.camera.torchMode=AVCaptureTorchModeOn;
        [self.camera unlockForConfiguration];
    }
    // Create a AVCaptureInput with the camera device
    NSError *error=nil;
    AVCaptureInput* cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.camera error:&error];
    if (cameraInput == nil) {
        NSLog(@"Error to create camera capture:%@",error);
    }
    
    // Set the output
    AVCaptureVideoDataOutput* videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // create a queue to run the capture on
    dispatch_queue_t captureQueue=dispatch_queue_create("captureQueue", NULL);
    
    // setup ourself up as the capture delegate
    [videoOutput setSampleBufferDelegate:self queue:captureQueue];
    
    // configure the pixel format
    videoOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey, nil];
    
    // set the minimum acceptable frame rate to 10 fps
    videoOutput.minFrameDuration=CMTimeMake(1, 10);
    
    // and the size of the frames we want - we'll use the smallest frame size available
    [self.session setSessionPreset:AVCaptureSessionPresetLow];
    
    // Add the input and output
    [self.session addInput:cameraInput];
    [self.session addOutput:videoOutput];
    
    // Start the session
    [self.session startRunning];
    
    // we're now sampling from the camera
    self.currentState=STATE_SAMPLING;
    
    // stop the app from sleeping
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // update our UI on a timer every 0.1 seconds
    if (self.checkSpot == 5) {
        [self.updateTimer invalidate];
        [self performSelector:@selector(timerEngage) withObject:self afterDelay:0];

    } else {
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        
    }
    
}


-(void) pause {
    if(self.currentState==STATE_PAUSED) return;
    
    // switch off the torch
    if([self.camera isTorchModeSupported:AVCaptureTorchModeOn]) {
        [self.camera lockForConfiguration:nil];
        self.camera.torchMode=AVCaptureTorchModeOff;
        [self.camera unlockForConfiguration];
    }
    self.currentState=STATE_PAUSED;
    // let the application go to sleep if the phone is idle
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

-(void) resume {
    if(self.currentState!=STATE_PAUSED) return;
    
    // switch on the torch
    if([self.camera isTorchModeSupported:AVCaptureTorchModeOn]) {
        [self.camera lockForConfiguration:nil];
        self.camera.torchMode=AVCaptureTorchModeOn;
        [self.camera unlockForConfiguration];
    }
    self.currentState=STATE_SAMPLING;
    // stop the app from sleeping
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)playSystemSound {
    AudioServicesPlaySystemSound(self.beatSound);
}

int pulseAt = 6;
bool togglePulse = true; // Get High Initially
-(void)rotatePulse {
    for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 10; c++) {
            [self.randomArray replaceObjectAtIndex:((r*11)+c) withObject:[self.randomArray objectAtIndex:((r*11)+c+1)]];
        }
    }
}

-(void)beatAt:(int)x {
    UInt8 red = 138;
    UInt8 green = 7;
    UInt8 blue = 7;
//    NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
    UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
    for (int r = 1; r < 10; r++) {
        [self.randomArray replaceObjectAtIndex:((11*r)-1) withObject:color1];
    }
    red = 255;
    blue = 255;
    green = 255;
//    NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
    UIColor *color2 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
    [self.randomArray replaceObjectAtIndex:((11*x)-1) withObject:color2];
}

-(void)beatFastAt:(int)x {
    UInt8 red = 138;
    UInt8 green = 7;
    UInt8 blue = 7;
//    NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
    UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
    for (int r = 1; r < 10; r++) {
        [self.randomArray replaceObjectAtIndex:((11*r)-1) withObject:color1];
    }
    red = 255;
    blue = 255;
    green = 255;
//    NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
    UIColor *color2 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
    [self.randomArray replaceObjectAtIndex:((11*x)-1) withObject:color2];
    [self.randomArray replaceObjectAtIndex:((11*(x-1))-1) withObject:color2];
    
}




-(void)initPulse {
    self.randomArray = [[NSMutableArray alloc] init];
    
    for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 11; c++) {
            if (r==pulseAt) {
                UInt8 red = 255;
                UInt8 green = 255;
                UInt8 blue = 255;
//                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
                [self.randomArray addObject:color1];
                
            }
            else{
                UInt8 red = 138;
                UInt8 green = 7;
                UInt8 blue = 7;
//                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
                [self.randomArray addObject:color1];
                
            }
        }
    }
}


-(void)pulseUp {
    if(pulseAt>0){
        [self beatAt:pulseAt--];
//        NSLog(@"get High!");
    }
    else{
        //Can't go higher!
        togglePulse=false;
//        NSLog(@"turn down!");
        pulseAt++;
    }
}

-(void)pulseDown {
    if(pulseAt<=8){
        [self beatAt:++pulseAt];
//        NSLog(@"get High!");
    }
    else{
        //Need to go higher!
        togglePulse=true;
//        NSLog(@"turn up!");
        pulseAt--;
        
    }
}


-(void)pulseUpFast {
    if(pulseAt>=1){
        [self beatFastAt:pulseAt--];
//        NSLog(@"get High!");
        pulseAt--;
    }
    else{
        //Can't go higher!
        togglePulse=false;
//        NSLog(@"turn down!");
        pulseAt++;
        pulseAt++;
        
    }
}

-(void)pulseDownFast {
    if(pulseAt<=9){
        pulseAt++;
        [self beatFastAt:++pulseAt];
//        NSLog(@"get High!");
    }
    else{
        //Need to go higher!
        togglePulse=true;
//        NSLog(@"turn up!");
        pulseAt--;
        pulseAt--;
        
    }
}


int spool = 0;

-(void)heartBeat {
    
    switch(spool){
        case 0:
        [self pulseUp];
        spool++;
        break;
        case 1:
        [self pulseDownFast];
        spool++;
        break;
        case 2:
        [self pulseDown];
        spool++;
        break;
        case 3:
        [self pulseUp];
        spool++;
        break;
        case 4:
        [self pulseUp];
        spool++;
        break;
        case 5:
        [self pulseUp];
        spool++;
        break;
        case 6:
        [self pulseUp];
        spool++;
        break;
        case 7:
        [self pulseDownFast];
        spool++;
        break;
        case 8:
        [self pulseDownFast];
        spool++;
        break;
        case 9:
        [self pulseUp];
        spool++;
        break;
        case 10:
        [self pulseUpFast];
        spool++;
        break;
        case 11:
        [self pulseUp];
        spool++;
        break;
        case 12:
        [self pulseUpFast];
        spool++;
        break;
        case 13:
        [self pulseUp];
        spool++;
        break;
        case 14:
        [self pulseDownFast];
        spool++;
        break;
        case 15:
        [self pulseDown];
        spool++;
        break;
        case 16:
        [self pulseDown];
        spool++;
        break;
        case 17:
        [self pulseDown];
        spool++;
        break;
        case 18:
        spool++;
        break;
        case 19:
        spool++;
        break;
        case 20:
        spool++;
        break;
        case 21:
        spool++;
        break;
        case 22:
        spool++;
        break;
        case 23:
        spool++;
        break;
        default:
        spool=0;
        break;
    }
}


-(void)animateLights {
    
    NSLog(@"fire");
    
    //rotate the array
    [self rotatePulse];
    //    NSLog(@"%d", pulseAt);
    [self heartBeat];
    self.checkSpot = 0;
    [self pause];
    [HMNLedControl setColorImage:self.randomArray];

}

void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v ) {
    float min, max, delta;
    min = MIN( r, MIN(g, b ));
    max = MAX( r, MAX(g, b ));
    *v = max;
    delta = max - min;
    if( max != 0 )
        *s = delta / max;
    else {
        // r = g = b = 0
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;
    else if( g == max )
        *h=2+(b-r)/delta;
    else
        *h=4+(r-g)/delta;
    *h *= 60;
    if( *h < 0 )
        *h += 360;
}

- (void)configureSystemSound {
    // This is the simplest way to play a sound.
    // But note with System Sound services you can only use:
    // File Formats (a.k.a. audio containers or extensions): CAF, AIF, WAV
    // Data Formats (a.k.a. audio encoding): linear PCM (such as LEI16) or IMA4
    // Sounds must be 30 sec or less
    // And only one sound plays at a time!
    NSString *beatPath = [[NSBundle mainBundle] pathForResource:@"heartrate" ofType:@"wav"];
    NSURL *beatUrl = [NSURL fileURLWithPath:beatPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)beatUrl, &_beatSound);
}

-(void) update {
    
    // if we're paused then there's nothing to do
    if(self.currentState==STATE_PAUSED) return;
    
    // get the average period of the pulse rate from the pulse detector
    float avePeriod=[self.pulseDetector getAverage];
    if(avePeriod==INVALID_PULSE_PERIOD) {
        // no value available
        self.pulseRate.text=@"--";
    } else {
        // got a value so show it
        float pulse=60.0/avePeriod;
        self.pulseRateSaved = pulse;
        self.checkSpot++;
        NSLog(@"%i", self.checkSpot);
        self.pulseRate.text=[NSString stringWithFormat:@"%0.0f", pulse];
    }
}

- (IBAction)dismissView:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

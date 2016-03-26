//
//  ViewController.m
//  PebbleAdventure
//
//  Created by Darran Hall on 3/25/16.
//
//

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "Filter.h"
#import "PulseDetector.h"
#import <Pulse2SDK/HMNPulse2API.h>

typedef NS_ENUM(NSUInteger, CURRENT_STATE) {
    STATE_PAUSED,
    STATE_SAMPLING
};

#define MIN_FRAMES_FOR_FILTER_TO_SETTLE 10

@interface ViewController () <UITextFieldDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *camera;
@property (nonatomic, strong) UITapGestureRecognizer *recognizer;
@property (nonatomic, strong) NSMutableArray *array;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property(nonatomic, strong) PulseDetector *pulseDetector;
@property(nonatomic, strong) Filter *filter;
@property(nonatomic, assign) CURRENT_STATE currentState;
@property(nonatomic, assign) int validFrameCounter;
@property (nonatomic, strong) HMNLedControl *ledControl;

@property(nonatomic, strong) IBOutlet UILabel *pulseRate;
@end

@implementation ViewController

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [HMNDeviceGeneral connectToMasterDevice];
    [HMNLedControl setLedBrightness:45];
    [self setNeedsStatusBarAppearanceUpdate];

    //self.filter = [[Filter alloc] init];
    self.navigationController.navigationBarHidden = YES;
    //self.pulseDetector = [[PulseDetector alloc] init];
    [super viewDidLoad];
    self.iconImage.center = self.view.center;
    [self performSelector:@selector(animateAll) withObject:self];
    
    self.array = [[NSMutableArray alloc] init];
    self.passwordField.delegate = self;
    self.usernameField.delegate = self;
    self.recognizer = [[UITapGestureRecognizer alloc] init];
    self.recognizer.numberOfTapsRequired = 1;
    [self.recognizer addTarget:self action:@selector(dismissKeyboardView)];
    [self.view addGestureRecognizer:self.recognizer];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)animateAll {
    
    [UIView animateWithDuration:1.f animations:^{
        
        self.iconImage.center = CGPointMake(self.view.center.x, self.view.frame.origin.y + 58 + self.iconImage.frame.size.height/2);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.f animations:^{
            
            self.mainView.alpha = 1;

        }];
    }];
    
}

-(void)dismissKeyboardView {
    
    [self.passwordField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)startCapture:(id)sender {
    
    if (self.currentState == STATE_SAMPLING) {
        
        [self pause];
        
    } else {
        
        [self captureHeartRate];

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
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(update) userInfo:nil repeats:YES];

}


-(void)timerFired:(NSNotification*)not {
    
    [self.session stopRunning];
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    [mutableIndexSet addIndexesInRange:NSMakeRange(0, 60)];
    [self.array removeObjectsAtIndexes:mutableIndexSet];
    [[NSUserDefaults standardUserDefaults] setObject:self.array forKey:@"arrayOfKeys"];
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"arrayOfKeys"]);
    UIViewController *controller =[self.storyboard instantiateViewControllerWithIdentifier:@"Graph"];
    [self presentViewController:controller animated:YES completion:nil];
    
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


-(void) update {
        
    // if we're paused then there's nothing to do
    if(self.currentState==STATE_PAUSED) return;
    
    // get the average period of the pulse rate from the pulse detector
    float avePeriod=[self.pulseDetector getAverage];
    if(avePeriod==INVALID_PULSE_PERIOD) {
        // no value available
        self.heartRateLabel.text=@"--";
    } else {
        // got a value so show it
        float pulse=60.0/avePeriod;
        self.heartRateLabel.text=[NSString stringWithFormat:@"%0.0f", pulse];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

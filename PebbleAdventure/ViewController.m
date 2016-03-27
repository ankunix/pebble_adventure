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

@interface ViewController () <UITextFieldDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *camera;
@property (nonatomic, strong) UITapGestureRecognizer *recognizer;
@property (nonatomic, strong) NSMutableArray *array;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property(nonatomic, strong) PulseDetector *pulseDetector;
@property(nonatomic, strong) Filter *filter;
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

    self.filter = [[Filter alloc] init];
    self.navigationController.navigationBarHidden = YES;
    self.pulseDetector = [[PulseDetector alloc] init];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

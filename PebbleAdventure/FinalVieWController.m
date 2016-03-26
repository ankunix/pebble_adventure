//
//  FinalVieWController.m
//  PebbleAdventure
//
//  Created by Darran Hall on 3/26/16.
//
//

#import "FinalVieWController.h"
#import <Pulse2SDK/HMNPulse2API.h>
#import <AudioToolbox/AudioServices.h>

@interface FinalVieWController ()
@property int firstSwitch;
@property (assign) SystemSoundID beatSound;
@property (nonatomic) int lineCount;

@end

@implementation FinalVieWController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSystemSound];
    _firstSwitch = 0;
    self.lineCount = 0;
    // Do any additional setup after loading the view.
}

-(void)rotateLine:(int)l {
    self.randomArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 11; j++) {
            if (j % l == 0) {
                UInt8 red = 255;
                UInt8 green = 255;
                UInt8 blue = 255;
                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
                [self.randomArray addObject:color1];
            } else {
                UInt8 red = 255;
                UInt8 green = 0;
                UInt8 blue = 0;
                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
                [self.randomArray addObject:color1];
                
                
            }
        }
    }

    
}


- (IBAction)presentAlertThenPush:(id)sender {
    
     self.randomArray = [[NSMutableArray alloc] init];

    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 11; j++) {
            NSLog(@"%ul", j);
            if (j % 11 == 0) {
                UInt8 red = 255;
                UInt8 green = 255;
                UInt8 blue = 255;
                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
                [self.randomArray addObject:color1];
            } else {
                UInt8 red = 255;
                UInt8 green = 0;
                UInt8 blue = 0;
                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
                [self.randomArray addObject:color1];
                        
                        
            }
        }
    }
    
//    self.colorArray = [[NSMutableArray alloc] init];
//
//    for (int i = 0; i < 9; i++) {
//        for (int j = 0; j < 11; j++) {
//            if (i % 9 <= 2) {
//                UInt8 red = 255;
//                UInt8 green = 255;
//                UInt8 blue = 255;
//                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
//                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
//                [self.colorArray addObject:color1];
//            } else if (i % 9 <= 5) {
//                UInt8 red = 255;
//                UInt8 green = 255;
//                UInt8 blue = 255;
//                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
//                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
//                [self.colorArray addObject:color1];
//                
//            } else {
//                UInt8 red = 255;
//                UInt8 green = 0;
//                UInt8 blue = 0;
//                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
//                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
//                [self.colorArray addObject:color1];
//                
//                
//            }
//        }
//    }
//    self.colorArray1 = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < 9; i++) {
//        for (int j = 0; j < 11; j++) {
//            if (i % 9 <= 2) {
//                UInt8 red = 255;
//                UInt8 green = 255;
//                UInt8 blue = 255;
//                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
//                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
//                [self.colorArray1 addObject:color1];
//            } else if (i % 9 <= 5) {
//                UInt8 red = 255;
//                UInt8 green = 0;
//                UInt8 blue = 0;
//                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
//                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
//                [self.colorArray1 addObject:color1];
//                
//            } else {
//                UInt8 red = 255;
//                UInt8 green = 255;
//                UInt8 blue = 255;
//                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
//                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
//                [self.colorArray1 addObject:color1];
//                
//                
//            }
//        }
//    }
//    self.colorArray2 = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < 9; i++) {
//        for (int j = 0; j < 11; j++) {
//            if (i % 9 <= 2) {
//                UInt8 red = 255;
//                UInt8 green = 0;
//                UInt8 blue = 0;
//                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
//                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
//                [self.colorArray2 addObject:color1];
//            } else if (i % 9 <= 5) {
//                UInt8 red = 255;
//                UInt8 green = 255;
//                UInt8 blue = 255;
//                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
//                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
//                [self.colorArray2 addObject:color1];
//                
//            } else {
//                UInt8 red = 255;
//                UInt8 green = 255;
//                UInt8 blue = 255;
//                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
//                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
//                [self.colorArray2 addObject:color1];
//                
//                
//            }
//        }
//    }
//    
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animateLights) userInfo:nil repeats:YES];
    [aTimer fire];
    

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Congratulations!" message:@"You signed up for Baton. How painless, huh?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Awesome!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)playSystemSound {
    AudioServicesPlaySystemSound(self.beatSound);
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

-(void)animateLights {
    NSLog(@"fire");
    [self playSystemSound];
    
//    if (self.lineCount > 11) {
//        
//        self.lineCount = 0;
//        
//        
//    }
    
//    [self rotateLine:self.lineCount];
    [HMNLedControl setColorImage:self.randomArray];
//    self.lineCount++;

    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

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
    _firstSwitch = 0;
    self.lineCount = 0;
    
    // Do any additional setup after loading the view.
}





- (IBAction)presentAlertThenPush:(id)sender {
    
//    
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
    
//    [self initPulse];
//    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:.06 target:self selector:@selector(animateLights) userInfo:nil repeats:YES];
//    [aTimer fire];
    

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Congratulations!" message:@"You signed up for Baton. How painless, huh?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Awesome!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"loggedIn"];
        
        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Profile"] animated:YES completion:nil];

    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}


//
//-(void)animateLights {
//    [self playSystemSound];
//
//    if (self.firstSwitch == 0) {
//        [HMNLedControl setColorImage:self.colorArray];
//
//        _firstSwitch++;
//    } else if (self.firstSwitch == 1) {
//        [HMNLedControl setColorImage:self.colorArray1];
//        _firstSwitch++;
//        
//    } else if (self.firstSwitch == 2) {
//        [HMNLedControl setColorImage:self.colorArray2];
//        _firstSwitch = 0;
//    }
//    
//}

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

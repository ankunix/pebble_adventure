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
    NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
    UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
    for (int r = 1; r < 10; r++) {
        [self.randomArray replaceObjectAtIndex:((11*r)-1) withObject:color1];
    }
    red = 255;
    blue = 255;
    green = 255;
    NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
    UIColor *color2 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
    [self.randomArray replaceObjectAtIndex:((11*x)-1) withObject:color2];
}

-(void)beatFastAt:(int)x {
    UInt8 red = 138;
    UInt8 green = 7;
    UInt8 blue = 7;
    NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
    UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
    for (int r = 1; r < 10; r++) {
        [self.randomArray replaceObjectAtIndex:((11*r)-1) withObject:color1];
    }
    red = 255;
    blue = 255;
    green = 255;
    NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
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
                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
                [self.randomArray addObject:color1];
                
            }
            else{
                UInt8 red = 138;
                UInt8 green = 7;
                UInt8 blue = 7;
                NSLog(@"%hhu, %hhu, %hhu", red, green, blue);
                UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
                [self.randomArray addObject:color1];
                
            }
            }
        }
    }


-(void)pulseUp {
    if(pulseAt>0){
        [self beatAt:pulseAt--];
        NSLog(@"get High!");
    }
    else{
        //Can't go higher!
        togglePulse=false;
        NSLog(@"turn down!");
        pulseAt++;
    }
}

-(void)pulseDown {
    if(pulseAt<=8){
        [self beatAt:++pulseAt];
        NSLog(@"get High!");
    }
    else{
        //Need to go higher!
        togglePulse=true;
        NSLog(@"turn up!");
        pulseAt--;
        
    }
}


-(void)pulseUpFast {
    if(pulseAt>=1){
        [self beatFastAt:pulseAt--];
        NSLog(@"get High!");
        pulseAt--;
    }
    else{
        //Can't go higher!
        togglePulse=false;
        NSLog(@"turn down!");
        pulseAt++;
        pulseAt++;
        
    }
}

-(void)pulseDownFast {
    if(pulseAt<=9){
        pulseAt++;
        [self beatFastAt:++pulseAt];
        NSLog(@"get High!");
    }
    else{
        //Need to go higher!
        togglePulse=true;
        NSLog(@"turn up!");
        pulseAt--;
        pulseAt--;
        
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
    
    [self initPulse];
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:.06 target:self selector:@selector(animateLights) userInfo:nil repeats:YES];
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
            [self playSystemSound];

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
    NSLog(@"%d", pulseAt);
    [self heartBeat];
    [HMNLedControl setColorImage:self.randomArray];
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

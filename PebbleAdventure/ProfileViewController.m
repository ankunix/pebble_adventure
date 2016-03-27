//
//  ProfileViewController.m
//  PebbleAdventure
//
//  Created by Darran Hall on 3/27/16.
//
//

#import "ProfileViewController.h"
#import <HealthKit/HealthKit.h>
#import <Pulse2SDK/HMNPulse2API.h>

@interface ProfileViewController ()
@property (strong, nonatomic) HKHealthStore *healthStore;
@property (strong, nonatomic) IBOutlet UIView *heartView;
@property (strong, nonatomic) NSMutableArray *colorArray;
@end

@implementation ProfileViewController


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (NSSet *)dataTypesToWrite {
    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *heartRate = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, heartRate, weightType, nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *steps = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];

    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *biologicalSexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    HKCharacteristicType *distance = [HKObjectType characteristicTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKCharacteristicType *bikingDistance = [HKObjectType characteristicTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
    HKCharacteristicType *stairsClimbed = [HKObjectType characteristicTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];



    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, birthdayType, biologicalSexType, steps, distance, bikingDistance, stairsClimbed, nil];
}

-(void)showHeartRateView {
    
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"HeartRecord"];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
    
}


- (void)viewDidLoad {
    [HMNDeviceGeneral connectToMasterDevice];
    if (!self.colorArray)
        self.colorArray = [NSMutableArray arrayWithCapacity:99];
    
    [self setNeedsStatusBarAppearanceUpdate];
    self.healthStore = [[HKHealthStore alloc] init];
    NSSet *writeDataTypes = [self dataTypesToWrite];
    NSSet *readDataTypes = [self dataTypesToRead];
    NSMutableArray *steps = [NSMutableArray array];
    __block NSNumber *sumOfNums;
    [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
            
            return;
        }
    }];
    [super viewDidLoad];
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHeartRateView)];
    recog.numberOfTapsRequired = 1;
    [self.heartView addGestureRecognizer:recog];
    [self.heartView setUserInteractionEnabled:YES];
    if ([HKHealthStore isHealthDataAvailable]) {
        // add code to use HealthKit here...
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;
    
    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                     fromDate:[NSDate date]];
    anchorComponents.hour = 0;
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create the query
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                           quantitySamplePredicate:nil
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:anchorDate
                                                                                intervalComponents:interval];
    
        query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
        }
        
        NSDate *endDate = [NSDate date];
        NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                 value:-7
                                                toDate:endDate
                                               options:0];
        
        // Plot the daily step counts over the past 7 days
        [results enumerateStatisticsFromDate:startDate
                                      toDate:endDate
                                   withBlock:^(HKStatistics *result, BOOL *stop) {
                                       
                                       HKQuantity *quantity = result.sumQuantity;
                                       NSLog(@"%@", quantity);
                                       if (quantity) {
                                           NSDate *date = result.startDate;
                                           double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                                           NSLog(@"%@: %f", date, value);
                                           [steps addObject:[NSNumber numberWithFloat:value]];
                                           NSLog(@"%@", steps);
                                       }
                                       
                                   }];
            for (int i = 0; i < [steps count] - 1; i++) {
                sumOfNums = @([sumOfNums integerValue] + [[steps objectAtIndex:i] integerValue]);
                
                NSLog(@"steps taken are %ld", [sumOfNums integerValue]);
            }
            self.stepsLabel.text = [NSString stringWithFormat:@"%ld", [sumOfNums integerValue]];


    };

    
    [self.healthStore executeQuery:query];

        
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    
    NSString *binary = @"000000000000012000210001221012210012210122100012212210000112221100000122210000001121100000000100000";
    NSUInteger len = [binary length];
    unichar buffer[len+1];
    
    [binary getCharacters:buffer range:NSMakeRange(0, len)];
    
    NSLog(@"getCharacters:range: with unichar buffer");
    
    for(int i = 0; i < len; i++) {
        NSLog(@"%C", buffer[i]);
        if (buffer[i] == '0') {
            UInt8 red = 255;
            UInt8 green = 255;
            UInt8 blue = 255;
            UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
            NSLog(@"%@", color1);
            [self.colorArray addObject:color1];
        } else if (buffer[i] == '1') {
            UInt8 red = 255;
            UInt8 green = 128;
            UInt8 blue = 128;
            UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
            NSLog(@"%@", color1);
            [self.colorArray addObject:color1];
        } else if (buffer[i] == '2') {
            UInt8 red = 255;
            UInt8 green = 0;
            UInt8 blue = 0;
            UIColor *color1 = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.f];
            NSLog(@"%@", color1);
            [self.colorArray addObject:color1];
        }

    }
    NSLog(@"%@", self.colorArray);
    [HMNLedControl setColorImage:self.colorArray];

    
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

//
//  GraphViewController.m
//  PebbleAdventure
//
//  Created by Darran Hall on 3/26/16.
//
//

#import "GraphViewController.h"
#import <FSLineChart/FSLineChart.h>

@interface GraphViewController ()
@property (strong, nonatomic) IBOutlet FSLineChart *lineChart;

@end

@implementation GraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayOfKeys"]];
    int beatsCounted;
    NSLog(@"%@ and array count of %lu", array, [array count]);
    NSMutableArray *sorted = [[[[array sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects] mutableCopy];
    NSLog(@"%@ and sorted count of %lu", sorted, [sorted count]);

    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    [mutableIndexSet addIndexesInRange:NSMakeRange(67, 97)];
    [sorted removeObjectsAtIndexes:mutableIndexSet];
    NSLog(@"%lu", (unsigned long)[sorted count]);
    NSLog(@"%lu", (unsigned long)[array count]);
    for (int i=0; i < sorted.count - 1; i++) {
        NSUInteger number = [array indexOfObject:[sorted objectAtIndex:i]];
        NSLog(@"%lu", number);
        NSLog(@"%f, and then %f", [[array objectAtIndex:number] doubleValue], [[array objectAtIndex:[array count] -1] doubleValue]);
        if (number == 0) {
            if ([[array objectAtIndex:number] doubleValue] > [[array objectAtIndex:number+1] doubleValue]) {
                beatsCounted++;
                NSLog(@"object was compared: %@ was greater than %@", [array objectAtIndex:number], [array objectAtIndex:number+1]);
            }

        }
        if (number <= [array count] - 1 && number > 0) {
            if ([[array objectAtIndex:number-1] doubleValue] > [[array objectAtIndex:number] doubleValue]) {
                beatsCounted++;
                NSLog(@"object was compared: %@ was greater than %@", [array objectAtIndex:number-1], [array objectAtIndex:number]);
            }
            
        }
        
    }
    NSLog(@"there are %i valleys", beatsCounted);
    self.bpmLabel.text = [NSString stringWithFormat:@"%i", beatsCounted * 6];
    self.lineChart.verticalGridStep = 9;
    self.lineChart.horizontalGridStep = 11;
    [self.lineChart setChartData:array];
    
    // Do any additional setup after loading the view.
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

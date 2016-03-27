//
//  CALayer+XibConfiguration.m
//  PebbleAdventure
//
//  Created by Darran Hall on 3/27/16.
//
//

#import "CALayer+XibConfiguration.h"

@implementation CALayer(XibConfiguration)

-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}
@end

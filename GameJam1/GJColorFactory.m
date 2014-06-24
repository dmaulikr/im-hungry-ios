//
//  GJColorFactory.m
//  GameJam1
//
//  Created by Gabriel Lumbi on 2014-03-23.
//
//

#import "GJColorFactory.h"

@implementation GJColorFactory

+(UIColor*)sinedGreenColor:(int)t{
    float sin = sinf(t*0.1f);
    float green = sin*sin;
    green /= 4;
    green += 0.4f;
    return [UIColor colorWithRed:0 green:green blue:0 alpha:1.0f];
}

+(UIColor*)rainbowColor:(int)t{
    t+=12;
    return [UIColor colorWithHue:(t%360)/360.0f saturation:1.0f brightness:1.0f alpha:1.0f];
}

@end
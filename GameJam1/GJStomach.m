//
//  GJStomach.m
//  GameJam1
//
//  Created by Gabriel Lumbi on 2014-03-23.
//
//

#import "GJStomach.h"

@interface GJStomach()

@property(nonatomic, retain) SKShapeNode* bar;

@end

@implementation GJStomach

-(id)initWithRect:(CGRect)rect color:(UIColor*)color{
    if(self = [super init]){
        self.bar = [SKShapeNode node];
        self.bar.path = CGPathCreateWithRect(rect, nil);
        self.bar.fillColor = color;
        self.bar.strokeColor = nil;
        [self addChild:self.bar];
    }
    return self;
}

-(void)setColor:(UIColor *)color{
    self.bar.fillColor = color;
}

@end
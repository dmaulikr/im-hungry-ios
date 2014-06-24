//
//  GJVomit.m
//  GameJam1
//
//  Created by Gabriel Lumbi on 2014-06-23.
//
//

#import "GJVomit.h"
#import "CollisionMasks.h"
#import "GameData.h"
#import <math.h>

@implementation GJVomit

-(id)init{
    if(self = [super init]){
        self.name = @"vomit";
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:VOMIT_RADIUS];
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.categoryBitMask = COL_MASK_VOMIT;
        self.physicsBody.contactTestBitMask = 0;
        self.physicsBody.collisionBitMask = 0x00000000;
        
#if DEBUG
        SKShapeNode *frameLine = [[SKShapeNode alloc] init];
        frameLine.path = CGPathCreateWithEllipseInRect(CGRectMake(-VOMIT_RADIUS/2.0f, -VOMIT_RADIUS/2.0f,
                                                                  VOMIT_RADIUS, VOMIT_RADIUS), nil);
        frameLine.strokeColor = [UIColor greenColor];
        frameLine.lineWidth = 0.25f;
        [self addChild:frameLine];
#endif
    }
    return self;
}

-(void)setAngle:(CGFloat)angle{
    [self.physicsBody applyForce:CGVectorMake(8000*cosf(angle), 8000*sinf(angle))];
}

@end

//
//  GJChild.m
//  GameJam1
//
//  Created by Gabriel Lumbi on 2014-05-19.
//
//

#import "GJChild.h"
#import "GameData.h"
#import "CollisionMasks.h"
#import "GJAnimator.h"

@interface GJChild ()

@property(strong) SKTexture* MOUTH_OPEN;
@property(strong) SKTexture* MOUTH_CLOSED;
@property(assign) CGFloat currentStomach;

@end

@implementation GJChild

-(id)initWithId:(uint32_t)identifier{
    if(self = [super initWithImageNamed:[NSString stringWithFormat:TEXT_CHILDREN_MOUTH_CLOSED, identifier]]){
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2.0f];
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.categoryBitMask = COL_MASK_CHILD;
        self.physicsBody.contactTestBitMask = COL_MASK_VOMIT;
        self.physicsBody.collisionBitMask = 0x00000000;
        
        self.MOUTH_OPEN =[SKTexture textureWithImageNamed:[NSString stringWithFormat:TEXT_CHILDREN_MOUTH_OPEN, identifier]];
        self.MOUTH_CLOSED =[SKTexture textureWithImageNamed:[NSString stringWithFormat:TEXT_CHILDREN_MOUTH_CLOSED, identifier]];
        
        self.currentStomach = 0;
    }
    return self;
}

-(BOOL)isFull{
    return self.currentStomach >= 1.0f;
}

-(void)eatPuke{
    if(!self.hidden && !self.isFull){
        self.currentStomach += 0.1f;
        [self removeActionForKey:@"puke"];
        NSArray* actions = @[
                             [SKAction setTexture:self.MOUTH_OPEN],
                             [SKAction waitForDuration:1],
                             [SKAction setTexture:self.MOUTH_CLOSED]
                             ];
        [self runAction:[SKAction sequence:actions]withKey:@"puke"];
        
        if(self.isFull){
            [GJAnimator disapearSlideUp:self];
        }
    }
}

-(void)emptyStomach{
    self.currentStomach = 0;
}

@end

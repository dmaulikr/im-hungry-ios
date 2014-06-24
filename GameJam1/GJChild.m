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
@property(nonatomic, strong) SKEmitterNode* pukeSplashEmitter;
@property(nonatomic,assign) int defaultPukeBirthRate;

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
        
        NSString *pukePath = [[NSBundle mainBundle] pathForResource:@"vomi_splash" ofType:@"sks"];
        
        self.pukeSplashEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:pukePath];
        self.defaultPukeBirthRate = self.pukeSplashEmitter.particleBirthRate;
        self.zPosition = 1;
        self.pukeSplashEmitter.zPosition = 10;
        self.pukeSplashEmitter.particleBirthRate = 0;
        [self addChild:self.pukeSplashEmitter];
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
        
        [self removeActionForKey:@"splash"];
        [self runAction:[SKAction customActionWithDuration:0.5f actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            if(elapsedTime == 0){
                self.pukeSplashEmitter.particleBirthRate = self.defaultPukeBirthRate;
            }else if(elapsedTime >= 0.5f){
                self.pukeSplashEmitter.particleBirthRate = 0;
            }
        }] withKey:@"splash"];
        
        if(self.isFull){
            [GJAnimator disapearSlideUp:self];
        }
    }
}

-(void)emptyStomach{
    self.currentStomach = 0;
}

@end

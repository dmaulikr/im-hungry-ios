//
//  GJFeeder.m
//  GameJam1
//
//  Created by Gabriel Lumbi on 3/2/2014.
//
//

#import <CoreMotion/CoreMotion.h>
#import "GJFeeder.h"
#import "GJFood.h"
#import "CollisionMasks.h"
#import <math.h>

#define TEXT_MOUTH_CLOSED @"packman_closed.png"
#define TEXT_MOUTH_OPEN @"packman_open.png"

@interface GJFeeder()

@property(nonatomic, strong) SKAction* openMouthAction;
@property(nonatomic, strong) SKAction* closeMouthAction;
@property(nonatomic, strong) SKEmitterNode* pukeEmitter;
@property(nonatomic,assign) int defaultPukeBirthRate;

@property(nonatomic, strong) CMMotionManager* motionManager;

@end

@implementation GJFeeder

-(id)init{
    if(self = [super initWithImageNamed:TEXT_MOUTH_CLOSED]){
        self.foodLimit = 5.0f;
        
        self.openMouthAction = [SKAction setTexture:[SKTexture textureWithImageNamed:TEXT_MOUTH_OPEN]];
        self.closeMouthAction = [SKAction setTexture:[SKTexture textureWithImageNamed:TEXT_MOUTH_CLOSED]];
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2.0f];
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.categoryBitMask = COL_MASK_FEEDER;
        self.physicsBody.contactTestBitMask = COL_MASK_FOOD;
        self.physicsBody.collisionBitMask = 0x00000000;
        
        NSString *pukePath = [[NSBundle mainBundle] pathForResource:@"vomi" ofType:@"sks"];
        self.pukeEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:pukePath];
        self.defaultPukeBirthRate = self.pukeEmitter.particleBirthRate;
        self.pukeEmitter.zPosition = -10;
        self.pukeEmitter.particleBirthRate = 0;
        [self addChild:self.pukeEmitter];
        
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.gyroUpdateInterval = 0.1f;
        if(self.motionManager.gyroAvailable){
            [self.motionManager startGyroUpdates];
        }
    }
    return self;
}

-(void)openMouth{
    self.currentState = MOUTH_OPENED;
    [self runAction:self.openMouthAction];

}

-(void)closeMouth{
    self.currentState = MOUTH_CLOSED;
    [self runAction:self.closeMouthAction];

}

-(void)startPuking{
    [self openMouth];
    _isPuking = YES;
     self.pukeEmitter.particleBirthRate = self.defaultPukeBirthRate;
}

-(void)stopPuking{
    [self closeMouth];
    _isPuking = NO;
    self.pukeEmitter.particleBirthRate = 0;
}

-(void)updatePukeAngle:(NSTimeInterval)elapsedTime{
    CMRotationRate rotRate = self.motionManager.gyroData.rotationRate;
    self.pukeEmitter.emissionAngle += rotRate.z * elapsedTime;
    if(self.pukeEmitter.emissionAngle > M_PI - M_PI_4){
        self.pukeEmitter.emissionAngle = M_PI - M_PI_4;
    }else if(self.pukeEmitter.emissionAngle < M_PI_4){
        self.pukeEmitter.emissionAngle = M_PI_4;
    }
}

-(void)eatFood:(GJFood*)food{
    [food runAction:[SKAction sequence:@[
                                         [SKAction customActionWithDuration:0
                                                                actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                                                                    node.physicsBody.velocity = CGVectorMake(0, 0);
                                                                }],
                                         [SKAction scaleTo:0.0f duration:0.5f],
                                         [SKAction removeFromParent]
                                         ]
                     ]];
    
    self.foodAcccumulator += 1.0f;
    
    if(self.foodAcccumulator >= self.foodLimit){
        [self startPuking];
    }
    
    //TODO: do other stuff?
}

@end

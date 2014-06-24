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
#import "GJVomit.h"
#import "CollisionMasks.h"
#import "GameData.h"
#import <math.h>

@interface GJFeeder()

@property(nonatomic, strong) SKAction* openMouthAction;
@property(nonatomic, strong) SKAction* closeMouthAction;
@property(nonatomic, strong) SKEmitterNode* pukeEmitter;
@property(nonatomic,assign) int defaultPukeBirthRate;

@property(nonatomic, assign) NSTimeInterval vomitEmitTimeAccumulator;
@property(nonatomic, assign) NSTimeInterval vomitEmitInterval;
@property(nonatomic, assign) int vomitCount;

@property(nonatomic, strong) CMMotionManager* motionManager;

@end

@implementation GJFeeder

-(id)init{
    if(self = [super initWithImageNamed:TEXT_MOUTH_CLOSED]){
        self.foodLimit = INIT_FOOD_LIMIT;
        
        self.vomitEmitInterval = DEFAULT_VOMIT_EMIT_INTERVAL;
        
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
        self.motionManager.gyroUpdateInterval = GYROSCOPE_INTERVAL_UPDATE;
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

-(void)update:(NSTimeInterval)elapsedTime{
    [self updatePukeAngle:elapsedTime];
    if(self.isPuking){
        self.foodAcccumulator-=FEEDER_FOOD_ACCUMULATOR_DECREASE_RATE*elapsedTime;
        if(self.foodAcccumulator <= 0){
            [self stopPuking];
            self.foodAcccumulator = 0;
        }
    }
}

-(void)updatePukeAngle:(NSTimeInterval)elapsedTime{
    CMRotationRate rotRate = self.motionManager.gyroData.rotationRate;
    self.pukeEmitter.emissionAngle += rotRate.z * elapsedTime;
    if(self.pukeEmitter.emissionAngle > M_PI - M_PI_4){
        self.pukeEmitter.emissionAngle = M_PI - M_PI_4;
    }else if(self.pukeEmitter.emissionAngle < M_PI_4){
        self.pukeEmitter.emissionAngle = M_PI_4;
    }
    self.vomitEmitTimeAccumulator += elapsedTime;
    if(self.vomitEmitTimeAccumulator >= self.vomitEmitInterval){
        self.vomitEmitTimeAccumulator = 0;
        if(_isPuking || true){
            GJVomit* newVomit = [[GJVomit alloc] init];
            newVomit.position = self.position;
            [self.scene addChild:newVomit];
            [newVomit setAngle:self.pukeEmitter.emissionAngle];
            [self cleanVomit];
            self.vomitCount++;
        }
    }
}

-(void)eatFood:(GJFood*)food{
    [food runAction:[SKAction sequence:@[
                                         [SKAction customActionWithDuration:0
                                                                actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                                                                    node.physicsBody.velocity = CGVectorMake(0, 0);
                                                                }],
                                         [SKAction scaleTo:FOOD_EAT_ANIMATION_SCALE_TO
                                                  duration:FOOD_EAT_ANIMATION_SCALE_TO_DURATION],
                                         [SKAction removeFromParent]
                                         ]
                     ]];
    
    self.foodAcccumulator += 1.0f;
    
    if(self.foodAcccumulator >= self.foodLimit){
        [self startPuking];
    }
}

-(void)cleanVomit{
    [self.scene enumerateChildNodesWithName:@"vomit" usingBlock:^(SKNode *node, BOOL *stop) {
        if(!CGRectIntersectsRect(self.scene.frame, node.frame)){
            [node removeFromParent];
            self.vomitCount--;
        }
    }];
}

@end

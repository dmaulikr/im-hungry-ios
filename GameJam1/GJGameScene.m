//
//  GJGameScene.m
//  GameJam1
//
//  Created by Gabriel Lumbi on 3/2/2014.
//
//

#import "GJGameScene.h"
#import "GJFood.h"
#import "GJFeeder.h"
#import "GJFoodFactory.h"
#import "CollisionMasks.h"
#import <stdlib.h>

@interface GJGameScene()

@property(nonatomic, assign) NSTimeInterval startTime;
@property(nonatomic, assign) NSTimeInterval lastTime;
@property(nonatomic, assign) NSTimeInterval elapsedStartTime;
@property(nonatomic, assign) NSTimeInterval lastfoodSpawnTime;

@property(nonatomic, strong) GJFeeder* feeder;
@property(nonatomic, strong) GJFoodFactory* foodFactory;

@property(nonatomic, assign) NSTimeInterval foodSpawnInterval;

@end

@implementation GJGameScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.debugShowNodeFrames = YES;
        
        self.physicsWorld.contactDelegate = self;
        
        self.feeder = [[GJFeeder alloc] init];
        self.feeder.anchorPoint = CGPointMake(0.5f, 0);
        self.feeder.position = CGPointMake(size.width/2.0f, 0);
        [self addChild:self.feeder];
        
        self.foodFactory = [[GJFoodFactory alloc] init];
        self.foodFactory.position = CGPointMake(size.width/2.0f, size.height-60);
        
        self.foodSpawnInterval = 0.5f;
        
        [self addChild:self.foodFactory];
    }
    return self;
}

-(void)update:(NSTimeInterval)currentTime{
    [super update:currentTime];
    
    if(self.startTime == 0){
        self.startTime = currentTime;
        self.lastTime = currentTime;
    }
    
    NSTimeInterval elapsedTime = currentTime - self.lastTime;
    
    self.elapsedStartTime = currentTime - self.startTime;
    
    if(currentTime - self.lastfoodSpawnTime > self.foodSpawnInterval){
        if(self.feeder.foodAcccumulator < self.feeder.foodLimit){
            self.lastfoodSpawnTime = currentTime;
            [self.foodFactory spawnFoodWithCategory:SALTY]; //TODO Change category
        }
    }
    
    [self.feeder updatePukeAngle:elapsedTime];
    
    self.lastTime = currentTime;
}

-(void)didSimulatePhysics{
    [super didSimulatePhysics];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!self.feeder.isPuking){
        [self.feeder openMouth];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(!self.feeder.isPuking){
        [self.feeder closeMouth];
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }else{
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if(firstBody.categoryBitMask & COL_MASK_FEEDER){
        if(secondBody.categoryBitMask & COL_MASK_FOOD){
            
            GJFood* food = (GJFood*)secondBody.node;
            if(self.feeder.currentState == MOUTH_OPENED){
                [self.feeder eatFood:food];
            }else{
                //TODO: load textures from assets
                
                food.zPosition = 10;
                
//                float halfWidth = food.frame.size.width/2.0f;
//                CGRect leftHalf = CGRectMake(0, 0, halfWidth, food.frame.size.height);
//                CGRect rightHalf = CGRectMake(halfWidth, 0, halfWidth, food.frame.size.height);
//                
//                SKTexture* textPartLeft = [SKTexture textureWithRect:leftHalf inTexture:food.texture];
//                SKTexture* textPartRight = [SKTexture textureWithRect:rightHalf inTexture:food.texture];
//                
//                SKSpriteNode* leftPart = [[SKSpriteNode alloc] initWithTexture:textPartLeft];
//                SKSpriteNode* rightPart = [[SKSpriteNode alloc] initWithTexture:textPartRight];
//                
//                leftPart.position = food.position;
//                rightPart.position = food.position;
//                
//                leftPart.name = @"food";
//                rightPart.name = @"food";
//                
//                [self.foodFactory addChild:leftPart];
//                [self.foodFactory addChild:rightPart];
//                [food removeFromParent];
            }
        }
    }
}

@end
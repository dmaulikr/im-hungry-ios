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
#import "GJStomach.h"
#import <stdlib.h>
#import "GameData.h"
#import "GJColorFactory.h"
#import "GJChild.h"
#import "GJAnimator.h"

@interface GJGameScene()

@property(nonatomic, assign) NSTimeInterval startTime;
@property(nonatomic, assign) NSTimeInterval lastTime;
@property(nonatomic, assign) NSTimeInterval elapsedStartTime;

@property(nonatomic, assign) int currentFrame;

@property(nonatomic, strong) GJFeeder* feeder;
@property(nonatomic, strong) GJStomach* feederStomach;
@property(nonatomic, strong) GJFoodFactory* foodFactory;
@property(nonatomic, strong) GJChild* child0;
@property(nonatomic, strong) GJChild* child1;
@property(nonatomic, strong) GJChild* child2;
@property(assign) int lastGameState;
@property(assign) int currentGameState;
@property(assign) int nextGameState;

#define GAME_STATE_EATING 1
#define GAME_STATE_VOMITTING 2

@property(nonatomic, assign) NSTimeInterval lastfoodSpawnTime;
@property(nonatomic, assign) NSTimeInterval foodSpawnInterval;

@end

@implementation GJGameScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.currentGameState = GAME_STATE_EATING;
        self.lastGameState = GAME_STATE_EATING;
        self.nextGameState = GAME_STATE_EATING;
        
        self.debugShowNodeFrames = YES;
        
        self.physicsWorld.contactDelegate = self;
        
        self.feederStomach = [[GJStomach alloc] initWithRect:CGRectMake(0, 0, size.width, size.height)
                                                       color:[UIColor greenColor]];
        self.feederStomach.yScale = 0.0f;
        self.feederStomach.zPosition = -1000;
        
        [self addChild:self.feederStomach];
        
        self.feeder = [[GJFeeder alloc] init];
        self.feeder.anchorPoint = CGPointMake(0.5f, 0);
        self.feeder.position = CGPointMake(size.width/2.0f, 0);
        [self addChild:self.feeder];
        
        CGFloat childZoneWidth = size.width-size.width*0.3f;
        CGFloat childZoneWidthLeftPadding = (size.width-childZoneWidth)/2.0f;
        
        self.child0 = [[GJChild alloc] initWithId:0];
        self.child0.position = CGPointMake(childZoneWidthLeftPadding, size.height-self.child0.size.height/2);
        [self addChild:self.child0];
        self.child1 = [[GJChild alloc] initWithId:0];
        self.child1.position = CGPointMake(size.width/2, size.height-self.child1.size.height/2);
        [self addChild:self.child1];
        self.child2 = [[GJChild alloc] initWithId:0];
        self.child2.position = CGPointMake(size.width-childZoneWidthLeftPadding, size.height-self.child2.size.height/2);
        [self addChild:self.child2];
        
        self.child0.hidden = YES;
        self.child1.hidden = YES;
        self.child2.hidden = YES;
        
        self.foodFactory = [[GJFoodFactory alloc] init];
        self.foodFactory.position = CGPointMake(size.width/2.0f, size.height-60);
        
        self.foodSpawnInterval = INIT_FOOD_SPAWN_INTERVAL;
        
        [self addChild:self.foodFactory];
    }
    return self;
}

-(void)update:(NSTimeInterval)currentTime{
    [super update:currentTime];
    
    self.currentFrame++;
    
    if(self.startTime == 0){
        self.startTime = currentTime;
        self.lastTime = currentTime;
    }
    
    NSTimeInterval elapsedTime = currentTime - self.lastTime;
    
    float targetStocmachScale = self.feeder.foodAcccumulator / self.feeder.foodLimit;
    if(self.feederStomach.yScale != targetStocmachScale && ![self.feederStomach hasActions]){
        float d = STOMACH_BAR_SCALE_ANIMATION_DURATION;
        SKAction* stomachScale = [SKAction sequence:@[[SKAction scaleYTo:targetStocmachScale*1.08f duration:d/3.0f],
                                                      [SKAction scaleYTo:targetStocmachScale*0.95f duration:d/3.0f],
                                                      [SKAction scaleYTo:targetStocmachScale duration:d/3.0f],
                                                      ]];
        [self.feederStomach runAction: stomachScale];
    }
    
    if(self.currentFrame %2 == 0){
        if(!self.feeder.isPuking){
            self.feederStomach.color = [GJColorFactory sinedGreenColor:self.currentFrame];
        }else{
            self.feederStomach.color = [GJColorFactory rainbowColor:12*self.currentFrame];
        }
    }
    
    self.elapsedStartTime = currentTime - self.startTime;
    
    if(currentTime - self.lastfoodSpawnTime > self.foodSpawnInterval){
        if(!self.feeder.isPuking && self.feeder.foodAcccumulator < self.feeder.foodLimit){
            self.lastfoodSpawnTime = currentTime;
            [self.foodFactory spawnFoodWithCategory:SALTY]; //TODO Change category
            self.nextGameState = GAME_STATE_EATING;
        }
    }
    
    [self.feeder update:elapsedTime];
    
    if(self.currentGameState == GAME_STATE_VOMITTING && self.nextGameState == GAME_STATE_EATING){
        [self hideChildren];
    }
    
    self.lastTime = currentTime;
}

-(void)didSimulatePhysics{
    [super didSimulatePhysics];
    
    self.lastGameState = self.currentGameState;
    self.currentGameState = self.nextGameState;
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
                if([self.feeder isPuking]){
                    self.nextGameState = GAME_STATE_VOMITTING;
                    [self showChildren];
                    [self.foodFactory destroyAllFoods];
                }
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
    }else if (firstBody.categoryBitMask & COL_MASK_VOMIT){
        if(secondBody.categoryBitMask * COL_MASK_CHILD){
            GJChild* child = (GJChild*)secondBody.node;
            [child eatPuke];
        }
    }
}

-(void)showChildren{
    [self.child0 emptyStomach];
    [self.child1 emptyStomach];
    [self.child2 emptyStomach];
    [GJAnimator appearBounce:self.child0];
    [GJAnimator appearBounce:self.child1];
    [GJAnimator appearBounce:self.child2];
}

-(void)hideChildren{
    [GJAnimator disapearSlideUp:self.child0];
    [GJAnimator disapearSlideUp:self.child1];
    [GJAnimator disapearSlideUp:self.child2];
}

@end
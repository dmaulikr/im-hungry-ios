//
//  GJFoodFactory.m
//  GameJam1
//
//  Created by Gabriel Lumbi on 3/2/2014.
//
//

#import <UIKit/UIKit.h>
#import "GJFoodFactory.h"
#import "CollisionMasks.h"
#import <stdlib.h>
#import "GameData.h"

@interface GJFoodFactory()
@property(nonatomic, strong) SKAction* foodImpulse;
@property(nonatomic, strong) SKAction* foodSpawn;

@end

@implementation GJFoodFactory

-(id)init{
    if(self = [super init]){
        
        float targetTime = 1.2f;
        float height = [[UIScreen mainScreen] bounds].size.height;
        float targetFoodVelocity = height / targetTime;
        
        self.foodImpulse = [SKAction customActionWithDuration:2 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            node.physicsBody.velocity = CGVectorMake(0, -targetFoodVelocity);
        }];
        self.foodSpawn = [SKAction sequence:@[
                                              [SKAction scaleTo: FOOD_SPAWN_ANIMATION_SCALE_1
                                                       duration:FOOD_SPAWN_ANIMATION_SCALE_1_DURATION],
                                              [SKAction scaleTo: FOOD_SPAWN_ANIMATION_SCALE_1
                                                       duration:FOOD_SPAWN_ANIMATION_SCALE_2_DURATION],
                                              [SKAction scaleTo: 1.0f
                                                       duration:FOOD_SPAWN_ANIMATION_SCALE_RESTORE_DURATION]
                                              ]];
    }
    return self;
}

-(void)spawnFoodWithCategory:(enum GJFoodCategory)cat{
    GJFood* food = [[GJFood alloc] initWithImageNamed:@"apple.png"];
    food.name = @"food";
    food.category = cat;
    food.zPosition = -1;
    food.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:3.0f];
    food.physicsBody.affectedByGravity = NO;
    food.xScale = 0;
    food.yScale = 0;
    food.physicsBody.categoryBitMask = COL_MASK_FOOD;
    food.physicsBody.contactTestBitMask = 0x00000000;
    food.physicsBody.collisionBitMask = 0x00000000;
    [food runAction:[SKAction sequence:@[self.foodSpawn,
                                        self.foodImpulse]
                    ]];
    [self addChild:food];
    
    float randomAngle = 2*((arc4random() % 100)/100.0f - 0.5f);
    
    [food runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:randomAngle duration:1]]];
}

-(void)cleanFoods{
    [self enumerateChildNodesWithName:@"food" usingBlock:^(SKNode *node, BOOL *stop) {
        if(!CGRectIntersectsRect(self.frame, node.frame)){
            [node removeFromParent];
        }
    }];
}

@end

//
//  GJFood.h
//  GameJam1
//
//  Created by Gabriel Lumbi on 3/2/2014.
//
//

#import <SpriteKit/SpriteKit.h>

enum GJFoodCategory{
    SWEET = 0,
    SALTY = 1,
    BITTER = 2,
    INEDIBLE = 3
};

@interface GJFood : SKSpriteNode

@property(nonatomic, assign) enum GJFoodCategory category;

@end
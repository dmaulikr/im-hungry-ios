//
//  GJFoodFactory.h
//  GameJam1
//
//  Created by Gabriel Lumbi on 3/2/2014.
//
//

#import <SpriteKit/SpriteKit.h>
#import "GJFood.h"

@interface GJFoodFactory : SKNode

-(void)spawnFoodWithCategory:(enum GJFoodCategory)cat;

@end
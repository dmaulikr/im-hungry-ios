//
//  GJChild.h
//  GameJam1
//
//  Created by Gabriel Lumbi on 2014-05-19.
//
//

#import <SpriteKit/SpriteKit.h>

@interface GJChild : SKSpriteNode

@property(assign, readonly) BOOL isFull;

-(id)initWithId:(uint32_t)identifier;

-(void)eatPuke;

-(void)emptyStomach;

@end

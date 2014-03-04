//
//  GJFeeder.h
//  GameJam1
//
//  Created by Gabriel Lumbi on 3/2/2014.
//
//

#import <SpriteKit/SpriteKit.h>
#import "GJFood.h"

enum GJFeederState {
    MOUTH_CLOSED = 0,
    MOUTH_OPENED = 1,
    VOMITTING = 2
};

@interface GJFeeder : SKSpriteNode

@property(nonatomic, assign) enum GJFeederState currentState;

-(void)openMouth;
-(void)closeMouth;
-(void)eatFood:(GJFood*)food;
-(void)updatePukeAngle:(NSTimeInterval)elapsedTime;

@end

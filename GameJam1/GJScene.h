//
//  GJScene.h
//  GameJam1
//
//  Created by Gabriel Lumbi on 3/2/2014.
//
//

#import <SpriteKit/SpriteKit.h>

@interface GJScene : SKScene

#ifdef DEBUG
@property(nonatomic, assign) BOOL debugShowGravity;
@property(nonatomic, assign) BOOL debugShowNodeFrames;
#endif

@end

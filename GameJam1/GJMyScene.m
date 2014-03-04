//
//  GJMyScene.m
//  GameJam1
//
//  Created by Gabriel Lumbi on 3/1/2014.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "GJMyScene.h"

@implementation GJMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.debugShowGravity = YES;
        self.debugShowNodeFrames = YES;
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Hello, World!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [self addChild:myLabel];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        sprite.name = @"spaceship";
        sprite.xScale = 0.5f;
        sprite.yScale = 0.5f;
        
        sprite.position = location;
        sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.frame.size.width/2.0f];
        sprite.physicsBody.affectedByGravity = NO;
        
        SKAction *action = [SKAction rotateByAngle:M_PI duration:2];
        
        SKAction *impulse = [SKAction customActionWithDuration:2 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            [node.physicsBody applyImpulse:CGVectorMake(2, 2)];
        }];
        
        [sprite runAction:[SKAction repeatActionForever:action]];
        [sprite runAction:impulse];
        
        [self addChild:sprite];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    [super update:currentTime];
    /* Called before each frame is rendered */
}

-(void)didSimulatePhysics{
    [super didSimulatePhysics];
    [self enumerateChildNodesWithName:@"spaceship" usingBlock:^(SKNode *node, BOOL *stop) {
        if(!CGRectIntersectsRect(self.frame, node.frame)){
            [node removeFromParent];
        }
    }];
}

@end

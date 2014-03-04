//
//  GJScene.m
//  GameJam1
//
//  Created by Gabriel Lumbi on 3/2/2014.
//
//

#import "GJScene.h"

@interface GJScene()
#ifdef DEBUG
@property(nonatomic, strong) SKNode* debugOverlay;
#endif
@end

@implementation GJScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
#ifdef DEBUG
        self.debugOverlay = [SKNode node];
        [self addChild:self.debugOverlay];
#endif
    }
    return self;
}

-(void)update:(NSTimeInterval)currentTime{
#ifdef DEBUG
    [self.debugOverlay removeFromParent];
    [self.debugOverlay removeAllChildren];
#endif
}

-(void)didSimulatePhysics{
#ifdef DEBUG
    [self addChild:self.debugOverlay];
    
    if(self.debugShowGravity){
        [self debugGravity];
    }
    
    if(self.debugShowNodeFrames){
        [self debugNodeFrames];
    }
#endif
}

-(void)debugGravity{
    SKShapeNode *gravityLine = [[SKShapeNode alloc] init];
    gravityLine.position = CGPointMake (200,200);
    
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0.0, 0.0);
    CGPathAddLineToPoint(path, 0, self.physicsWorld.gravity.dx*10, self.physicsWorld.gravity.dy*10);
    CGPathAddLineToPoint(path, 0, self.physicsWorld.gravity.dx*10-5, self.physicsWorld.gravity.dy*10+5);
    CGPathMoveToPoint(path, NULL, self.physicsWorld.gravity.dx*10, self.physicsWorld.gravity.dy*10);
    CGPathAddLineToPoint(path, 0, self.physicsWorld.gravity.dx*10+5, self.physicsWorld.gravity.dy*10+5);
    CGPathCloseSubpath(path);
    gravityLine.path = path;
    CGPathRelease(path);
    gravityLine.strokeColor = [self inverse:self.backgroundColor];
    
    [self.debugOverlay addChild: gravityLine];
}

-(void)debugNodeFrames{
    [self enumerateChildNodesWithName:@"*" usingBlock:^(SKNode *node, BOOL *stop) {
        SKShapeNode *frameLine = [[SKShapeNode alloc] init];
        frameLine.position = CGPointMake (node.frame.origin.x, node.frame.origin.y);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0.0, 0.0);
        CGPathAddLineToPoint(path, 0, node.frame.size.width, 0);
        CGPathAddLineToPoint(path, 0, node.frame.size.width, node.frame.size.height);
        CGPathAddLineToPoint(path, 0, 0, node.frame.size.height);
        CGPathAddLineToPoint(path, 0, 0, 0);
        CGPathCloseSubpath(path);
        frameLine.path = path;
        CGPathRelease(path);

        frameLine.strokeColor = [UIColor redColor];
        frameLine.lineWidth = 0.25f;
        
        [self.debugOverlay addChild:frameLine];
    }];
}

-(UIColor*)inverse:(UIColor*)color{
    const CGFloat *colors = CGColorGetComponents(color.CGColor);
    return [UIColor colorWithRed:1.0f-colors[0] green:1.0f-colors[1] blue:1.0f-colors[2] alpha:1.0f];
}

@end

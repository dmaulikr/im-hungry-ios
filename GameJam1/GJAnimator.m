//
//  GJAnimator.m
//  GameJam1
//
//  Created by Gabriel Lumbi on 2014-06-19.
//
//

#import "GJAnimator.h"

@implementation GJAnimator

+(void)appearBounce:(SKNode*)target{
    [target setScale:0.0f];
    target.hidden = NO;
    [target runAction:
    [SKAction sequence:
                      @[[SKAction scaleTo:1.2f duration:0.1f],
                        [SKAction scaleTo:0.8f duration:0.1f],
                        [SKAction scaleTo:1.1f duration:0.2f],
                        [SKAction scaleTo:0.9f duration:0.2f],
                        [SKAction scaleTo:1.0f duration:0.3f]
                        ]
     ]];
}

+(void)disapearSlideUp:(SKNode*)target{
    [target runAction:[SKAction moveByX:0 y:target.frame.size.height duration:1.0f] completion:^{
        target.hidden = YES;
        [target runAction: [SKAction moveByX:0 y:-target.frame.size.height duration:0]];
    }];
}

@end

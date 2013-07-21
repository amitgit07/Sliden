// CALayer+DTUIKitAdditions.m
// 
// Copyright (c) 2012 David Renoldner <hello@davetrudes.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CALayer+DTUIKitAdditions.h"


@implementation CALayer (DTUIKitAdditions_FlipAnimations)

#pragma mark - Public
- (void)flipToLayer:(CALayer *)toLayer withDirection:(DTCALayerFlipAnimationDirection)direction
{
	[self flipToLayer:toLayer withDirection:direction completion:nil];
}

- (void)flipToLayer:(CALayer *)toLayer withDirection:(DTCALayerFlipAnimationDirection)direction completion:(void (^)())completion
{
	[self flipToLayer:toLayer withDuration:1.0f direction:direction completion:completion];
}



- (void)flipToLayer:(CALayer *)toLayer withDuration:(NSTimeInterval)duration direction:(DTCALayerFlipAnimationDirection)direction completion:(void (^)())completion
{
	[self flipToLayer:toLayer withDuration:duration scaleFactor:1.0f direction:direction completion:completion];
}

- (void)flipToLayer:(CALayer *)toLayer withDuration:(NSTimeInterval)duration scaleFactor:(float)scaleFactor direction:(DTCALayerFlipAnimationDirection)direction completion:(void (^)())completion
{
	CAAnimation *fromAnim = [self flipAnimationWithDirection:direction scaleFactor:scaleFactor duration:duration flipsToBack:YES];
	CAAnimation *toAnim = [self flipAnimationWithDirection:direction scaleFactor:scaleFactor duration:duration flipsToBack:NO];
	
	
	CGFloat zDistance = 1500.0f;
	CATransform3D perspective = CATransform3DIdentity;
	float directionFactor = direction == DTCALayerFlipAnimationDirectionFromLeft ? -1.f : 1.f;
	perspective.m34 = directionFactor / zDistance; //-1(flip left), 1 (flip right)
	self.transform = perspective;
	toLayer.transform = perspective;
	
	[CATransaction begin];
	[CATransaction setCompletionBlock:completion];
	[self addAnimation:fromAnim forKey:@"flip"];
	[toLayer addAnimation:toAnim forKey:@"flip"];
	[CATransaction commit];
}

#pragma mark - Private
- (CAAnimation *)flipAnimationWithDirection:(DTCALayerFlipAnimationDirection)direction scaleFactor:(float)scaleFactor duration:(NSTimeInterval)duration flipsToBack:(BOOL)flipsToBack
{
	//Basic flip animation
	CABasicAnimation *flipAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
	flipAnim.fromValue = [NSNumber numberWithFloat:(flipsToBack ? 0.0f : M_PI)];
    flipAnim.beginTime = 0;
    flipAnim.duration = duration;
	flipAnim.toValue = [NSNumber numberWithFloat:(flipsToBack ? -M_PI : 0.0f)];
    flipAnim.additive = NO;
    flipAnim.fillMode = kCAFillModeForwards; //kCAFillModeBoth;
    flipAnim.removedOnCompletion = NO;
    return flipAnim;
    
}


#pragma mark- 
#pragma mark Flip Using Delay 

#pragma mark - Public
- (void)flipToLayer:(CALayer *)toLayer withDirection:(DTCALayerFlipAnimationDirection)direction afterDelay:(NSTimeInterval)delay
{
	[self flipToLayer:toLayer withDirection:direction afterDelay:delay completion:nil];
}

- (void)flipToLayer:(CALayer *)toLayer withDirection:(DTCALayerFlipAnimationDirection)direction afterDelay:(NSTimeInterval)delay completion:(void (^)())completion
{
	[self flipToLayer:toLayer withDuration:1.0f direction:direction afterDelay:delay completion:completion];
}



- (void)flipToLayer:(CALayer *)toLayer withDuration:(NSTimeInterval)duration direction:(DTCALayerFlipAnimationDirection)direction afterDelay:(NSTimeInterval)delay completion:(void (^)())completion
{
	[self flipToLayer:toLayer withDuration:duration scaleFactor:1.0f direction:direction afterDelay:delay completion:completion];
}

- (void)flipToLayer:(CALayer *)toLayer withDuration:(NSTimeInterval)duration scaleFactor:(float)scaleFactor direction:(DTCALayerFlipAnimationDirection)direction afterDelay:(NSTimeInterval)delay completion:(void (^)())completion
{
	CAAnimation *fromAnim = [self flipAnimationWithDirection:direction scaleFactor:scaleFactor duration:duration afterDelay:delay flipsToBack:YES];
	CAAnimation *toAnim = [self flipAnimationWithDirection:direction scaleFactor:scaleFactor duration:duration afterDelay:delay flipsToBack:NO];
	
	
//	CGFloat zDistance = 1500.0f;
//	CATransform3D perspective = CATransform3DIdentity;
//    float directionFactor = 0.0f;
//    switch (direction) {
//        case DTCALayerFlipAnimationDirectionFromLeft:
//            directionFactor = -1.0f;
//            break;
//        case DTCALayerFlipAnimationDirectionFromRight:
//            directionFactor = 1.0f;
//            break;
//        case DTCALayerFlipAnimationDirectionFromTop:
//            directionFactor = 1.0f;
//            break;
//        case DTCALayerFlipAnimationDirectionFromBottom:
//            directionFactor = -1.0f;
//            break;
//            
//        default:
//            break;
//    }
	//float directionFactor = direction == DTCALayerFlipAnimationDirectionFromLeft ? -1.f : 1.f;
//	perspective.m34 = directionFactor / zDistance; //-1(flip left), 1 (flip right)
//	self.transform = perspective;
//	toLayer.transform = perspective;
	
//	[CATransaction begin];
//	[CATransaction setCompletionBlock:completion];
	[self addAnimation:fromAnim forKey:@"flip"];
	[toLayer addAnimation:toAnim forKey:@"flip"];
//	[CATransaction commit];
}

#pragma mark - Private
- (CAAnimation *)flipAnimationWithDirection:(DTCALayerFlipAnimationDirection)direction scaleFactor:(float)scaleFactor duration:(NSTimeInterval)duration afterDelay:(NSTimeInterval)delay flipsToBack:(BOOL)flipsToBack
{
	//Basic flip animation
	CABasicAnimation *flipAnim = nil;
    switch (direction) {
        case DTCALayerFlipAnimationDirectionFromLeft:
        case DTCALayerFlipAnimationDirectionFromRight:
            flipAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
            break;
        case DTCALayerFlipAnimationDirectionFromTop:
        case DTCALayerFlipAnimationDirectionFromBottom:
            flipAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
            break;
        default:
            break;
    }
    
    flipAnim.fromValue = [NSNumber numberWithFloat:(flipsToBack ? -M_PI : 2*M_PI)];
    flipAnim.toValue = [NSNumber numberWithFloat:(flipsToBack ? -2*M_PI : M_PI)];
    flipAnim.beginTime = delay;
    flipAnim.duration = duration;
    flipAnim.additive = NO;
    flipAnim.fillMode = kCAFillModeForwards; //kCAFillModeBoth;
    flipAnim.removedOnCompletion = NO;
    return flipAnim;
}









@end

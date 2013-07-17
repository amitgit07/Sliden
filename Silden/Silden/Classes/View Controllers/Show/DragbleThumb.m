//
//  DragbleThumb.m
//  Sliden
//
//  Created by Amit Priyadarshi on 27/06/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "DragbleThumb.h"

@implementation DragbleThumb 
@synthesize imageThumb=_imageThumb;
@synthesize isDraggingEnabled=_isDraggingEnabled;
@synthesize delegate=_delegate;
@synthesize thumbIndex=_thumbIndex;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isDraggingEnabled = NO;
        _imageThumb = [[UIImageView alloc] initWithFrame:self.bounds];
        [_imageThumb setContentMode:UIViewContentModeScaleAspectFill];
        [_imageThumb setClipsToBounds:YES];
        [self addSubview:_imageThumb];
        backupFrame = frame;
    }
    return self;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isDraggingEnabled) {
        UITouch *aTouch = [touches anyObject];
        offset = [aTouch locationInView: self.superview];
        if (_delegate && [_delegate respondsToSelector:@selector(dragbleThumb:didBeginFromPosition:)]) {
            [_delegate dragbleThumb:self didBeginFromPosition:offset];
        }
//        if (_delegate && [_delegate respondsToSelector:@selector(dragbleThumb:didStartMovingFromLocation:)]) {
//            [_delegate dragbleThumb:self didStartMovingFromLocation:self.frame];
//        }
//        backupFrame = self.frame;
    }
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isDraggingEnabled) {
        UITouch *aTouch = [touches anyObject];
        CGPoint location = [aTouch locationInView:self.superview];
        if (_delegate && [_delegate respondsToSelector:@selector(dragbleThumb:didMovingToPosition:)]) {
            [_delegate dragbleThumb:self didMovingToPosition:location];
        }
//        [UIView animateWithDuration:0.05 animations:^{
//            self.frame = CGRectMake(location.x-offset.x, location.y-offset.y,
//                                    self.frame.size.width, self.frame.size.height);
//        } completion:^(BOOL finished) {
//            CGRect intersect = CGRectIntersection(self.frame, backupFrame);
//            if (intersect.size.width<(backupFrame.size.width/2) || intersect.size.height<(backupFrame.size.height/2)) {
//                if (_delegate && [_delegate respondsToSelector:@selector(dragbleThumb:didExitFromLocation:)]) {
//                    [_delegate dragbleThumb:self didExitFromLocation:backupFrame];
//                }
//            }
//        }];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.superview];
    if (_delegate && [_delegate respondsToSelector:@selector(dragbleThumb:didEndOnPosition:)]) {
        [_delegate dragbleThumb:self didEndOnPosition:location];
    }
//    CGRect intersect = CGRectIntersection(self.frame, backupFrame);
//    if (intersect.size.width>(backupFrame.size.width/2) && intersect.size.height>(backupFrame.size.height/2)) {
//        if (_delegate && [_delegate respondsToSelector:@selector(didEnddragbleThumb:)]) {
//            [_delegate didEnddragbleThumb:self];
//        }
//        [UIView animateWithDuration:0.05 animations:^{
//            self.frame = backupFrame;
//        }];
//    }
}
#pragma mark - 
- (void)setIsDraggingEnabled:(BOOL)enabled {
    _isDraggingEnabled = enabled;
    if (_isDraggingEnabled) {
        [UIView animateWithDuration:0.05 animations:^{
            self.frame = backupFrame;
        }];
    }
}
#pragma mark -
#pragma mark Draggable animation


- (void)appearDraggable {
    self.layer.opacity = 0.6f;
    [self.layer setValue:[NSNumber numberWithFloat:1.25f] forKeyPath:@"transform.scale"];
}


- (void)appearNormal {
    self.layer.opacity = 1.0f;
    [self.layer setValue:[NSNumber numberWithFloat:1.0f] forKeyPath:@"transform.scale"];
}


#pragma mark -
#pragma mark Wiggle animation


- (void)startWiggling {
    CAAnimation *rotationAnimation = [self wiggleRotationAnimation];
    [self.layer addAnimation:rotationAnimation forKey:@"wiggleRotation"];
    
    CAAnimation *translationYAnimation = [self wiggleTranslationYAnimation];
    [self.layer addAnimation:translationYAnimation forKey:@"wiggleTranslationY"];
}


- (void)stopWiggling {
    [self.layer removeAnimationForKey:@"wiggleRotation"];
    [self.layer removeAnimationForKey:@"wiggleTranslationY"];
}


- (CAAnimation *)wiggleRotationAnimation {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:-0.05f],
                   [NSNumber numberWithFloat:0.05f],
                   nil];
    anim.duration = 0.09f + ((self.thumbIndex % 10) * 0.01f);
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    return anim;
}


- (CAAnimation *)wiggleTranslationYAnimation {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    anim.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:-1.0f],
                   [NSNumber numberWithFloat:1.0f],
                   nil];
    anim.duration = 0.07f + ((self.thumbIndex % 10) * 0.01f);
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    anim.additive = YES;
    return anim;
}

@end

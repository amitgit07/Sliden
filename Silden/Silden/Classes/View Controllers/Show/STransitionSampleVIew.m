//
//  STransitionSampleVIew.m
//  Sliden
//
//  Created by Amit Priyadarshi on 21/07/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "STransitionSampleVIew.h"
#import <QuartzCore/QuartzCore.h>
#import "CALayer+DTUIKitAdditions.h"

#define ANIMATION_TIME 2.0f

@interface STransitionSampleVIew()

@end

@implementation STransitionSampleVIew
@synthesize transionIndex=_transionIndex;
@synthesize isAnimationAdded=_isAnimationAdded;
@synthesize transiton=_transiton;
@synthesize delegate=_delegate;

+ (STransitionSampleVIew*)sampelViewWithTransition:(TransistionType)transitioinType {
    STransitionSampleVIew* view = [[[STransitionSampleVIew alloc] initWithFrame:CGRectMake(0, 0, Default_W, Default_H)] autorelease];
//    [view demonstratedTransition:transitioinType];
    view.clipsToBounds = YES;
    return view;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isAnimationAdded = NO;
        _mainSlector = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mainSlector setImage:Image(@"redFrame.png") forState:UIControlStateNormal];
        [_mainSlector setImage:Image(@"redFrameSelected.png") forState:UIControlStateSelected];
        [_mainSlector setFrame:CGRectMake(17, 8, Image(@"redFrameSelected.png").size.width, Image(@"redFrameSelected.png").size.height)];
        [_mainSlector addTarget:self action:@selector(animationSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_mainSlector];
        
        _transitionName = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-35, self.bounds.size.width, 25)];
        [_transitionName setBackgroundColor:[UIColor clearColor]];
        [_transitionName setFont:[UIFont systemFontOfSize:11]];
        [_transitionName setTextColor:[UIColor blackColor]];
        [_transitionName setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_transitionName];
    }
    return self;
}
- (void)setSelected:(BOOL)selected {
    [_mainSlector setSelected:selected];
}
- (void)demonstratedTransition:(TransistionType)transitioinType {
    if (transitioinType != _transiton) {
        [_firstView removeFromSuperview];
        cRelease(_firstView);
        [_secondView removeFromSuperview];
        cRelease(_secondView);
        [_imageHolder removeFromSuperview];
        cRelease(_imageHolder);
    }
    else {
        if (_isAnimationAdded) {
            return;
        }
    }
    _transiton=transitioinType;
    if (!_imageHolder) {
        UIImageView *bg = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [bg setBackgroundColor:[UIColor clearColor]];
        [bg setImage:[UIImage imageNamed:@"video_bg.png"]];
        [self addSubview:bg];

        _imageHolder = [[UIView alloc] initWithFrame:CGRectMake(22, 15, 132, 123)];
        _imageHolder.clipsToBounds = YES;
        [self addSubview:_imageHolder];
        
        _firstView = [[UIImageView alloc] initWithFrame:_imageHolder.bounds];
        [_firstView setBackgroundColor:[UIColor whiteColor]];
        [_imageHolder addSubview:_firstView];
        [_firstView setImage:Image(@"firstSampel.png")];
        _secondView = [[UIImageView alloc] initWithFrame:_imageHolder.bounds];
        [_secondView setBackgroundColor:[UIColor whiteColor]];
        [_secondView setImage:Image(@"secondSampel.png")];
        [_imageHolder addSubview:_secondView];
        [self bringSubviewToFront:_mainSlector];
        [self bringSubviewToFront:_transitionName];
    }
    CGSize baseSize=_imageHolder.bounds.size;
    _isAnimationAdded = YES;
    [_firstView.layer removeAllAnimations];
    [_secondView.layer removeAllAnimations];
    switch (transitioinType) {
        case kTransitionTypeEnterFromBottom:
        {
            [_firstView setImage:Image(@"firstSampel.png")];
            [_secondView setImage:Image(@"secondSampel.png")];
            _secondView.frame = CGRectMake(0, baseSize.height, baseSize.width, baseSize.height);
            [UIView animateWithDuration:2.0f delay:0.25 options:UIViewAnimationOptionRepeat animations:^{
                _secondView.frame = _imageHolder.bounds;
            } completion:nil];
            _transitionName.text = @"Enter From Bottom";
        }break;
        case kTransitionTypeEnterFromLeft:
        {
            [_firstView setImage:Image(@"firstSampel.png")];
            [_secondView setImage:Image(@"secondSampel.png")];
            _secondView.frame = CGRectMake(-1*baseSize.width, 0, baseSize.width, baseSize.height);
            [UIView animateWithDuration:2.0f delay:0.25 options:UIViewAnimationOptionRepeat animations:^{
                _secondView.frame = _imageHolder.bounds;
            } completion:nil];
            _transitionName.text = @"Enter From Left";
        }break;
        case kTransitionTypeEnterFromRight:
        {
            [_firstView setImage:Image(@"firstSampel.png")];
            [_secondView setImage:Image(@"secondSampel.png")];
            _secondView.frame = CGRectMake(baseSize.width, 0, baseSize.width, baseSize.height);
            [UIView animateWithDuration:2.0f delay:0.25 options:UIViewAnimationOptionRepeat animations:^{
                _secondView.frame = _imageHolder.bounds;
            } completion:nil];
            _transitionName.text = @"Enter From Right";
        }break;
        case kTransitionTypeEnterFromTop:
        {
            [_firstView setImage:Image(@"firstSampel.png")];
            [_secondView setImage:Image(@"secondSampel.png")];
            _secondView.frame = CGRectMake(0, -1*baseSize.height, baseSize.width, baseSize.height);
            [UIView animateWithDuration:2.0f delay:0.25 options:UIViewAnimationOptionRepeat animations:^{
                _secondView.frame = _imageHolder.bounds;
            } completion:nil];
            _transitionName.text = @"Enter From Top";
        }break;
        case kTransitionTypeExitToBottom:
        {
            [_secondView setImage:Image(@"firstSampel.png")];
            [_firstView setImage:Image(@"secondSampel.png")];
            _secondView.frame = CGRectMake(0, 0, baseSize.width, baseSize.height);
            _firstView.frame = CGRectMake(0, 0, baseSize.width, baseSize.height);
            [UIView animateWithDuration:2.0f delay:0.25 options:UIViewAnimationOptionRepeat animations:^{
                _secondView.frame = CGRectMake(0, baseSize.height, baseSize.width, baseSize.height);
            } completion:nil];
            _transitionName.text = @"Exit From Bottom";
        }break;
        case kTransitionTypeExitToLeft:
        {
            [_secondView setImage:Image(@"firstSampel.png")];
            [_firstView setImage:Image(@"secondSampel.png")];
            _secondView.frame = CGRectMake(0, 0, baseSize.width, baseSize.height);
            _firstView.frame = CGRectMake(0, 0, baseSize.width, baseSize.height);
            [UIView animateWithDuration:2.0f delay:0.25 options:UIViewAnimationOptionRepeat animations:^{
                _secondView.frame = CGRectMake(-1*baseSize.width, 0, baseSize.width, baseSize.height);
            } completion:nil];
            _transitionName.text = @"Exit From Left";
        }break;
        case kTransitionTypeExitToRight:
        {
            [_secondView setImage:Image(@"firstSampel.png")];
            [_firstView setImage:Image(@"secondSampel.png")];
            _secondView.frame = CGRectMake(0, 0, baseSize.width, baseSize.height);
            _firstView.frame = CGRectMake(0, 0, baseSize.width, baseSize.height);
            [UIView animateWithDuration:2.0f delay:0.25 options:UIViewAnimationOptionRepeat animations:^{
                _secondView.frame = CGRectMake(baseSize.width, 0, baseSize.width, baseSize.height);
            } completion:nil];
            _transitionName.text = @"Exit From Right";
        }break;
        case kTransitionTypeExitToTop:
        {
            [_secondView setImage:Image(@"firstSampel.png")];
            [_firstView setImage:Image(@"secondSampel.png")];
            _secondView.frame = CGRectMake(0, 0, baseSize.width, baseSize.height);
            _firstView.frame = CGRectMake(0, 0, baseSize.width, baseSize.height);
            [UIView animateWithDuration:2.0f delay:0.25 options:UIViewAnimationOptionRepeat animations:^{
                _secondView.frame = CGRectMake(0, -1*baseSize.height, baseSize.width, baseSize.height);
            } completion:nil];
            _transitionName.text = @"Exit From Top";
        }break;
        case kTransitionTypeFade:
        {
            [_secondView setImage:Image(@"firstSampel.png")];
            [_firstView setImage:Image(@"secondSampel.png")];
            _secondView.frame = CGRectMake(0, 0, baseSize.width, baseSize.height);
            _firstView.frame = CGRectMake(0, 0, baseSize.width, baseSize.height);
            [UIView animateWithDuration:2.0f delay:0.25 options:UIViewAnimationOptionRepeat animations:^{
                _secondView.alpha = 0.0f;
            } completion:nil];
            _transitionName.text = @"Fade";
        }break;
        case kTransitionTypeFlipFromBottom:
        {
            CAAnimation *fromAnim = [self flipAnimationWithDirection:DTCALayerFlipAnimationDirectionFromBottom scaleFactor:0.0f duration:ANIMATION_TIME  afterDelay:0.0f flipsToBack:YES];
            CAAnimation *toAnim = [self flipAnimationWithDirection:DTCALayerFlipAnimationDirectionFromBottom scaleFactor:0.0f duration:ANIMATION_TIME  afterDelay:0.0f flipsToBack:NO];
            [_firstView.layer addAnimation:fromAnim forKey:@"flip"];
            [_secondView.layer addAnimation:toAnim forKey:@"flip"];
            _transitionName.text = @"Flip From Bottom";
        }break;
        case kTransitionTypeFlipFromLeft:
        {
            CAAnimation *fromAnim = [self flipAnimationWithDirection:DTCALayerFlipAnimationDirectionFromLeft scaleFactor:0.0f duration:ANIMATION_TIME  afterDelay:0.0f flipsToBack:YES];
            CAAnimation *toAnim = [self flipAnimationWithDirection:DTCALayerFlipAnimationDirectionFromLeft scaleFactor:0.0f duration:ANIMATION_TIME  afterDelay:0.0f flipsToBack:NO];
            [_firstView.layer addAnimation:fromAnim forKey:@"flip"];
            [_secondView.layer addAnimation:toAnim forKey:@"flip"];
            _transitionName.text = @"Flip From Left";
        }break;
        case kTransitionTypeFlipFromRight:
        {
            CAAnimation *fromAnim = [self flipAnimationWithDirection:DTCALayerFlipAnimationDirectionFromRight scaleFactor:0.0f duration:ANIMATION_TIME  afterDelay:0.0f flipsToBack:YES];
            CAAnimation *toAnim = [self flipAnimationWithDirection:DTCALayerFlipAnimationDirectionFromRight scaleFactor:0.0f duration:ANIMATION_TIME  afterDelay:0.0f flipsToBack:NO];
            [_firstView.layer addAnimation:fromAnim forKey:@"flip"];
            [_secondView.layer addAnimation:toAnim forKey:@"flip"];
            _transitionName.text = @"Flip From Right";
        }break;
        case kTransitionTypeFlipFromTop:
        {
            CAAnimation *fromAnim = [self flipAnimationWithDirection:DTCALayerFlipAnimationDirectionFromTop scaleFactor:0.0f duration:ANIMATION_TIME  afterDelay:0.0f flipsToBack:YES];
            CAAnimation *toAnim = [self flipAnimationWithDirection:DTCALayerFlipAnimationDirectionFromTop scaleFactor:0.0f duration:ANIMATION_TIME  afterDelay:0.0f flipsToBack:NO];
            [_firstView.layer addAnimation:fromAnim forKey:@"flip"];
            [_secondView.layer addAnimation:toAnim forKey:@"flip"];
            _transitionName.text = @"Flip From Top";
        }break;
        default:
            break;
    }
    
}

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
    flipAnim.repeatCount = HUGE_VALF;
    flipAnim.additive = NO;
    flipAnim.fillMode = kCAFillModeForwards; //kCAFillModeBoth;
    flipAnim.removedOnCompletion = NO;
    return flipAnim;
}
- (void)animationSelected:(UIButton*)button {
    [_mainSlector setSelected:!button.selected];
    if (_delegate && [_delegate respondsToSelector:@selector(selectionStateChangedForView:newState:)]) {
        [_delegate selectionStateChangedForView:self newState:_mainSlector.selected];
    }
}
@end

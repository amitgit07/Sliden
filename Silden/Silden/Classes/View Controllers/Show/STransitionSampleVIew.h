//
//  STransitionSampleVIew.h
//  Sliden
//
//  Created by Amit Priyadarshi on 21/07/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    kTransitionTypeFade,
    kTransitionTypeEnterFromLeft,
    kTransitionTypeEnterFromRight,
    kTransitionTypeEnterFromTop,
    kTransitionTypeEnterFromBottom,
    kTransitionTypeExitToLeft,
    kTransitionTypeExitToRight,
    kTransitionTypeExitToTop,
    kTransitionTypeExitToBottom,
    kTransitionTypeFlipFromLeft,
    kTransitionTypeFlipFromRight,
    kTransitionTypeFlipFromTop,
    kTransitionTypeFlipFromBottom,
    kTransitionTypeCurlUp,
    kTransitionTypeCurlDown,
    kTransitionTypeNone
} TransistionType;

#define Default_W 175
#define Default_H 175

@class STransitionSampleVIew;
@protocol STransitionSampleVIewDelegate <NSObject>

- (void)selectionStateChangedForView:(STransitionSampleVIew*)view newState:(BOOL)selected;

@end

@interface STransitionSampleVIew : UIView {
    UIImageView* _firstView;
    UIImageView* _secondView;
    UIView*     _imageHolder;
    UIButton*   _mainSlector;
    UILabel*    _transitionName;
}
@property(nonatomic, assign) int transionIndex;
@property(nonatomic, assign) BOOL isAnimationAdded;
@property(nonatomic, assign) TransistionType transiton;
@property(nonatomic, retain) id<STransitionSampleVIewDelegate> delegate;

+ (STransitionSampleVIew*)sampelViewWithTransition:(TransistionType)transitioinType;
- (void)demonstratedTransition:(TransistionType)transitioinType;
- (void)setSelected:(BOOL)selected;

@end

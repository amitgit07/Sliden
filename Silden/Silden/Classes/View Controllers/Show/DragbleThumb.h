//
//  DragbleThumb.h
//  Sliden
//
//  Created by Amit Priyadarshi on 27/06/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DragbleThumb;
@protocol DragbleThumbDelegate <NSObject>
- (void)dragbleThumb:(DragbleThumb*)thumb didBeginFromPosition:(CGPoint)point;
- (void)dragbleThumb:(DragbleThumb*)thumb didMovingToPosition:(CGPoint)point;
- (void)dragbleThumb:(DragbleThumb*)thumb didEndOnPosition:(CGPoint)point;
//- (void)dragbleThumb:(DragbleThumb*)thumb didExitFromLocation:(CGRect)start;
//- (void)didEnddragbleThumb:(DragbleThumb*)thumb;
@end

@interface DragbleThumb : UIView {
    CGPoint offset;
    CGRect  backupFrame;
}
@property(nonatomic, assign) NSUInteger thumbIndex;
@property(nonatomic, retain) UIImageView* imageThumb;
@property(nonatomic, assign) BOOL isDraggingEnabled;
@property(nonatomic, assign) id<DragbleThumbDelegate> delegate;

- (void)appearDraggable;
- (void)appearNormal;
- (void)startWiggling;
- (void)stopWiggling;
@end

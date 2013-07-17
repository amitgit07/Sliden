//
//  UIView+ResignResponder.m
//  Silden
//
//  Created by Amit Priyadarshi on 06/02/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//


#import "UIView+ResignResponder.h"

@implementation UIView (ResignFirstResponder)

- (BOOL)resignFirstResonder
{
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;     
    }
    switch (self.tag) {
        case OVERLAY_VIEW_TAG:
            [self removeFromSuperview];
            break;
        case OVERLAY_VIEW_TAG_SLIDE: {
            UIView* supV = self.superview;
            [UIView animateWithDuration:0.5f animations:^{
                [self setFrame:CGRectMake(0, supV.frame.size.height, self.frame.size.width, self.frame.size.height)];
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        }break;
        case OVERLAY_VIEW_TAG_BOUNCE:
            [self removeFromSuperview];
            break;
            
        default:
            break;
    }
    
    for (UIView *subView in self.subviews) {
        if ([subView resignFirstResonder])
            return YES;
    }
    return NO;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self resignFirstResonder];
	[super touchesBegan:touches withEvent:event];
}

@end

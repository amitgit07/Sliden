//
//  SUILable.m
//  Silden
//
//  Created by Amit Priyadarshi on 07/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SUILable.h"

@implementation SUILable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)layoutIfNeeded {
    [super layoutIfNeeded];
    self.layer.shadowColor = [[UIColor colorWithWhite:0.95f alpha:0.80f] CGColor];
    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

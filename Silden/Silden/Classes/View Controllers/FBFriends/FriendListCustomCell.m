//
//  FriendListCustomCell.m
//  Silden
//
//  Created by Amit Priyadarshi on 15/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "FriendListCustomCell.h"

@interface FriendListCustomCell()
- (void)didTapOnFollowButton:(UIButton*)button;
- (void)didTapOnCheckbox:(UIButton*)button;
@end

@implementation FriendListCustomCell
@synthesize userThumb=_userThumb;
@synthesize userName=_userName;
@synthesize button=_button;
@synthesize followStatus=_followStatus;
@synthesize checkBox=_checkBox;
@synthesize cellType=_cellType;
@synthesize checkStatus=_checkStatus;
@synthesize delegate=_delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView* bg = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)] autorelease];
        [bg setImage:Image(@"cellBg.png")];
        [self.contentView addSubview:bg];
        
        UIImageView* thumbBg = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 60, 60)] autorelease];
        [thumbBg setImage:Image(@"thumb_placeholde.png")];
        [self.contentView addSubview:thumbBg];
        
        _userThumb = [[UIThumbView alloc] initWithFrame:CGRectMake(15, 10, 47, 47)];
        [_userThumb setDefaultImage:Image(@"default_profile_image.png")];
        [self.contentView addSubview:_userThumb];
        
        _userName = [[UILabel alloc] initWithFrame:CGRectMake(75, 24, 150, 22)];
        [_userName setFont:[UIFont boldSystemFontOfSize:12]];
        [_userName setBackgroundColor:[UIColor clearColor]];
        [_userName setTextColor:[UIColor colorWithRed:FractionIn255(26) green:FractionIn255(106) blue:FractionIn255(166) alpha:1.0f]];
        [self.contentView addSubview:_userName];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setFrame:CGRectMake(235, 19, 78, 32)];
        [_button.titleLabel setFont:[UIFont boldSystemFontOfSize:8]];
        [_button addTarget:self action:@selector(didTapOnFollowButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_button];
        
        _checkBox = [[SharedUtility sharedInstance] getACheckBoxButtonOnLocation:CGPointMake(260, 25)];
        [_checkBox setSelected:NO];
        [_checkBox addTarget:self action:@selector(didTapOnCheckbox:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_checkBox];
    }
    return self;
}
- (void)setCellType:(CellType)type {
    if (type == CellTypeSildenUser) {
        [_checkBox setHidden:YES];
        [_button setHidden:NO];
    }
    else {
        [_checkBox setHidden:NO];
        [_button setHidden:YES];
    }
}
- (void)setFollowStatus:(FollowStatus)status {
    if (status==FollowStatusFollowing) {
        [_button setBackgroundImage:Image(@"blueBtn37.png") forState:UIControlStateNormal];
        [_button setTitle:@"UNFOLLOW" forState:UIControlStateNormal];
    }
    else {
        [_button setBackgroundImage:Image(@"grabutton37.png") forState:UIControlStateNormal];
        [_button setTitle:@"FOLLOW" forState:UIControlStateNormal];
    }

    _followStatus = status;
}
- (void)setCheckStatus:(CheckboxStatus)status {
    if (status == CheckboxStatusSelected) {
        [_checkBox setSelected:YES];
    }
    else {
        [_checkBox setSelected:NO];
    }
    _checkStatus = status;
    
}
#pragma mark - Private Method
- (void)didTapOnFollowButton:(UIButton*)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(friendListCustomCell:didTapFollowButton:)]) {
        [self.delegate friendListCustomCell:self didTapFollowButton:button];
    }
    if (_followStatus==FollowStatusNotFollowing) {
        [self setFollowStatus:FollowStatusFollowing];
    }
    else {
        [self setFollowStatus:FollowStatusNotFollowing];
    }
    
}
- (void)didTapOnCheckbox:(UIButton*)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(friendListCustomCell:didTapOnCheckBox:)]) {
        [self.delegate friendListCustomCell:self didTapOnCheckBox:button];
    }
    if (self.checkStatus == CheckboxStatusSelected) {
        self.checkStatus = CheckboxStatusUnselected;
        [self.checkBox setSelected:NO];
    }
    else {
        self.checkStatus = CheckboxStatusSelected;
        [self.checkBox setSelected:YES];
    }
}
@end

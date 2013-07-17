//
//  FriendListCustomCell.h
//  Silden
//
//  Created by Amit Priyadarshi on 15/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIThumbView.h"

typedef enum {
    FollowStatusUnknown,
    FollowStatusFollowing,
    FollowStatusNotFollowing,
}FollowStatus;

typedef enum {
    CellTypeSildenUser = 1,
    CellTypeFacebookFriends = 2,
}CellType;

@class FriendListCustomCell;

@protocol FriendListCustomCellDelegate <NSObject>
@optional
- (void)friendListCustomCell:(FriendListCustomCell*)cell didTapOnCheckBox:(UIButton*)checkBox;
- (void)friendListCustomCell:(FriendListCustomCell*)cell didTapFollowButton:(UIButton*)button;

@end

@interface FriendListCustomCell : UITableViewCell {
    
}

@property(nonatomic, retain) UIThumbView* userThumb;
@property(nonatomic, retain) UILabel* userName;
@property(nonatomic, assign) UIButton* button;
@property(nonatomic, assign) UIButton* checkBox;
@property(nonatomic, assign) FollowStatus followStatus;
@property(nonatomic, assign) CellType cellType;
@property(nonatomic, assign) CheckboxStatus checkStatus;
@property(nonatomic, assign) id<FriendListCustomCellDelegate> delegate;

@end

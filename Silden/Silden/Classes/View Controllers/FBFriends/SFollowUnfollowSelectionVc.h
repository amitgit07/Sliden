//
//  SFollowUnfollowSelectionVc.h
//  Silden
//
//  Created by Amit Priyadarshi on 09/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendListCustomCell.h"
#import "InviteFacebookFriend.h"

@interface SFollowUnfollowSelectionVc : SGrayViewController <UITableViewDataSource, UITabBarDelegate, FriendListCustomCellDelegate> {
    NSMutableArray* _sildenUsers;
    NSMutableArray* _followingFriends;
    InviteFacebookFriend* facebookFriendsView;
}
@property (retain, nonatomic) IBOutlet UITableView *sildenUsersTableView;
@property (retain, nonatomic) IBOutlet UIButton *sildenUserButton;
@property (retain, nonatomic) IBOutlet UIButton *facebookUserButton;
- (IBAction)skipOrDoneButtonTap:(UIButton *)sender;
- (IBAction)sildenUserButtonTap:(id)sender;
- (IBAction)inviteFbFriendButtonTap:(id)sender;
@end

//
//  InviteFacebookFriend.h
//  Silden
//
//  Created by Amit Priyadarshi on 15/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendListCustomCell.h"

@interface InviteFacebookFriend : UIView <FriendListCustomCellDelegate, UITableViewDelegate, UITableViewDataSource>{
    NSArray* _friendsArray;
    UITableView* friendsTable;
//    NSSet* friendsOnFb;
    NSMutableSet* selectedFriends;
}
@property(nonatomic, retain) NSMutableSet* selectedFriends;
@end

//
//  SUserProfileViewCell.h
//  Sliden
//
//  Created by Amit Priyadarshi on 06/08/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIThumbView.h"

@interface OneUserView : UIView
@property(nonatomic, retain) UIThumbView* userProfilePic;
@property(nonatomic, retain) UILabel*     userProfileName;
- (void)setBadgeNumber:(int)number;
@end


@interface SUserProfileViewCell : UITableViewCell {
    
}
@property(nonatomic, retain) NSMutableArray* usersInOneCell;

- (void)setNumberOfBadgeCount:(int)cout forUser:(OneUserView*)user;
@end

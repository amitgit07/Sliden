//
//  SUserProfileViewCell.m
//  Sliden
//
//  Created by Amit Priyadarshi on 06/08/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SUserProfileViewCell.h"

@implementation OneUserView {
    UIImageView* _badgeBg;
    UILabel* _badgeCountLabel;
}

@synthesize userProfilePic=_userProfilePic;
@synthesize userProfileName=_userProfileName;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView* bg = [[UIImageView alloc] initWithFrame:CGRectMake(4, 0, 72, 85)];
        [bg setImage:Image(@"home_profilePic_bg")];
        [self addSubview:bg];
        sRelease(bg);
        
        _userProfilePic = [[UIThumbView alloc] initWithFrame:CGRectMake(10, 7, 60, 58)];
        [_userProfilePic setImageType:@"Users"];
        [self addSubview:_userProfilePic];
        
        _userProfileName = [[UILabel alloc] initWithFrame:CGRectMake(9, 65, 62, 11)];
        [_userProfileName setFont:[UIFont boldSystemFontOfSize:7]];
        [_userProfileName setTextColor:[UIColor darkGrayColor]];
        [_userProfileName setBackgroundColor:[UIColor clearColor]];
        [_userProfileName setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_userProfileName];
        
        _badgeBg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 3, 64, 18)];
        [_badgeBg setBackgroundColor:[UIColor clearColor]];
        [_badgeBg setImage:StreachImage(@"badge.png", 20, 0)];
        [_badgeBg setHidden:YES];
        [self addSubview:_badgeBg];
        
        _badgeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 6, 12, 11)];
        [_badgeCountLabel setFont:[UIFont boldSystemFontOfSize:8]];
        [_badgeCountLabel setTextColor:[UIColor whiteColor]];
        [_badgeCountLabel setBackgroundColor:[UIColor clearColor]];
        [_badgeCountLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_badgeCountLabel];
    }
return self;
}
- (void)setBadgeNumber:(int)number {
    [_badgeBg setHighlighted:(number<1)];
    [_badgeCountLabel setHighlighted:(number<1)];
    [_badgeCountLabel setText:[NSString stringWithFormat:@"%d",number]];
}
@end

@implementation SUserProfileViewCell
@synthesize usersInOneCell=_usersInOneCell;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _usersInOneCell = [[NSMutableArray alloc] initWithCapacity:4];
        for (int i = 0; i < 4; i++) {
            OneUserView* view = [[[OneUserView alloc] initWithFrame:CGRectMake(80*i, 5, 80, 85)] autorelease];
            [self.contentView addSubview:view];
            [_usersInOneCell addObject:view];
        }
    }
    return self;
}

- (void)setNumberOfBadgeCount:(int)cout forUser:(OneUserView*)user {
    [user setBadgeNumber:cout];
}

@end

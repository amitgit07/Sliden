//
//  SHomeVc.h
//  Silden
//
//  Created by Amit Priyadarshi on 08/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIThumbView.h"
@interface SHomeVc : SGrayViewController <UIImageViewTapDelegate> {
    Byte hideActivityCount;
}
@property (retain, nonatomic) IBOutlet UIImageView *profilePicThumbView;
@property (retain, nonatomic) IBOutlet UILabel *numberOfFollowersLabel;
@property (retain, nonatomic) IBOutlet UILabel *numberOfFollowingLabel;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIButton *followerButton;
@property (retain, nonatomic) IBOutlet UIButton *followingButton;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *followingActivity;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *followersActivity;
- (IBAction)followersButtonTap:(UIButton *)sender;
- (IBAction)followingButtonTaped:(UIButton *)sender;
@end

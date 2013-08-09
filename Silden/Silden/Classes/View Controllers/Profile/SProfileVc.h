//
//  SProfileVc.h
//  Silden
//
//  Created by Amit Priyadarshi on 08/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIThumbView.h"

@interface SProfileVc : SGrayViewController <UIImageViewTapDelegate>

@property (nonatomic, retain) PFUser*  currentUser;
@property (nonatomic, retain) NSMutableArray* following;
@property (nonatomic, retain) NSMutableArray* followers;

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIButton *showsButton;
@property (retain, nonatomic) IBOutlet UIButton *followersButton;
@property (retain, nonatomic) IBOutlet UIButton *followingButton;
@property (retain, nonatomic) IBOutlet UIButton *followButton;
@property (retain, nonatomic) IBOutlet UIImageView *userProfilePicImageView;
@property (retain, nonatomic) IBOutlet UILabel *userTagLine;
@property (retain, nonatomic) IBOutlet UILabel *numberOfShowsLabel;
@property (retain, nonatomic) IBOutlet UILabel *numberOfFollowersLabel;
@property (retain, nonatomic) IBOutlet UILabel *numberOfFollowingLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *showsActivity;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *followersActivity;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *followingActivity;

- (IBAction)followButtonTap:(UIButton *)sender;
- (IBAction)showsButtonTap:(UIButton *)sender;
- (IBAction)followersButtonTap:(UIButton *)sender;
- (IBAction)followingButtonTap:(UIButton *)sender;

- (void)displayProfileForUser:(PFUser*)user;
@end

//
//  SHomeVc.m
//  Silden
//
//  Created by Amit Priyadarshi on 08/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SHomeVc.h"
#import "SUserProfileViewCell.h"
#import "SProfileVc.h"

@interface SHomeVc ()

@end

@implementation SHomeVc {
    NSArray* _usersToDisplay;
    NSMutableArray* _following;
    NSMutableArray* _followers;
    BOOL displayFollowers;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:0];
        [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"home_icon_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"home_icon.png"]];
        displayFollowers = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setProfilePic];
    [_followersActivity startAnimating];
    [_followingActivity startAnimating];
    [_tableView setSeparatorColor:[UIColor clearColor]];
    _following = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    _followers = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [APP_DELEGATE setNavigationBarBackground:YES];
    hideActivityCount = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followersUpdated) name:kFollowersSynced object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followingUpdated) name:kFollowingSynced object:nil];
    _following = [DBS following];
    _followers = [DBS followers];
    [_tableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFollowersSynced object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFollowingSynced object:nil];
}
- (void)dealloc {
    [_profilePicThumbView release];
    [_numberOfFollowersLabel release];
    [_numberOfFollowingLabel release];
    [_tableView release];
    [_followerButton release];
    [_followingButton release];
    [_followingActivity release];
    [_followersActivity release];
    [super dealloc];
}
- (IBAction)followersButtonTap:(UIButton *)sender {
    displayFollowers = YES;
    [sender setSelected:YES];
    [_followingButton setSelected:NO];
    _usersToDisplay = [DBS followers];
    [_tableView reloadData];
}

- (IBAction)followingButtonTaped:(UIButton *)sender {
    displayFollowers = NO;
    [sender setSelected:YES];
    [_followerButton setSelected:NO];
    _usersToDisplay = [DBS following];
    [_tableView reloadData];
}
- (void)viewDidUnload {
    [self setProfilePicThumbView:nil];
    [self setNumberOfFollowersLabel:nil];
    [self setNumberOfFollowingLabel:nil];
    [self setTableView:nil];
    [self setFollowerButton:nil];
    [self setFollowingButton:nil];
    [self setFollowingActivity:nil];
    [self setFollowersActivity:nil];
    [super viewDidUnload];
}


#pragma mark - TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    _usersToDisplay = (displayFollowers)?_followers:_following;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_usersToDisplay count]) {
        unsigned int k = ceil(([_usersToDisplay count])/4.0f);
        return k;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    SUserProfileViewCell* cell = (SUserProfileViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[SUserProfileViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        NSArray* users = cell.usersInOneCell;
        for (OneUserView* view in users) {
            [view.userProfilePic addTapReceiver];
            [view.userProfilePic setTapDelegate:self];
            [view.userProfilePic setContentMode:UIViewContentModeScaleAspectFill];
            [view.userProfilePic.layer setMasksToBounds:YES];
        }
    }
    int tumbsInCurrentCell = ([_usersToDisplay count]/((indexPath.row+1) * 4.0f) >= 1)?4: ([_usersToDisplay count]%4);
    int externalIndex = 0;
    NSArray* users = cell.usersInOneCell;
    for (int i = 0; i < tumbsInCurrentCell; i++) {
        externalIndex = indexPath.row*4 + i;
        OneUserView* view = users[i];
        PFUser* currentUser = [_usersToDisplay objectAtIndex:externalIndex];
        [view.userProfilePic setImageForUser:currentUser];
        [view.userProfilePic setUniqueIdentifire:[NSNumber numberWithInt:externalIndex]];
        [view.userProfileName setText:[currentUser objectForKey:@"name"]];
        [view setHidden:NO];
    }
    for (int i = 4; i > tumbsInCurrentCell; i--) {
        OneUserView* view = users[i-1];
        [view setHidden:YES];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
#pragma mark - 
- (void)didTapOnImageView:(UIThumbView*)clikableImage {
    int index = [clikableImage.uniqueIdentifire intValue];
    PFUser *user = [_usersToDisplay objectAtIndex:index];
    UITabBarController* tbC = [APP_DELEGATE tabBarController];
    [SProfileVc emptyUserStack];
    UINavigationController* nvc = [[tbC viewControllers] objectAtIndex:3];
    [nvc popToRootViewControllerAnimated:NO];
    SProfileVc* profileVc = (SProfileVc*)[[nvc viewControllers] objectAtIndex:0];
    [tbC setSelectedIndex:3];
    [profileVc displayProfileForUser:user];
}
- (void)setProfilePic {
    PFUser* user = [PFUser currentUser];
    PFFile *profilePic = [user objectForKey:kKeyProfilePic];
    NSString* imageUrlStr = [NSString stringWithFormat:@"%@.jpg",[user objectForKey:kKeyUserId]];
    NSString* localPath = [NSString stringWithFormat:@"%@/%@/%@/%@",CACHE_DIR,BaseBufferFolder,
                           NoTypeFolder,
                           [imageUrlStr lastPathComponent]];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:localPath]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage* image = [SCI maskImage:[UIImage imageWithContentsOfFile:localPath] withMask:Image(@"mask_home_center_circle.png")];
            [_profilePicThumbView setImage:image];
        });
    }
    else {
        [profilePic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error) {
                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
                return;
            }
            if ([data length] > 50) {
                NSFileManager* fm = [NSFileManager defaultManager];
                if ([fm fileExistsAtPath:localPath])
                {
                    NSError* err = nil;
                    [fm removeItemAtPath:localPath error:&err];
                    if (err)
                        NSLog(@"%s:%@",__FUNCTION__,err);
                }
                [fm createFileAtPath:localPath contents:data attributes:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage* image = [SCI maskImage:[UIImage imageWithContentsOfFile:localPath] withMask:Image(@"mask_home_center_circle.png")];
                    [_profilePicThumbView setImage:image];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                });
            }
        }];
    }
}
- (void)followersUpdated {
    [self checkForHideScree];
    [_followersActivity stopAnimating];
    [_followers setArray:[DBS followers]];
    _numberOfFollowersLabel.text = [NSString stringWithFormat:@"%d",_followers.count];
    [_tableView reloadData];
}
- (void)followingUpdated {
    [self checkForHideScree];
    [_followingActivity stopAnimating];
    [_following setArray:[DBS following]];
    _numberOfFollowingLabel.text = [NSString stringWithFormat:@"%d",_following.count];
    [_tableView reloadData];
}
- (void)checkForHideScree {
    hideActivityCount+=1;
    if (hideActivityCount > 1) {
        [APP_DELEGATE showActivity:NO];
        hideActivityCount = 0;
    }
}
@end

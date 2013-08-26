//
//  SProfileVc.m
//  Silden
//
//  Created by Amit Priyadarshi on 08/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SProfileVc.h"
#import "SUserProfileViewCell.h"

#define kFollowersSynced_SProfileVc @"kFollowersSynced_SProfileVc"
#define kFollowingSynced_SProfileVc @"kFollowingSynced_SProfileVc"


@interface SProfileVc ()

@end

@implementation SProfileVc {
    NSMutableArray* _usersToDisplay;
}
static NSMutableArray* userStack;
+ (void)emptyUserStack {
    if (userStack) {
        [userStack removeAllObjects];
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization profile_icon_selected@2x.png
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Profile" image:nil tag:0];
        [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"profile_icon_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"profile_icon.png"]];
        if (!userStack) {
            userStack = [[NSMutableArray alloc] init];
            _hideLockCount = 0;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _usersToDisplay = [[NSMutableArray alloc] initWithCapacity:0];
    // Do any additional setup after loading the view from its nib.
    [_followButton setBackgroundImage:StreachImage(@"blueButton37_146.png", 70, 17) forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [APP_DELEGATE setNavigationBarBackground:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followersSynced) name:kFollowersSynced_SProfileVc object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followingSynced) name:kFollowingSynced_SProfileVc object:nil];
    if (_currentUser) {
        [self.navigationItem setTitle:[_currentUser objectForKey:@"name"]];
        NSString* userName = [_currentUser objectForKey:@"name"];
        if (userName && [userStack containsObject:userName]) {
            int index = [userStack indexOfObject:userName];
            if (index >= 0) {
                int count = [userStack count];
                count -= (index+1);
                for (int i = 0; i < count; i++) {
                    [userStack removeLastObject];
                }
            }
        }
        [self setProfilePic];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFollowersSynced_SProfileVc object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFollowingSynced_SProfileVc object:nil];
}
- (void)dealloc {
    [_tableView release];
    [_showsButton release];
    [_followersButton release];
    [_followingButton release];
    [_userProfilePicImageView release];
    [_followButton release];
    [_userTagLine release];
    sRelease(_usersToDisplay);
    [_numberOfShowsLabel release];
    [_numberOfFollowersLabel release];
    [_numberOfFollowingLabel release];
    [_showsActivity release];
    [_followersActivity release];
    [_followingActivity release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [self setShowsButton:nil];
    [self setFollowersButton:nil];
    [self setFollowingButton:nil];
    [self setUserProfilePicImageView:nil];
    [self setFollowButton:nil];
    [self setUserTagLine:nil];
    [self setNumberOfShowsLabel:nil];
    [self setNumberOfFollowersLabel:nil];
    [self setNumberOfFollowingLabel:nil];
    [self setShowsActivity:nil];
    [self setFollowersActivity:nil];
    [self setFollowingActivity:nil];
    [self setFollowers:nil];
    [self setFollowing:nil];
    [super viewDidUnload];
}
- (IBAction)followButtonTap:(UIButton *)sender {
    NSArray* array = [NSArray arrayWithArray:[DBS following]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.name=%@",[_currentUser objectForKey:@"name"]];
    array = [[DBS following] filteredArrayUsingPredicate:predicate];
    if (![array count] && _currentUser) {
        [[DBS following] addObject:_currentUser];
        array = [NSArray arrayWithArray:[DBS following]];
        [DBS updateFollowingListWithArray:array];
    }
}

- (IBAction)showsButtonTap:(UIButton *)sender {
    [self setAllButtonSelected:NO];
    _showsButton.selected = YES;
    //update _usersToDisplay and reload table
}

- (IBAction)followersButtonTap:(UIButton *)sender {
    [self setAllButtonSelected:NO];
    _followersButton.selected = YES;
    //update _usersToDisplay and reload table
    [_usersToDisplay setArray:_followers];
    [_tableView reloadData];
}

- (IBAction)followingButtonTap:(UIButton *)sender {
    [self setAllButtonSelected:NO];
    _followingButton.selected = YES;
    //update _usersToDisplay and reload table
    [_usersToDisplay setArray:_following];
    [_tableView reloadData];
}
- (void)displayProfileForUser:(PFUser*)user {
    [self.navigationItem setTitle:[user objectForKey:@"name"]];
    _currentUser = user;
    [userStack addObject:[user objectForKey:@"name"]];
    [self setProfilePic];
    cRelease(_followers);
    cRelease(_following);
    _following = [[NSMutableArray alloc] initWithCapacity:0];
    _followers = [[NSMutableArray alloc] initWithCapacity:0];
    _hideLockCount = 0;
    [APP_DELEGATE showActivity:YES];
    [self syncFollowers];
    [self syncFollowings];
    dispatch_async(dispatch_get_main_queue(), ^{
        [APP_DELEGATE setNavigationBarBackground:NO];
        _numberOfShowsLabel.text = @"";
        _numberOfFollowersLabel.text = @"";
        _numberOfFollowingLabel.text = @"";
        [_showsActivity startAnimating];
        [_followersActivity startAnimating];
        [_followingActivity startAnimating];
        [_showsButton setSelected:YES];
    });
}
#pragma mark - Private Methods
- (void)followersSynced {
    _numberOfFollowersLabel.text = [NSString stringWithFormat:@"%d",_followers.count];
    [_followersActivity stopAnimating];
    if (_followersButton.selected) {
        [_usersToDisplay setArray:_followers];
        [_tableView reloadData];
    }
}
- (void)followingSynced {
    _numberOfFollowingLabel.text = [NSString stringWithFormat:@"%d",_following.count];
    [_followingActivity stopAnimating];
    if (_followingButton.selected) {
        [_usersToDisplay setArray:_following];
        [_tableView reloadData];
    }
}
- (void)setAllButtonSelected:(BOOL)selected {
    [_showsButton setSelected:selected];
    [_followersButton setSelected:selected];
    [_followingButton setSelected:selected];
}
- (void)setProfilePic {
    PFUser* user = _currentUser;
    PFFile *profilePic = [user objectForKey:kKeyProfilePic];
    NSString* imageUrlStr = [NSString stringWithFormat:@"%@.jpg",[user objectForKey:kKeyUserId]];
    NSString* localPath = [NSString stringWithFormat:@"%@/%@/%@/%@",CACHE_DIR,BaseBufferFolder,
                           NoTypeFolder,
                           [imageUrlStr lastPathComponent]];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:localPath]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage* image = [SCI maskImage:[UIImage imageWithContentsOfFile:localPath] withMask:Image(@"mask_home_center_circle@2x.png")];
            [_userProfilePicImageView setImage:image];
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
                    [_userProfilePicImageView setImage:image];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                });
            }
        }];
    }
}
- (void)syncFollowers {
    PFQuery *query = [PFQuery queryWithClassName:@"followTableList"];
    [query whereKey:@"user_id" equalTo:_currentUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
            return;
        }
        if (objects && [objects count]) {
            PFObject* followTableForCU = [objects lastObject];
            NSArray* followers = [followTableForCU objectForKey:@"followers"];
            if(followers && [followers count]) {
                [self.followers removeAllObjects];
                __block int count = [followers count];
                for (PFUser* usr in followers) {
                    [usr fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if (error) {
                            NSString *errorString = [[error userInfo] objectForKey:@"error"];
                            [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
                            return;
                        }
                        [self.followers addObject:object];
                        if (--count == 0) {
                            [self checkForHideScree];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowersSynced_SProfileVc object:nil];
                        }
                    }];
                }
            }
            else {
                [self checkForHideScree];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFollowersSynced_SProfileVc object:nil];
            }
        }
        else {
            [self checkForHideScree];
            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowersSynced_SProfileVc object:nil];
        }
        
    }];
}
- (void)syncFollowings {
    PFQuery *query = [PFQuery queryWithClassName:@"followTableList"];
    [query whereKey:@"user_id" equalTo:_currentUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
            return;
        }
        if (objects && [objects count]) {
            PFObject* followTableForCU = [objects lastObject];
            NSArray* following = [followTableForCU objectForKey:@"following"];
            [self.following removeAllObjects];
            __block int count = [following count];
            if(following && [following count]) {
                for (PFUser* usr in following) {
                    [usr fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if (error) {
                            NSString *errorString = [[error userInfo] objectForKey:@"error"];
                            [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
                            return;
                        }
                        [self.following addObject:object];
                        if (--count == 0) {
                            [self checkForHideScree];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowingSynced_SProfileVc object:nil];
                        }
                    }];
                }
            }
            else {
                [self checkForHideScree];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFollowingSynced_SProfileVc object:nil];
            }
        }
        else {
            [self checkForHideScree];
            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowingSynced_SProfileVc object:nil];
        }
    }];
}

#pragma mark - TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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
- (void)didTapOnImageView:(UIThumbView*)clikableImage {
    int index = [clikableImage.uniqueIdentifire intValue];
    PFUser *user = [_usersToDisplay objectAtIndex:index];
    
    NSString* userName = [user objectForKey:@"name"];
    NSLog(@"%@",userStack);
    if ([userStack containsObject:userName]) {
        int index = [userStack indexOfObject:userName];
        if (index >= 0 && [[self.navigationController viewControllers] count] > index) {
            [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:index] animated:YES];
            int count = [userStack count];
            count -= (index+1);
            for (int i = 0; i < count; i++) {
                [userStack removeLastObject];
            }
        NSLog(@"%@",userStack);
        }
    }
    else {
        SProfileVc* profileVc = [[[SProfileVc alloc] initWithNibName:@"SProfileVc" bundle:nil] autorelease];
        [profileVc displayProfileForUser:user];
        [self.navigationController pushViewController:profileVc animated:YES];
        self.navigationItem.title = @"Back";
    }
}
- (void)checkForHideScree {
    _hideLockCount+=1;
    if (_hideLockCount > 1) {
        [APP_DELEGATE showActivity:NO];
        _hideLockCount = 0;
    }
}
@end

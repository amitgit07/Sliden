//
//  SFollowUnfollowSelectionVc.m
//  Silden
//
//  Created by Amit Priyadarshi on 09/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SFollowUnfollowSelectionVc.h"


@interface SFollowUnfollowSelectionVc ()

@end

@implementation SFollowUnfollowSelectionVc


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_sildenUsersTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_sildenUsersTableView setBackgroundColor:[UIColor clearColor]];
    [_sildenUserButton setEnabled:NO];
    [_facebookUserButton setEnabled:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _sildenUsers = [[NSMutableArray alloc] initWithCapacity:0];
    _followingFriends = [[NSMutableArray alloc] initWithCapacity:0];

    
    PFQuery* q = [PFUser query];
    
//    NSArray* followers = [DBS followers];
//    NSArray *oFollowers = [followers valueForKey:@"objectId"];
    NSArray* following = [DBS following];
    NSArray *oFollowing = [following valueForKey:@"objectId"];
//    NSOrderedSet *orderedSet1 = [NSOrderedSet orderedSetWithArray:oFollowers];
    NSOrderedSet *orderedSet2 = [NSOrderedSet orderedSetWithArray:oFollowing];
    NSMutableArray* allKnownUsers = [[NSMutableArray alloc] init];
//    [allKnownUsers addObjectsFromArray:[[orderedSet1 set] allObjects]];
    [allKnownUsers addObjectsFromArray:[[orderedSet2 set] allObjects]];
    [allKnownUsers addObject:[[PFUser currentUser] valueForKey:@"objectId"]];
    [q whereKey:@"objectId" notContainedIn:allKnownUsers];
    q.limit = 100;
    [APP_DELEGATE showActivity:YES];
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
            return;
        }
        if (objects) {
            [_sildenUsers setArray:objects];
            [_followingFriends setArray:[DBS following]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_sildenUsersTableView reloadData];
                [APP_DELEGATE showActivity:NO];
            });
        }
    }];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [DBS updateFollowingListWithArray:_followingFriends];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_sildenUsersTableView release];
    [_sildenUserButton release];
    [_facebookUserButton release];
    [super dealloc];
}

#define DoneButtonTag 101
#define SkipButtonTag 200
- (IBAction)skipOrDoneButtonTap:(UIButton *)sender {
    if (sender.tag == DoneButtonTag) {
        if (facebookFriendsView && [facebookFriendsView.selectedFriends count]) {
            [[SharedUtility sharedInstance] scheduleFbPostOnFriendWithIds:[facebookFriendsView.selectedFriends allObjects]];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"first login via facebook"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)sildenUserButtonTap:(id)sender {
    [_sildenUserButton setEnabled:NO];
    [_facebookUserButton setEnabled:YES];
    
    CGRect sRect = _sildenUsersTableView.frame;
    CGRect fRect = facebookFriendsView.frame;
    sRect = CGRectMake(0, sRect.origin.y, sRect.size.width, sRect.size.height);
    fRect = CGRectMake(320, fRect.origin.y, fRect.size.width, fRect.size.height);

    [UIView animateWithDuration:0.20f animations:^{
        [facebookFriendsView setFrame:fRect];
        [_sildenUsersTableView setFrame:sRect];
    } completion:^(BOOL finished) {
        nil;
    }];
}

- (IBAction)inviteFbFriendButtonTap:(id)sender {
    [_sildenUserButton setEnabled:YES];
    [_facebookUserButton setEnabled:NO];
    if (!facebookFriendsView) {
        facebookFriendsView = [[InviteFacebookFriend alloc] initWithFrame:_sildenUsersTableView.frame];
        [self.view addSubview:facebookFriendsView];
    }
    CGRect sRect = _sildenUsersTableView.frame;
    CGRect fRect = facebookFriendsView.frame;
    fRect = CGRectMake(320, fRect.origin.y, fRect.size.width, fRect.size.height);
    [facebookFriendsView setFrame:fRect];

    sRect = CGRectMake(-320, sRect.origin.y, sRect.size.width, sRect.size.height);
    fRect = CGRectMake(0, fRect.origin.y, fRect.size.width, fRect.size.height);
    [UIView animateWithDuration:0.20f animations:^{
        [facebookFriendsView setFrame:fRect];
        [_sildenUsersTableView setFrame:sRect];
    } completion:^(BOOL finished) {
        nil;
    }];
}

- (PFUser*)friendObjectInArrayForUser:(PFUser*)usr inArray:(NSArray*)array{
    NSArray* allUserFolloweByCU = array;//[[PFUser currentUser] objectForKey:@"following_users"];
    if (allUserFolloweByCU && [allUserFolloweByCU count]) {
//        [allUserFolloweByCU makeObjectsPerformSelector:@selector(fetchIfNeeded)];
        NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            PFUser* user = (PFUser*)evaluatedObject;
            if ([[user valueForKey:@"user_id"] isEqualToString:[usr valueForKey:@"user_id"]]) {
                return YES;
            }
            return NO;
        }];
        NSArray* result = [allUserFolloweByCU filteredArrayUsingPredicate:predicate];
        return [result lastObject];
    }
    return nil;
}
#pragma mark - UITableView protocol
- (void)friendListCustomCell:(FriendListCustomCell*)cell didTapFollowButton:(UIButton*)sender {
    switch (cell.followStatus) {
        case FollowStatusFollowing:
        {//unfollow done remove objects
            PFUser* user = [_sildenUsers objectAtIndex:sender.tag];
            NSMutableArray* allUserFolloweByCU = _followingFriends;
            user = [self friendObjectInArrayForUser:user inArray:allUserFolloweByCU];
            [allUserFolloweByCU removeObject:user];
            [DBS removeFollower:[PFUser currentUser] fromUser:user];
        }break;
        case FollowStatusNotFollowing:
        {//follow a user
            PFUser* user = [_sildenUsers objectAtIndex:sender.tag];
            NSMutableArray* allUserFolloweByCU = _followingFriends;
            if (allUserFolloweByCU) {
                [allUserFolloweByCU addObject:user];
            }
            [DBS addFollower:[PFUser currentUser] inUser:user];
        }break;
        default:
            break;
    }


}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_sildenUsers count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    FriendListCustomCell* cell = (FriendListCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[FriendListCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setCellType:CellTypeSildenUser];
        [cell setDelegate:self];
    }
    PFUser* user = [_sildenUsers objectAtIndex:indexPath.row];
    [cell.button setTag:indexPath.row];
    NSMutableArray* allUserFolloweByCU = _followingFriends;

    if ([allUserFolloweByCU containsObject:[self friendObjectInArrayForUser:user inArray:allUserFolloweByCU]]) {
        [cell setFollowStatus:FollowStatusFollowing];
    }
    else {
        [cell setFollowStatus:FollowStatusNotFollowing];
    }
    cell.userName.text = [user objectForKey:kKeyFirstName];
    [cell.userThumb setImageForUser:user];
    return cell;
}

@end

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
    _friendsIdCollection = [[NSMutableString alloc] initWithString:([[PFUser currentUser] valueForKey:kKeyFollowingUsers])?[[PFUser currentUser] valueForKey:kKeyFollowingUsers]:@""];

    [_sildenUserButton setEnabled:NO];
    [_facebookUserButton setEnabled:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    PFQuery *query = [PFUser query];
    [APP_DELEGATE showActivity:YES];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            NSLog(@"Retrived %d",[objects count]);
            [APP_DELEGATE showActivity:NO];
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.user_id != %@",[[PFUser currentUser] valueForKey:kKeyUserId]];
            
            _sildenUsers = [[objects filteredArrayUsingPredicate:predicate] retain];
            [_sildenUsersTableView reloadData];
        }
    }];
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
        [[PFUser currentUser] setValue:_friendsIdCollection forKey:kKeyFollowingUsers];
        [[PFUser currentUser] saveInBackground];
        
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

#pragma mark - UITableView protocol
- (void)friendListCustomCell:(FriendListCustomCell*)cell didTapFollowButton:(UIButton*)sender {
    switch (cell.followStatus) {
        case FollowStatusFollowing:
        {
            PFUser* user = [_sildenUsers objectAtIndex:sender.tag];
            [_followingFriends removeObject:user];
            NSRange range = [_friendsIdCollection rangeOfString:[NSString stringWithFormat:@"%@,",[user valueForKey:kKeyUserId]]];
            [_friendsIdCollection deleteCharactersInRange:range];
        }break;
        case FollowStatusNotFollowing:
        {
            PFUser* user = [_sildenUsers objectAtIndex:sender.tag];
            [_followingFriends addObject:user];
            [_friendsIdCollection appendFormat:@"%@,",[user valueForKey:kKeyUserId]];
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
    
    NSRange range = [_friendsIdCollection rangeOfString:[NSString stringWithFormat:@"%@,",[user valueForKey:kKeyUserId]]];
    if (range.location != NSNotFound) {
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

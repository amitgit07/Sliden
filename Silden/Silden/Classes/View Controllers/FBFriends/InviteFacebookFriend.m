//
//  InviteFacebookFriend.m
//  Silden
//
//  Created by Amit Priyadarshi on 15/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "InviteFacebookFriend.h"

@implementation InviteFacebookFriend {
    NSSet* _facebookFriendsIds;
}
@synthesize selectedFriends;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self getListOfFacebookFriends];

        friendsTable = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [friendsTable setDelegate:self];
        [friendsTable setDataSource:self];
        [friendsTable setBackgroundColor:[UIColor clearColor]];
        [self addSubview:friendsTable];
        
        selectedFriends = [[NSMutableSet alloc] init];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)getListOfFriendsWhoAreOnSilden {
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.fbId IN %@",_facebookFriendsIds];
//    PFQuery* quary = [PFQuery queryWithClassName:@"fbUserOnSilden" predicate:predicate];
//    [APP_DELEGATE showActivity:YES];
//    [quary findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        [APP_DELEGATE showActivity:NO];
//        if (!error) {
//            friendsOnFb = [[NSSet setWithArray:objects] retain];
//            NSLog(@"friends on FB = %@",friendsOnFb);
//        }
//        else {
//            NSLog(@"Error 232 = %@",error);
//        }
//    }];
}
- (void)getListOfFacebookFriends {
    _friendsArray = [[[SharedUtility sharedInstance] getFbFriends] retain];
    _facebookFriendsIds = [[NSSet setWithArray:[[SharedUtility sharedInstance] getFbFriendsIds]] retain];
    [self getListOfFriendsWhoAreOnSilden];
}

#pragma mark - UITable View Protocol methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_friendsArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"facebook cell";
    FriendListCustomCell* cell = (FriendListCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[FriendListCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setCellType:CellTypeFacebookFriends];
        [cell setDelegate:self];
        [cell setCheckStatus:CheckboxStatusUnselected];
    }
    PFUser* user = [_friendsArray objectAtIndex:indexPath.row];
    [cell.checkBox setTag:indexPath.row];
    cell.userName.text = [user objectForKey:kKeyFirstName];
    NSString* profilePicUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",validObject(user[@"id"])];
    [cell.userThumb setImageFromUrlString:profilePicUrl];
    
    if ([selectedFriends containsObject:user[@"id"]]) {
        [cell setCheckStatus:CheckboxStatusSelected];
    }
    else {
        [cell setCheckStatus:CheckboxStatusUnselected];
    }
    return cell;
}

#pragma mark - 
- (void)friendListCustomCell:(FriendListCustomCell*)cell didTapOnCheckBox:(UIButton*)checkBox {
    
    PFUser* user = [_friendsArray objectAtIndex:checkBox.tag];
    [selectedFriends addObject:user[@"id"]];
}
@end
/*
NSMutableDictionary *postTest = [[NSMutableDictionary alloc]init];
[postTest setObject:[NSString stringWithFormat@"Your message"] forKey:@"message"];
[postTest setObject:@"" forKey:@"picture"];
[postTest setObject:@"" forKey:@"name"];
[postTest setObject:@"APPID" forKey:@"app_id"];
NSString *userFBID =[NSString stringWithFormat:@"%@",[allInfoDict objectForKey:@"Friends facebook ID "]];

[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/feed?access_token=%@",userFBID,[appDelegate.mysession accessToken]]
                             parameters:postTest
                             HTTPMethod:@"POST"
                      completionHandler:^(FBRequestConnection *connection,
                                          NSDictionary * result,
                                          NSError *error) {
                          if (error) {
                              [self hideHUD];
                              NSLog(@"Error: %@", [error localizedDescription]);
                              
                          } else {
                              // Success
                              
                          }
                      }];

[postTest release];
*/
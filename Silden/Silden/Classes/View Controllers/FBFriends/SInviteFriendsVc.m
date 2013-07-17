//
//  SInviteFriendsVc.m
//  Silden
//
//  Created by Amit Priyadarshi on 09/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SInviteFriendsVc.h"

@interface SInviteFriendsVc ()

@end

@implementation SInviteFriendsVc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)getFbFriends {
//    NSArray *permissions = [[NSArray alloc]initWithObjects:@"email",@"user_birthday",@"user_hometown",@"user_location",@"friends_birthday",@"friends_location",@"friends_hometown", nil];
//    
//    [FBSession openActiveSessionWithReadPermissions:permissions
//                                       allowLoginUI:YES
//                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//                                      NSLog(@"1");
//                                      if (session.isOpen) {
//                                          NSLog(@"2");
//                                          FBRequest *me = [FBRequest requestForMe];
//                                          [me startWithCompletionHandler: ^(FBRequestConnection *connection,
//                                                                            NSDictionary<FBGraphUser> *my,
//                                                                            NSError *error) {
//                                              NSLog(@"3");
//                                              NSLog(@"My dcitionary:- %@",my);
//                                              FBRequest *friendRequest = [FBRequest requestForMyFriends];
//                                              [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                                                  NSLog(@"4");
//                                                  NSArray *data = [result objectForKey:@"data"];
//                                                  
//                                                  for (FBGraphObject<FBGraphUser> *friend in data) {
//                                                      NSLog(@"%@", [friend first_name]);
//                                                  }
//                                              }];
//                                          }];
//                                      }
//                                  }];
    
    FBSession * session = [FBSession activeSession];
    [APP_DELEGATE showActivity:YES];
    if (session.isOpen) {
        FBRequest* friendsRequest = [FBRequest requestForMyFriends];
        [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                      NSDictionary* result,
                                                      NSError *error) {
            [APP_DELEGATE showActivity:NO];
            _friendsArray = [[result objectForKey:@"data"] retain];
            NSLog(@"Found: %i friends", _friendsArray.count);
            for (NSDictionary<FBGraphUser>* friend in _friendsArray) {
                NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
            }
        }];
    }
    else {
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getFbFriends];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

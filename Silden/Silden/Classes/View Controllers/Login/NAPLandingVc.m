//
//  NAPLandingVc.m
//  Silden
//
//  Created by Amit Priyadarshi on 28/04/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "NAPLandingVc.h"
#import "NAPLoginVc.h"
#import "NAPRegistrationVc.h"
#import <Parse/Parse.h>
#import "SInviteFriendsVc.h"
#import "SFollowUnfollowSelectionVc.h"
#define DevelopmentMode 1

@interface NAPLandingVc ()
- (void)saveDataOnCloud:(NSDictionary*)dict forUser:(PFUser*)user;
@end

@implementation NAPLandingVc

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
}
- (void)viewDidAppear:(BOOL)animated {
    self.title = @"Home";
#if DevelopmentMode
        [UIView transitionFromView:self.navigationController.view
                            toView:[[APP_DELEGATE tabBarController] view]
                          duration:0.35f
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:^(BOOL finished) {
                            [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE tabBarController]];
                        }];
#else
    if ([[PFFacebookUtils session] isOpen]) {
        [UIView transitionFromView:self.navigationController.view
                            toView:[[APP_DELEGATE tabBarController] view]
                          duration:0.35f
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:^(BOOL finished) {
                            [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE tabBarController]];
                        }];
    }
#endif

//    else {
//        for (int i = 1; i < 97; i++) {
//            [self performSelector:@selector(registerNewUser) withObject:nil afterDelay:i * 0.5f];
//        }
//
//    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fbConnectButtonTap:(UIButton *)sender {
    [APP_DELEGATE showActivity:YES];
//    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSArray* facebookCookies = [cookies cookiesForURL:
//                                [NSURL URLWithString:@"http://login.facebook.com"]];
//    
//    for (NSHTTPCookie* cookie in facebookCookies) {
//        [cookies deleteCookie:cookie];
//    }
    
    NSArray *permissionsArray = @[@"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"friends_birthday",@"friends_location",@"friends_hometown", kKeyEmailId, @"publish_stream"];
    
    [PFFacebookUtils initializeFacebook];
    [APP_DELEGATE setLaunchedOtherApplication:YES];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [APP_DELEGATE showActivity:NO];
        if (!user) {
            if (!error) {
                DLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                DLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            DLog(@"User with facebook signed up and logged in!");
            NSString *requestPath = @"me/?fields=first_name,middle_name,last_name,name,location,gender,birthday,relationship_status,email";
            [APP_DELEGATE showActivity:YES];
            FBRequest *request = [FBRequest requestForGraphPath:requestPath];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                [APP_DELEGATE showActivity:NO];
                if (!error) {
                    NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary
                    [self saveDataOnCloud:userData forUser:user];
                    DLog(@" %@", userData);
                }
            }];
        } else {
            [UIView transitionFromView:self.navigationController.view
                                toView:[[APP_DELEGATE tabBarController] view]
                              duration:0.35f
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            completion:^(BOOL finished) {
                                [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE tabBarController]];
                            }];

        }
    }];
}

- (IBAction)loginButtonTap:(UIButton *)sender {
    NAPLoginVc* loginVc = [[[NAPLoginVc alloc] initWithNibName:@"NAPLoginVc" bundle:nil] autorelease];
    [self.navigationController pushViewController:loginVc animated:YES];
}

- (IBAction)registerButtonTap:(UIButton *)sender {
    NAPRegistrationVc* registerVc = [[[NAPRegistrationVc alloc] initWithNibName:@"NAPRegistrationVc" bundle:nil] autorelease];
    [self.navigationController pushViewController:registerVc animated:YES];
}

#pragma mark - Private Methods
- (NSString*)generateUserId {
    NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate];
    int randontAddition = random()%90+10;
    NSString* result = [NSString stringWithFormat:@"%d%f",randontAddition, interval];
    result = [result stringByReplacingOccurrencesOfString:@"." withString:@""];
    return result;
}
- (void)transferDataFrom:(NSDictionary*)dict to:(PFUser*)object {
    NSString* uniqueUserId = [self generateUserId];
    NSString* name = [NSString stringWithFormat:@"%@ %@",validObject(dict[kKeyFirstName]), validObject(dict[kKeyLastName])];
    [object setValue:name forKey:kKeyFirstName];
    [object setEmail:validObject(dict[kKeyEmailId])];
    [object setUsername:validObject(dict[kKeyBirthName])];
    [object setValue:uniqueUserId forKey:kKeyUserId];
    [object setValue:@"" forKey:kKeyFollowingUsers];
    [object setValue:validObject(dict[@"id"]) forKey:@"id"];
    NSData* pic = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",validObject(dict[@"id"])]]];
    PFFile *file = [PFFile fileWithName:[NSString stringWithFormat:@"%@.jpg",uniqueUserId] data:pic];
    [file saveInBackground];
    [object setValue:file forKey:kKeyProfilePic];
}
- (void)saveDataOnCloud:(NSDictionary*)dict forUser:(PFUser*)user {
    [self transferDataFrom:dict to:user];
    NAPRegistrationVc* registerVc = [[[NAPRegistrationVc alloc] initWithNibName:@"NAPRegistrationVc" bundle:nil] autorelease];
    [self.navigationController pushViewController:registerVc animated:YES];
    [registerVc registerUserWithInfo:user];
}
- (void)dealloc {
    [_testButtonTap release];
    [super dealloc];
}
- (void)registerNewUser {
    static int i = 0;
    i++;
    PFUser *user = [PFUser user];
    NSString* uniqueUserId = [self generateUserId];
    NSString* name = [NSString stringWithFormat:@"Amit_%d Priyadarshi",i];
    [user setValue:uniqueUserId forKey:kKeyUserId];
    [user setValue:name forKey:kKeyFirstName];
    [user setEmail:[NSString stringWithFormat:@"amit%d@gmail.com",i]];
    [user setUsername:[NSString stringWithFormat:@"amit%d@gmail.com",i]];
    [user setPassword:@"amit1234"];
    [user setValue:@"" forKey:kKeyFollowingUsers];
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"1 (%d).jpg",i]];
    NSData* data = UIImageJPEGRepresentation(image, 0.5f);
    PFFile *file = [PFFile fileWithName:[NSString stringWithFormat:@"%@.jpg",uniqueUserId] data:data];
    [file saveInBackground];
    [user setValue:file forKey:kKeyProfilePic];

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error) {
            DLog(@"Registered user %d",i);
        }
    }];
}
- (IBAction)testBtnTap:(id)sender {
//    SInviteFriendsVc* registerVc = [[[SInviteFriendsVc alloc] initWithNibName:@"SInviteFriendsVc" bundle:nil] autorelease];
//    [self.navigationController pushViewController:registerVc animated:YES];
}
@end

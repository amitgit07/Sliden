//
//  SHomeVc.m
//  Silden
//
//  Created by Amit Priyadarshi on 08/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SHomeVc.h"
#import "SFollowUnfollowSelectionVc.h"

@interface SHomeVc ()

@end

@implementation SHomeVc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:0];
        [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"home_icon_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"home_icon.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [super dealloc];
}
- (IBAction)logoutButtonTap:(id)sender {
    [PFUser logOut];
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:
                                [NSURL URLWithString:@"http://login.facebook.com"]];
    
    for (NSHTTPCookie* cookie in facebookCookies) {
        [cookies deleteCookie:cookie];
    }
    [[APP_DELEGATE landingNavigationCntrl] popToRootViewControllerAnimated:NO];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE landingNavigationCntrl]];
//    [UIView transitionFromView:self.navigationController.view
//                        toView:[[APP_DELEGATE landingNavigationCntrl] view]
//                      duration:0.35f
//                       options:UIViewAnimationOptionTransitionFlipFromLeft
//                    completion:^(BOOL finished) {
//                        [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE landingNavigationCntrl]];
//                    }];
}
@end

//
//  NAPForgotPasswordVc.m
//  Silden
//
//  Created by Amit Priyadarshi on 28/04/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "NAPForgotPasswordVc.h"

@interface NAPForgotPasswordVc ()

@end

@implementation NAPForgotPasswordVc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Recover";
        Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
        reachability.reachableBlock = ^(Reachability *reachability) {
            NSLog(@"Network is reachable.");
            [APP_DELEGATE showActivity:NO];
        };
        reachability.unreachableBlock = ^(Reachability *reachability) {
            [APP_DELEGATE showActivity:YES];
            [APP_DELEGATE showLockScreenStatusWithMessage:@"Your internet connection appears to be offline."];
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [SCI applyEffectOnBoldLable:_pageTitle];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendPassword:(UIButton *)sender {
    [_emailTextField resignFirstResponder];
    if (![SCI isValidEmail:_emailTextField.text]) {
        [SCI showAlertWithMsg:@"Enter valid email!"];
        return;
    }
    [APP_DELEGATE showActivity:YES];
    [PFUser requestPasswordResetForEmailInBackground:_emailTextField.text block:^(BOOL succeeded, NSError *error) {
        [APP_DELEGATE showActivity:NO];
        if (error) {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
            return;
        }
        if (succeeded) {
            [SCI showAlertWithMsg:@"An email has been sent to your account."];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [SCI showAlertWithMsg:[[error userInfo] objectForKey:@"error"]];
        }
    }];
}

- (IBAction)backButtonTap:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)dealloc {
    [_emailTextField release];
    [_pageTitle release];
    [super dealloc];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendPassword:nil];
    return YES;
}

@end

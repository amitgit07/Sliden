//
//  NAPLoginVc.m
//  Silden
//
//  Created by Amit Priyadarshi on 28/04/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "NAPLoginVc.h"
#import "NAPForgotPasswordVc.h"
#import "NAPRegistrationVc.h"

@interface NAPLoginVc ()
- (void)resignAllResponders;
@end

@implementation NAPLoginVc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Login";
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
- (void)viewDidAppear:(BOOL)animated {
}
- (void)dealloc {
    [_emailTextField release];
    [_passwordTextField release];
    [_pageTitle release];
    [super dealloc];
}
#pragma mark - Textfield Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _emailTextField) {
        [_passwordTextField becomeFirstResponder];
    }
    else {
        [_passwordTextField resignFirstResponder];
        [self loginButtonTap:nil];
    }
    return YES;
}
#pragma mark - IBAction Methods
- (NSString*)checkForValidInput {
    NSString* error = nil;
    if (_emailTextField.text.length < 1) {
        error = @"Email can not be blank!";
    }
    else if (_passwordTextField.text.length < 1) {
        error = @"Password can not be blank!";
    }
    return error;
}
- (IBAction)loginButtonTap:(UIButton *)sender {
    NSString* error = [self checkForValidInput];
    if (error) {
        [SCI showAlertWithMsg:[error description]];
    }
    if (![SCI isValidEmail:_emailTextField.text]) {
        [SCI showAlertWithMsg:@"Enter valid email!"];
        return;
    }
    [APP_DELEGATE showActivity:YES];
    [PFUser logInWithUsernameInBackground:self.emailTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        [APP_DELEGATE showActivity:NO];
        if (user) {
            [UIView transitionFromView:self.navigationController.view
                                toView:[[APP_DELEGATE tabBarController] view]
                              duration:0.35f
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            completion:^(BOOL finished) {
                                [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE tabBarController]];
                            }];
        } else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            if ([errorString length] > 80)
                [SCI showAlertWithMsg:@"Something went wrong.\nPlease try again later."];
            else
                [SCI showAlertWithMsg:errorString];
        }
    }];
}
- (IBAction)registerButtonTap:(UIButton *)sender {
    [self resignAllResponders];
    NAPRegistrationVc* registerVc = [[[NAPRegistrationVc alloc] initWithNibName:@"NAPRegistrationVc" bundle:nil] autorelease];
    [self.navigationController pushViewController:registerVc animated:YES];
}

- (IBAction)forgotPasswordTap:(id)sender {
    [self resignAllResponders];
    NAPForgotPasswordVc* forgotVc = [[[NAPForgotPasswordVc alloc] initWithNibName:@"NAPForgotPasswordVc" bundle:nil] autorelease];
    [self.navigationController pushViewController:forgotVc animated:YES];
}

- (IBAction)backButtonTap:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private Methods
- (void)resignAllResponders {
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

@end

//
//  NAPRegistrationVc.m
//  Silden
//
//  Created by Amit Priyadarshi on 08/02/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "NAPRegistrationVc.h"
#import "SFollowUnfollowSelectionVc.h"

@interface NAPRegistrationVc ()
- (void)resignAllResponder;
- (void)registerForKeyboardNotifications;
- (NSString*)generateUserId;
@end

@implementation NAPRegistrationVc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Registration";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isThroughFbConnect = NO;
    _profilePic = nil;
    //TODO: set default profile pic
    // Do any additional setup after loading the view from its nib.
    [self.view addSubview:_personalDetailView];
    
    CGRect rect = _personalDetailView.frame;
    rect.origin.x = 0;
    rect.origin.y = 110;
    _personalDetailView.frame = rect;
    
    rect = _sildenIdentityView.frame;
    rect.origin.x = 320;
    rect.origin.y = 110;
    _sildenIdentityView.frame = rect;
    [_sildenIdentityView setContentSize:CGSizeMake(320, 230)];
    _sildenIdentityView.hidden = YES;
    [self.view addSubview:_sildenIdentityView];
    _mainButton.tag = 10;
    
    [_profilePicButton setHidden:YES];
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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [SCI applyEffectOnBoldLable:_pageTitle];
    [self registerForKeyboardNotifications];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_nameTextField release];
    [_emailTextField release];
    [_passwordTextField release];
    [_confirmTextField release];
    [_userNameTextField release];
    [_personalDetailView release];
    [_sildenIdentityView release];
    [_pageTitle release];
    [_mainButton release];
    [_profilePicButton release];
    [super dealloc];
}
- (BOOL)validateAllFields {
    if(![SCI isValidText:_nameTextField.text]) {
        [SCI showAlertWithMsg:@"Enter valid name"];
        return NO;
    }
    else if (![SCI isValidEmail:_emailTextField.text]) {
        [SCI showAlertWithMsg:@"Enter valid email!"];
        return NO;
    }
    else if(![_passwordTextField.text isEqualToString:_confirmTextField.text]) {
        [SCI showAlertWithMsg:@"Password don't match"];
        return NO;
    }
    return YES;
}
- (NSString*)checkForInfoPersonalValidity {
    NSString* errorMsg = nil;
    if (_nameTextField.text.length < 1) {
        errorMsg = @"Name can not be blank.";
    }
    else if (![SCI isValidEmail:_emailTextField.text]) {
        errorMsg = @"Enter valid email.";
    }
    return errorMsg;
}
- (NSString*)checkForInfoSildenIdentityValidity {
    NSString* errorMsg = nil;
    if (_userNameTextField.text.length < 1) {
        errorMsg = @"Username can not be blank.";
    }
    else if ([_userNameTextField.text rangeOfString:@" "].location != NSNotFound) {
        errorMsg = @"Username should not contain space.";
    }
    else if (_passwordTextField.text.length < 6) {
        errorMsg = @"Password should be at least 6 charecters long.";
    }
    else if (_confirmTextField.text.length < 6) {
        errorMsg = @"Confirm Password should be at least 6 charecters long.";
    }
    else if (![_passwordTextField.text isEqualToString:_confirmTextField.text]) {
        errorMsg = @"Passwords don't match.";
    }
    
    return errorMsg;
}
- (IBAction)setProfilePicButtonTap:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Sliden" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take a Photo", @"Select from Gallery", nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1: {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [APP_DELEGATE setNavigationBarBackground:NO];
                UIImagePickerController* imgPicker = [[UIImagePickerController alloc] init];
                imgPicker.allowsEditing = NO;
                imgPicker.delegate = self;
                imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imgPicker animated:YES completion:nil];
            }
            else {
                [SCI showAlertWithMsg:@"Camera not available in your device."];
            }
        }break;
        case 2: {
            [APP_DELEGATE setNavigationBarBackground:NO];
            UIImagePickerController* imgPicker = [[UIImagePickerController alloc] init];
            imgPicker.allowsEditing = NO;
            imgPicker.delegate = self;
            imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imgPicker animated:YES completion:nil];
        }break;
            
        default:
            break;
    }
}
- (IBAction)registerButtonTap:(UIButton *)sender {
    //[self resignAllResponder];
    if (sender.tag == TAG_BTN_NEXT) {
        NSString* error = [self checkForInfoPersonalValidity];
        if (error) {
            [SCI showAlertWithMsg:error];
            return;
        }
        [_profilePicButton setHidden:NO];
        [_profilePicButton setEnabled:YES];
        sender.tag = TAG_BTN_Register;
        [sender setImage:[UIImage imageNamed:@"register_done_button.png"] forState:UIControlStateNormal];
        [_pageTitle setText:@"STEP 2 - CREATE YOUR SLIDEN IDENTITY"];
        //show next view
        [_sildenIdentityView setHidden:NO];
        CGRect rect = _sildenIdentityView.frame;
        rect.origin.x = 320.0f;
        _sildenIdentityView.frame = rect;
        
        [UIView animateWithDuration:0.25f animations:^{
            CGRect rect = _personalDetailView.frame;
            rect.origin.x = -320.0f;
            _personalDetailView.frame = rect;
            
            CGRect rect1 = _sildenIdentityView.frame;
            rect1.origin.x = 0.0f;
            _sildenIdentityView.frame = rect1;
        } completion:^(BOOL finished) {
            [_personalDetailView setHidden:YES];
        }];
    }
    else {
        NSString* error = [self checkForInfoSildenIdentityValidity];
        if (error) {
            [SCI showAlertWithMsg:error];
            return;
        }
        
        if (!_userInfo) {
            _userInfo = [PFUser user];
        }
        [_userInfo setValue:_nameTextField.text forKey:kKeyFirstName];
        [_userInfo setEmail:_emailTextField.text];
        [_userInfo setUsername:_emailTextField.text];//_userNameTextField.text
        [_userInfo setPassword:_passwordTextField.text];
        [_userInfo setValue:@"" forKey:kKeyFollowingUsers];
        
        
        [APP_DELEGATE showActivity:YES];
        if (isThroughFbConnect) {
            [_userInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [APP_DELEGATE showActivity:NO];
                if (!error) {
                    PFObject* fbIds = [PFObject objectWithClassName:@"fbUserOnSilden"];
                    [fbIds setObject:[_userInfo objectForKey:@"id"] forKey:@"fbId"];
                    [fbIds saveInBackground];
                    [UIView transitionFromView:self.navigationController.view
                                        toView:[[APP_DELEGATE tabBarController] view]
                                      duration:0.35f
                                       options:UIViewAnimationOptionTransitionFlipFromLeft
                                    completion:^(BOOL finished) {
                                        [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE tabBarController]];
                                        SFollowUnfollowSelectionVc* vc = [[[SFollowUnfollowSelectionVc alloc] initWithNibName:@"SFollowUnfollowSelectionVc" bundle:nil] autorelease];
                                        [[APP_DELEGATE tabBarController] presentViewController:vc animated:YES completion:nil];
                                    }];
                } else {
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    [SCI showAlertWithMsg:errorString];
                }
            }];
        }
        else {
            NSString* uniqueUserId = [self generateUserId];
            [_userInfo setValue:uniqueUserId forKey:kKeyUserId];
            if (_profilePic) {
                NSData* pic = UIImageJPEGRepresentation(_profilePic, 0.6f);
                PFFile *file = [PFFile fileWithName:[NSString stringWithFormat:@"%@.jpg",uniqueUserId] data:pic];
                [file saveInBackground];
                [_userInfo setValue:file forKey:kKeyProfilePic];
            }
            [_userInfo signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [APP_DELEGATE showActivity:NO];
                if (!error) {
                    [UIView transitionFromView:self.navigationController.view
                                        toView:[[APP_DELEGATE tabBarController] view]
                                      duration:0.35f
                                       options:UIViewAnimationOptionTransitionFlipFromLeft
                                    completion:^(BOOL finished) {
                                        [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE tabBarController]];
                                    }];
//                    [self.navigationController popToRootViewControllerAnimated:YES];
                } else {
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    [SCI showAlertWithMsg:errorString];
                    _userInfo = nil;
                }
            }];
        }
    }
    
}
- (IBAction)backButtonTap:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)registerUserWithInfo:(PFUser*)user {
    isThroughFbConnect = YES;
    self.userInfo = user;
    self.nameTextField.text = [user objectForKey:kKeyFirstName];
    self.emailTextField.text = [user email];
    [self.emailTextField setUserInteractionEnabled:NO];
}

#pragma mark - Textfield Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    currentResponder = textField;
    if (textField == _passwordTextField) {
        [_confirmTextField setText:@""];
    }
    if ([textField superview]==_sildenIdentityView) {
        [_sildenIdentityView setClipsToBounds:YES];
        CGSize selfSize= self.view.bounds.size;
        keyboardEndFrame = CGRectMake(0, hDevice-220, 320, 216);
        CGRect viewFrame = _sildenIdentityView.frame;
        [UIView animateWithDuration:0.15f animations:^{
            [_sildenIdentityView setFrame:CGRectMake(0, viewFrame.origin.y, selfSize.width, selfSize.height-keyboardEndFrame.size.height-viewFrame.origin.y)];
        }completion:^(BOOL finished) {
             CGFloat newY = currentResponder.frame.origin.y - (selfSize.height-keyboardEndFrame.size.height-viewFrame.origin.y) + 30;
             [_sildenIdentityView scrollRectToVisible:CGRectMake(0, (newY>0)?newY : 0 , 320, 50) animated:YES];
        }];
    }

    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case TAG_TF_NAME:
            [_emailTextField becomeFirstResponder];
            break;
        case TAG_TF_USERNAME:
            [_passwordTextField becomeFirstResponder];
            break;
        case TAG_TF_PASSWORD:
            [_confirmTextField becomeFirstResponder];
            break;
        default:
            [textField resignFirstResponder];
            break;
    }
    return YES;
}
#pragma mark - Private Methods
- (void)resignAllResponder {
    [_nameTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_confirmTextField resignFirstResponder];
}
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)keyboardWasShown:(NSNotification*)aNotification {
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    [UIView animateWithDuration:0.25f animations:^{
        [_sildenIdentityView setFrame:CGRectMake(0, _sildenIdentityView.frame.origin.y, 320, 230)];
    }];
}
- (NSString*)generateUserId {
    NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate];
    int randontAddition = random()%90+10;
    NSString* result = [NSString stringWithFormat:@"%d%f",randontAddition, interval];
    result = [result stringByReplacingOccurrencesOfString:@"." withString:@""];
    return result;
}

#pragma mark - IMage Picker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [APP_DELEGATE setNavigationBarBackground:YES];
    _profilePic = [[info objectForKey:@"UIImagePickerControllerOriginalImage"] retain];
    [self dismissViewControllerAnimated:YES completion:nil];
    [_profilePicButton setTitle:@"CHANGE PROFILE PHOTO" forState:UIControlStateNormal];
//    [_profilePicButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [APP_DELEGATE setNavigationBarBackground:YES];
    _profilePic = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

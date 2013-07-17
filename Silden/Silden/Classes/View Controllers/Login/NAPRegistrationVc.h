//
//  NAPRegistrationVc.h
//  Silden
//
//  Created by Amit Priyadarshi on 08/02/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TAG_BTN_NEXT        10
#define TAG_BTN_Register    11

#define TAG_TF_NAME             20
#define TAG_TF_EMAIL            21
#define TAG_TF_USERNAME         22
#define TAG_TF_PASSWORD         23
#define TAG_TF_CONFIRM_PASSWORD 24

@interface NAPRegistrationVc : SViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    BOOL isThroughFbConnect;
    CGRect keyboardEndFrame;
    UITextField *currentResponder;
    UIImage* _profilePic;
}
@property (retain, nonatomic) PFUser* userInfo;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UITextField *emailTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UITextField *confirmTextField;
@property (retain, nonatomic) IBOutlet UITextField *userNameTextField;
@property (retain, nonatomic) IBOutlet UIView *personalDetailView;
@property (retain, nonatomic) IBOutlet UIScrollView *sildenIdentityView;
@property (retain, nonatomic) IBOutlet UIButton *profilePicButton;
@property (retain, nonatomic) IBOutlet UILabel *pageTitle;
@property (retain, nonatomic) IBOutlet UIButton *mainButton;
- (IBAction)setProfilePicButtonTap:(id)sender;

- (IBAction)registerButtonTap:(UIButton *)sender;
- (IBAction)backButtonTap:(UIButton *)sender;
- (void)registerUserWithInfo:(PFUser*)user;
@end

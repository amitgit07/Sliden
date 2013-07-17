//
//  NAPLoginVc.h
//  Silden
//
//  Created by Amit Priyadarshi on 28/04/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    AuthenticationTypeUnknown,
    AuthenticationTypeEmailNotAvailable,
    AuthenticationTypePasswordWrong,
    AuthenticationTypeValid,
}AuthenticationType;

@interface NAPLoginVc : SViewController <UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UILabel *pageTitle;
@property (retain, nonatomic) IBOutlet UITextField *emailTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)loginButtonTap:(UIButton *)sender;
- (IBAction)registerButtonTap:(UIButton *)sender;
- (IBAction)forgotPasswordTap:(id)sender;
- (IBAction)backButtonTap:(UIButton *)sender;

@end

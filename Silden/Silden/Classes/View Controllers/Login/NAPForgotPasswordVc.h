//
//  NAPForgotPasswordVc.h
//  Silden
//
//  Created by Amit Priyadarshi on 28/04/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NAPForgotPasswordVc : SViewController <UITextFieldDelegate>{
    
}

@property (retain, nonatomic) IBOutlet UILabel *pageTitle;
@property (retain, nonatomic) IBOutlet UITextField *emailTextField;
- (IBAction)sendPassword:(UIButton *)sender;
- (IBAction)backButtonTap:(UIButton *)sender;
@end

//
//  SInfoEditorVc.h
//  Sliden
//
//  Created by Amit Priyadarshi on 01/07/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkSpace.h"

@interface SInfoEditorVc : SGrayViewController <UITextFieldDelegate,UITextViewDelegate, UIScrollViewDelegate>
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UITextField *titleTextField;
@property (retain, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, strong) WorkSpace* workSpace;
@property (retain, nonatomic) IBOutlet UIToolbar *toolBar;

- (IBAction)selectTuneButtonTap:(UIButton *)sender;
- (IBAction)keepSlidenButtonTap:(id)sender;
- (IBAction)homeButtonTap:(UIButton *)sender;
- (IBAction)toolBarDontButtonTap:(id)sender;

@end

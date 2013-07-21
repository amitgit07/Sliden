//
//  SInfoEditorVc.m
//  Sliden
//
//  Created by Amit Priyadarshi on 01/07/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SInfoEditorVc.h"
#import "SPreviewVc.h"

@interface SInfoEditorVc ()

@end

@implementation SInfoEditorVc
@synthesize workSpace=_workSpace;

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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    [_scrollView setContentSize:CGSizeMake(320, 320)];
    _titleTextField.text = _workSpace.title;
    _descriptionTextView.text = _workSpace.videoDescription;
}
- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSDictionary* d = [aNotification userInfo];
    CGRect r = [d[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float duration = [d[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    r = [self.view convertRect:r fromView:nil];
    
    [UIView animateWithDuration:duration animations:^{
        [_scrollView setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-r.size.height)];
    }];
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    [UIView animateWithDuration:0.25f animations:^{
        [_scrollView setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-74)];
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text length]>3) {
        [_descriptionTextView becomeFirstResponder];
        return YES;
    }
    else {
        [SCI showAlertWithMsg:@"Title for video is required."];
        return NO;
    }
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if ([textView.text length]>5) {
        return YES;
    }
    else {
        [SCI showAlertWithMsg:@"Desciption for video is required."];
        return NO;
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_titleTextField resignFirstResonder];
    [_descriptionTextView resignFirstResonder];
}
- (void)dealloc {
    [_scrollView release];
    [_titleTextField release];
    [_descriptionTextView release];
    [super dealloc];
}
- (IBAction)selectTuneButtonTap:(UIButton *)sender {
    [SCI showDevelopmentAlert];
}

- (IBAction)keepSlidenButtonTap:(id)sender {
    if ([_titleTextField.text length]>3 && [_descriptionTextView.text length]>5) {
        _workSpace.title = _titleTextField.text;
        _workSpace.videoDescription = _descriptionTextView.text;
        [APP_DELEGATE saveContext];
        SPreviewVc* newObj = [[SPreviewVc alloc] initWithNibName:@"SPreviewVc" bundle:nil];
        newObj.workSpace = self.workSpace;
        [self.navigationController pushViewController:newObj animated:YES];
    }
}

- (IBAction)homeButtonTap:(UIButton *)sender {
    if ([_titleTextField.text length]>3 && [_descriptionTextView.text length]>5) {
        _workSpace.title = _titleTextField.text;
        _workSpace.videoDescription = _descriptionTextView.text;
        [APP_DELEGATE saveContext];
    }
    [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE tabBarController]];
}
@end

//
//  SInfoEditorVc.m
//  Sliden
//
//  Created by Amit Priyadarshi on 01/07/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SInfoEditorVc.h"
#import "SPreviewVc.h"
#import "SCategorySelectorVc.h"
#define ToolBarHeight 44
@interface SInfoEditorVc ()

@end

@implementation SInfoEditorVc
@synthesize workSpace=_workSpace;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction) name:@"So UI to select track" object:nil];
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
    self.title = @"Add Info";
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
    [self.view addSubview:_toolBar];
    [_toolBar setHidden:NO];
    [_toolBar setFrame:CGRectMake(0, self.view.frame.size.height, 320, ToolBarHeight)];
    [UIView animateWithDuration:duration animations:^{
        [_toolBar setFrame:CGRectMake(0, self.view.frame.size.height-r.size.height-ToolBarHeight, 320, ToolBarHeight)];
        [_scrollView setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-r.size.height-ToolBarHeight)];
    }];
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    NSDictionary* d = [aNotification userInfo];
    float duration = [d[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        [_toolBar setFrame:CGRectMake(0, self.view.frame.size.height, 320, ToolBarHeight)];
        [_scrollView setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-74)];
    }completion:^(BOOL finished) {
        [_toolBar removeFromSuperview];
        [_toolBar setHidden:YES];
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text length]) {
        [_descriptionTextView becomeFirstResponder];
    }
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    _workSpace.videoDescription = textView.text;
}
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [_titleTextField resignFirstResonder];
//    [_descriptionTextView resignFirstResonder];
//}
- (void)dealloc {
    [_scrollView release];
    [_titleTextField release];
    [_descriptionTextView release];
    [_toolBar release];
    [super dealloc];
}
- (void)notificationAction {
    double delayInSeconds = 0.30;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self showCategoryView];
    });
}
- (void)showCategoryView {
    SCategorySelectorVc* newObj = [[[SCategorySelectorVc alloc] initWithNibName:@"SCategorySelectorVc" bundle:nil] autorelease];
    [self.navigationController pushViewController:newObj animated:YES];
    newObj.workSpace = _workSpace;
    self.title = @"Back";
}
- (IBAction)selectTuneButtonTap:(UIButton *)sender {
    [self showCategoryView];
}

- (IBAction)keepSlidenButtonTap:(id)sender {
    NSString* title = [_titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* videoDescription = [_descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([title length]>0 && [videoDescription length]>0) {
//        if (![_workSpace.title isEqualToString:title] || ![_workSpace.videoDescription isEqualToString:videoDescription])
//            _workSpace.isAnyChange = [NSNumber numberWithInt:([_workSpace.isAnyChange integerValue] | WorkSpaceChangedInInfoEditor)];
        
        _workSpace.title = title;
        _workSpace.videoDescription = videoDescription;
        [APP_DELEGATE saveContext];
        SPreviewVc* newObj = [[SPreviewVc alloc] initWithNibName:@"SPreviewVc" bundle:nil];
        newObj.workSpace = self.workSpace;
        [self.navigationController pushViewController:newObj animated:YES];
        self.title=@"Back";
    }
    else if ([title length] < 1) {
        [SCI showAlertWithMsg:@"Title can not be blank."];
    }
    else if ([videoDescription length] < 1) {
        [SCI showAlertWithMsg:@"Desciption can not be blank."];
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

- (IBAction)toolBarDontButtonTap:(id)sender {
    [_titleTextField resignFirstResonder];
    [_descriptionTextView resignFirstResonder];
}
- (void)viewDidUnload {
    [self setToolBar:nil];
    [self setToolBar:nil];
    [super viewDidUnload];
}
@end

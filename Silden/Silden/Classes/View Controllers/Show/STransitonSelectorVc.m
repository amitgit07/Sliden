//
//  STransitonSelectorVc.m
//  Sliden
//
//  Created by Amit Priyadarshi on 09/06/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "STransitonSelectorVc.h"
#import "SPhotoSelectorVc.h"
#import "SPhotoSelectorVc.h"

#define IntNumber(o) [NSNumber numberWithInt:o]

@interface STransitonSelectorVc ()
- (void)backButtonTap:(id)sender;
- (WorkSpace*)createNewWorkSpace;
@end

@implementation STransitonSelectorVc {
    NSArray* transitions;
    NSMutableArray* selectedTransitions;
}
@synthesize workSpace = _workSpace;

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
    transitions = [[NSArray arrayWithObjects:IntNumber(kTransitionTypeFade), IntNumber(kTransitionTypeExitToLeft), IntNumber(kTransitionTypeExitToRight), IntNumber(kTransitionTypeExitToTop), IntNumber(kTransitionTypeExitToBottom), IntNumber(kTransitionTypeFlipFromLeft), IntNumber(kTransitionTypeFlipFromRight), IntNumber(kTransitionTypeFlipFromTop), IntNumber(kTransitionTypeFlipFromBottom), IntNumber(kTransitionTypeEnterFromLeft), IntNumber(kTransitionTypeEnterFromRight), IntNumber(kTransitionTypeEnterFromTop), IntNumber(kTransitionTypeEnterFromBottom), nil] retain];

    selectedTransitions = [[NSMutableArray alloc] initWithCapacity:0];
    self.icarouselView.type = iCarouselTypeRotary;
    [self getSelectedTransitons];
    [self.icarouselView reloadData];
    // Do any additional setup after loading the view from its nib.
    
    
    for (int i = 0; i < 3; i++) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[Image(@"blueBtn37.png") stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
        [button setBackgroundImage:[Image(@"grabutton37.png") stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateDisabled];
        if (i == 0) {
            [button setTitle:@"CLASSIC PACK" forState:UIControlStateNormal];
        }
        else {
            [button setTitle:@"COMING SOON" forState:UIControlStateNormal];
            [button setEnabled:NO];
        }
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:9]];
        [button.titleLabel setTextColor:[UIColor whiteColor]];
        [button setFrame:CGRectMake(i*105+5, 225, 100, 37)];
        [self.view addSubview:button];
    }
    UIButton* help = [UIButton buttonWithType:UIButtonTypeCustom];
    [help setBackgroundImage:Image(@"help_button.png") forState:UIControlStateNormal];
    [help.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [help setTitle:@"Help" forState:UIControlStateNormal];
    [help setFrame:CGRectMake(0, 0, 60, 30)];
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithCustomView:help];
    [self.navigationItem setRightBarButtonItem:rightButton animated:YES];

    UIButton* back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back addTarget:self action:@selector(backButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [back setBackgroundImage:Image(@"back_button.png") forState:UIControlStateNormal];
    [back.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [back setFrame:CGRectMake(0, 0, 50, 30)];
    UIBarButtonItem* leftButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    [self.navigationItem setLeftBarButtonItem:leftButton animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"Transitions";
}

#pragma mark -
#pragma mark iCarousel methods
- (void)getSelectedTransitons {
    NSString* allTranitionIndexes = _workSpace.transitions;
    NSArray* allObjs = [allTranitionIndexes componentsSeparatedByString:@"-"];
    for (NSString* transitionIndex in allObjs) {
        [selectedTransitions addObject:[NSNumber numberWithInt:[transitionIndex intValue]]];
    }
}
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //generate 100 item views
    //normally we'd use a backing array
    //as shown in the basic iOS example
    //but for this example we haven't bothered
    return [transitions count];
}
- (void)addAnimationOnView:(STransitionSampleVIew*)view {
    [view demonstratedTransition:[[transitions objectAtIndex:view.transionIndex] intValue]];//
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (!view)
    {
        view = [STransitionSampleVIew sampelViewWithTransition:kTransitionTypeEnterFromBottom];
        [view setBackgroundColor:[UIColor clearColor]];
        [(STransitionSampleVIew*)view setDelegate:self];
    }
    [(STransitionSampleVIew*)view setTransionIndex:index];
    [self performSelector:@selector(addAnimationOnView:) withObject:view afterDelay:0];
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSNumber* num=(NSNumber*)evaluatedObject;
        if (num.intValue == [[transitions objectAtIndex:index] intValue]) {
            return YES;
        }
        return NO;
    }];
    NSArray* arr = [selectedTransitions filteredArrayUsingPredicate:predicate];
    [(STransitionSampleVIew*)view setSelected:[arr count]];
    return view;
}

- (void)dealloc {
    self.icarouselView.dataSource = nil;
    self.icarouselView.delegate = nil;
    [_icarouselView release];
    [super dealloc];
}
- (IBAction)homeButtonTap:(id)sender {
    [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE tabBarController]];
}

- (IBAction)applyWholePackTap:(id)sender {
    [selectedTransitions setArray:transitions];
    [self.icarouselView reloadData];
}
- (NSString*)makeTransitionString {
    DLog(@"1");
    NSString* str = [selectedTransitions componentsJoinedByString:@"-"];
    return str;
}
- (IBAction)keepSlidenTap:(id)sender {
    NSString* transition = [self makeTransitionString];
    if (transition.length < 1) {
        [SCI showAlertWithMsg:@"Please select at least one transition."];
    }
    else {
        if (!_workSpace) 
            _workSpace = [self createNewWorkSpace];
        if (![_workSpace.transitions isEqualToString:transition]) _workSpace.isAnyChange = [NSNumber numberWithInt:([_workSpace.isAnyChange integerValue] | WorkSpaceChangedInTransition)];
        _workSpace.transitions = transition;
        SPhotoSelectorVc* newObj = [[SPhotoSelectorVc alloc] initWithNibName:@"SPhotoSelectorVc" bundle:nil];
        newObj.workSpace = _workSpace;
        [self.navigationController pushViewController:newObj animated:YES];
        self.title = @"Back";
        [APP_DELEGATE saveContext];
    }
}
- (void)selectionStateChangedForView:(STransitionSampleVIew*)view newState:(BOOL)selected {
    
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSNumber* num=(NSNumber*)evaluatedObject;
        if (num.intValue == view.transiton) {
            return YES;
        }
        return NO;
    }];
    NSArray* arr =[selectedTransitions filteredArrayUsingPredicate:predicate];
    if (selected) {
        if (![arr count]) {
            [selectedTransitions addObject:[NSNumber numberWithInt:view.transiton]];
        }
    }
    else {
        if ([arr count])
            [selectedTransitions removeObject:[arr lastObject]];
    }
    
}
#pragma mark - Private Methods
- (void)backButtonTap:(id)sender {
    [APP_DELEGATE setNavigationBarBackground:YES];
    [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE tabBarController]];
    CGRect frame = [APP_DELEGATE tabBarController].view.frame;
    frame.origin.x = -320;
    [APP_DELEGATE tabBarController].view.frame = frame;
    frame.origin.x = 0;
    [UIView animateWithDuration:0.2f animations:^{
        [APP_DELEGATE tabBarController].view.frame = frame;
    } completion:^(BOOL finished) {
    }];
}
- (WorkSpace*)createNewWorkSpace {
    NSError* error;
    if (!_workSpace) {
        NSManagedObjectContext* context = [APP_DELEGATE managedObjectContext];
        _workSpace = [NSEntityDescription insertNewObjectForEntityForName:@"WorkSpace" inManagedObjectContext:context];
        _workSpace.dateCreated = [NSDate date];
        _workSpace.dateModified = [NSDate date];
        _workSpace.title = @"Unfinished Show";
    }

    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* folderPath = [CACHE_DIR stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[NSDate date]]];
    if ([fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error]) {
        return _workSpace;
    }
    return nil;
}
@end

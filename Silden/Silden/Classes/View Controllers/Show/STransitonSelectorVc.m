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

@interface STransitonSelectorVc ()
- (void)backButtonTap:(id)sender;
- (WorkSpace*)createNewWorkSpace;
@end

@implementation STransitonSelectorVc
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
    self.icarouselView.type = iCarouselTypeRotary;
    // Do any additional setup after loading the view from its nib.
    
    for (int i = 0; i < 3; i++) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[Image(@"blueBtn37.png") stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
        [button setBackgroundImage:[Image(@"grabutton37.png") stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateDisabled];
        if (i == 0) {
            [button setTitle:@"CLASSIC PACK" forState:UIControlStateNormal];
        }
        else {
            [button setTitle:@"COOMING SOON" forState:UIControlStateNormal];
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
    [back setFrame:CGRectMake(0, 0, 60, 30)];
    UIBarButtonItem* leftButton = [[UIBarButtonItem alloc] initWithCustomView:back];
    [self.navigationItem setLeftBarButtonItem:leftButton animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //generate 100 item views
    //normally we'd use a backing array
    //as shown in the basic iOS example
    //but for this example we haven't bothered
    return 10;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (!view)
    {
    	view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 175, 175)] autorelease];
        [view setBackgroundColor:[UIColor clearColor]];
        UIImageView *bg = [[UIImageView alloc] initWithFrame:view.bounds];
        [bg setBackgroundColor:[UIColor clearColor]];
        [bg setImage:[UIImage imageNamed:@"video_bg.png"]];
        [view addSubview:bg];
        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 85, 175, 25)];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setBackgroundColor:[UIColor redColor]];
        [lbl setTag:100];
        [lbl setTextColor:[UIColor blackColor]];
        [view addSubview:lbl];
    }
    UILabel* lbl = (UILabel*)[view viewWithTag:100];
    [lbl setText:[NSString stringWithFormat:@"%d",index+1]];
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
}

- (IBAction)keepSlidenTap:(id)sender {
    SPhotoSelectorVc* newObj = [[[SPhotoSelectorVc alloc] initWithNibName:@"SPhotoSelectorVc" bundle:nil] autorelease];
    newObj.workSpace = [self createNewWorkSpace];
    [self.navigationController pushViewController:newObj animated:YES];
}
#pragma mark - Private Methods
- (void)backButtonTap:(id)sender {
    [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE tabBarController]];
}
- (WorkSpace*)createNewWorkSpace {
    NSError* error;
    if (!_workSpace) {
        NSManagedObjectContext* context = [APP_DELEGATE managedObjectContext];
        _workSpace = [NSEntityDescription insertNewObjectForEntityForName:@"WorkSpace" inManagedObjectContext:context];
        _workSpace.dateCreated = [NSDate date];
        _workSpace.dateModified = [NSDate date];
        _workSpace.title = @"Unfinished Show";
        [APP_DELEGATE saveContext];
    }

    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* folderPath = [DOC_DIR stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",_workSpace.dateCreated]];
    [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
    if (error) {
        NSLog(@"%@",error);
    }

    return _workSpace;
}
@end

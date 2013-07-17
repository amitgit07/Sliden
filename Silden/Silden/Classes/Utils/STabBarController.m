//
//  STabBarController.m
//  Silden
//
//  Created by Amit Priyadarshi on 08/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "STabBarController.h"

@interface STabBarController ()

@end

@implementation STabBarController {
    UIButton* _centerButton;
}

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
	// Do any additional setup after loading the view.
    
    [[self.view.subviews objectAtIndex:0] setFrame:CGRectMake(0, 0, wDevice, hDevice-TABBAR_HEIGHT)];
    [self.tabBar setFrame:CGRectMake(0, hDevice-TABBAR_HEIGHT, wDevice, TABBAR_HEIGHT)];
    
//    [[self tabBar] setBackgroundImage:[UIImage imageNamed:@"tabBarBg.png"]];
//    [[self tabBar] setSelectionIndicatorImage:nil];
    [[self tabBar] setBackgroundImage:[UIImage imageNamed:@"ican_tab_bar.png"]];
    [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];

}
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
     _centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _centerButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    _centerButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [_centerButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [_centerButton setBackgroundImage:highlightImage forState:UIControlStateSelected];
    [_centerButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        _centerButton.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        _centerButton.center = center;
    }
    
    [self.view addSubview:_centerButton];
    [_centerButton addTarget:self action:@selector(centerButtonTap:) forControlEvents:UIControlEventTouchDown];
}
- (void)centerButtonTap:(UIButton*)button {
    if (button.selected) {
        UINavigationController* nvc = [[self viewControllers] objectAtIndex:2];
        [nvc popToRootViewControllerAnimated:YES];
    }
    [button setSelected:YES];
    [self setSelectedIndex:2];
}
- (void)setSelectedViewController:(UIViewController *)vc {
    [super setSelectedViewController:vc];
    int index = [self.viewControllers indexOfObject:vc];
    if (index==2) {
        [_centerButton setSelected:YES];
    }
    else {
        [_centerButton setSelected:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

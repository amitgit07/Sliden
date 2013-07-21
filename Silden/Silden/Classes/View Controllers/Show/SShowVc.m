//
//  SShowVc.m
//  Silden
//
//  Created by Amit Priyadarshi on 08/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SShowVc.h"
#import "SLoadSavedShowVc.h"
#import "STransitonSelectorVc.h"

@interface SShowVc ()

@end

@implementation SShowVc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0];
        [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"tab_film_on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_film_off.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createShowButtonTap:(UIButton *)sender {
    STransitonSelectorVc* newObj = [[[STransitonSelectorVc alloc] initWithNibName:@"STransitonSelectorVc" bundle:nil] autorelease];
    UINavigationController* nvc = [[[UINavigationController alloc] initWithRootViewController:newObj] autorelease];
    [UIView transitionFromView:self.view toView:newObj.view duration:0.35f options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        [APP_DELEGATE setNavigationBarBackground:NO];
        [[APP_DELEGATE window] setRootViewController:nvc];
    }];
}

- (IBAction)loadShowButtonTap:(UIButton *)sender {
    SLoadSavedShowVc* newObj = [[[SLoadSavedShowVc alloc] initWithNibName:@"SLoadSavedShowVc" bundle:nil] autorelease];
    [self.navigationController pushViewController:newObj animated:YES];
    [self.navigationItem.backBarButtonItem setTitle:@"Back"];
}
@end

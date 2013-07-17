//
//  SViewController.m
//  Silden
//
//  Created by Amit Priyadarshi on 07/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SViewController.h"

@interface SViewController ()

@end

@implementation SViewController

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
    
    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_bgImageView setAutoresizingMask:63];
    [_bgImageView setImage:[UIImage imageNamed:IS_PHONE5?@"main_bg-568@2x.png":@"main_bg.png"]];
    [self.view addSubview:_bgImageView];
    [self.view sendSubviewToBack:_bgImageView];
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [_bgImageView setFrame:self.view.bounds];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    sRelease(_bgImageView);
    [super dealloc];
}

@end

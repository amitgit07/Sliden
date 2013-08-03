//
//  SGrayViewController.m
//  Silden
//
//  Created by Amit Priyadarshi on 10/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SGrayViewController.h"

@interface SGrayViewController ()

@end

@implementation SGrayViewController

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
    
    _bg = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_bg setAutoresizingMask:63];
    [_bg setImage:[Image(@"BG.png") stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
    [self.view addSubview:_bg];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_bg setFrame:self.view.bounds];
    [self.view sendSubviewToBack:_bg];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    sRelease(_bg);
    [super dealloc];
}
@end

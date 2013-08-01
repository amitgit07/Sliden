//
//  NAPMoreVc.m
//  Silden
//
//  Created by Amit Priyadarshi on 28/04/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SMoreVc.h"
#import "SDefaultSlidenCells.h"
@interface SMoreVc ()

@end

@implementation SMoreVc {
    NSArray* _options;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"More" image:nil tag:0];
        [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:@"more_icon_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"more_icon.png"]];
        
        _options = [@[@"Edit Profile", @"Settings", @"Other Apps", @"Share", @"Rate and Review App", @"Log out"] retain];
        [APP_DELEGATE setNavigationBarBackground:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_options count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.view.frame.size.height-54)/[_options count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    SDefaultSlidenCells* cell = (SDefaultSlidenCells*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[SDefaultSlidenCells alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    cell.showTitleLabel.text = [_options objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 5:
        {
            [PFUser logOut];
            NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray* facebookCookies = [cookies cookiesForURL:
                                        [NSURL URLWithString:@"http://login.facebook.com"]];
            
            for (NSHTTPCookie* cookie in facebookCookies) {
                [cookies deleteCookie:cookie];
            }
            [[APP_DELEGATE landingNavigationCntrl] popToRootViewControllerAnimated:NO];
            [self.navigationController popToRootViewControllerAnimated:NO];
            [[APP_DELEGATE window] setRootViewController:[APP_DELEGATE landingNavigationCntrl]];
        }break;
            
        default:
            [SCI showDevelopmentAlert];
            break;
    }
}

- (IBAction)connectViaFbButtonTap:(UIButton *)sender {
    [SCI showDevelopmentAlert];
}
- (void)dealloc {
    [_tableView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end

//
//  SCategorySelectorVc.m
//  Sliden
//
//  Created by Amit Priyadarshi on 27/07/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SCategorySelectorVc.h"
#import "SDefaultSlidenCells.h"
#import "STrackSelectorVc.h"

@interface SCategorySelectorVc ()

@end

@implementation SCategorySelectorVc {
    NSMutableArray* _categories;
    NSArray* _allSongsInfo;
}
@synthesize workSpace = _workSpace;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _categories = [[NSMutableArray alloc] initWithCapacity:0];
//        for (int i=0; i< 10; i++) {
//            [_categories addObject:[NSString stringWithFormat:@"Category #%d",i+1]];
//        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem.leftBarButtonItem setTitle:@"Back"];
    // Do any additional setup after loading the view from its nib.
    [APP_DELEGATE showActivity:YES];
    PFQuery* musicCat = [PFQuery queryWithClassName:@"MusicCat"];
    [musicCat findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        _allSongsInfo =[objects retain];
        for (PFObject* category in objects) {
            if (![_categories containsObject:[category objectForKey:@"cat_name"]]) {
                [_categories addObject:[category objectForKey:@"cat_name"]];
            }
        }
        [_tableView reloadData];
        [APP_DELEGATE showActivity:NO];
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    self.title = @"Categories";
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_categories count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    SDefaultSlidenCells* cell = (SDefaultSlidenCells*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[SDefaultSlidenCells alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    cell.showTitleLabel.text = [_categories objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.title= @"Back";
    STrackSelectorVc* newObj = [[[STrackSelectorVc alloc] initWithNibName:@"STrackSelectorVc" bundle:nil] autorelease];
    newObj.workSpace = _workSpace;
    newObj.allSongs = _allSongsInfo;
    newObj.selectedCategory = [_categories objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:newObj animated:YES];
}

@end
//
//  AssetTablePicker.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"
#define BottomBarHeight 74
@interface ELCAssetTablePicker ()

@property (nonatomic, assign) int columns;

@end

@implementation ELCAssetTablePicker {
    UIScrollView* selectedImageViewer;
    UIView* baseBottomView;
}

@synthesize parent = _parent;;
@synthesize selectedAssetsLabel = _selectedAssetsLabel;
@synthesize assetGroup = _assetGroup;
@synthesize elcAssets = _elcAssets;
@synthesize singleSelection = _singleSelection;
@synthesize columns = _columns;

- (void)viewDidLoad
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.tableView setAllowsSelection:NO];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
    [tempArray release];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(someImageSelected) name:@"image selected" object:nil];
    if (self.immediateReturn) {
        
    } else {
        UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneButton setBackgroundImage:Image(@"help_button.png") forState:UIControlStateNormal];
        [doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [doneButton setFrame:CGRectMake(0, 0, 60, 30)];
        [doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* leftButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
        [self.navigationItem setLeftBarButtonItem:leftButton animated:YES];
        
        UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setBackgroundImage:Image(@"help_button.png") forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(0, 0, 60, 30)];
        [cancelButton addTarget:self.parent action:@selector(cancelImagePicker) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* rightButton = [[[UIBarButtonItem alloc] initWithCustomView:cancelButton] autorelease];
        [self.navigationItem setRightBarButtonItem:rightButton animated:YES];


//        UIBarButtonItem *doneButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
//        [self.navigationItem setLeftBarButtonItem:leftButton];
//        [self.navigationItem setTitle:@"Loading..."];
        
    }

	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.columns = self.view.bounds.size.width / 80;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.columns = self.view.bounds.size.width / 80;
    [self.tableView reloadData];
}

- (void)preparePhotos
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSLog(@"enumerating photos");
    [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if(result == nil) {
            return;
        }

        ELCAsset *elcAsset = [[ELCAsset alloc] initWithAsset:result];
        [elcAsset setParent:self];
        [self.elcAssets addObject:elcAsset];
        [elcAsset release];
     }];
    NSLog(@"done enumerating photos");
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        // scroll to bottom
        int section = [self numberOfSectionsInTableView:self.tableView] - 1;
        int row = [self tableView:self.tableView numberOfRowsInSection:section] - 1;
        if (section >= 0 && row >= 0) {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:row
                                                 inSection:section];
            [self.tableView scrollToRowAtIndexPath:ip
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:NO];
        }
        
//        [self.navigationItem setTitle:self.singleSelection ? @"Pick Photo" : @"Pick Photos"];
    });
    
    [pool release];

}
- (void)someImageSelected {
    NSMutableArray *selectedAssetsImages = [[[NSMutableArray alloc] init] autorelease];
	for(ELCAsset *elcAsset in self.elcAssets) {
		if([elcAsset selected]) {
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
    [[selectedImageViewer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    int i = 0;
    for (ALAsset *asset in selectedAssetsImages) {
        //add in scroll view
        //[UIImage imageWithCGImage:asset.asset.thumbnail]
        UIImageView* thumb = [[[UIImageView alloc] initWithFrame:CGRectMake(i*70 + 5, 7, 60, 60)] autorelease];
        thumb.image = [UIImage imageWithCGImage:asset.thumbnail];
        [selectedImageViewer addSubview:thumb];
        i++;
    }
    [selectedImageViewer setContentSize:CGSizeMake(i*70+5, BottomBarHeight)];
}
- (void)doneAction:(id)sender
{	
	NSMutableArray *selectedAssetsImages = [[[NSMutableArray alloc] init] autorelease];
	    
	for(ELCAsset *elcAsset in self.elcAssets) {

		if([elcAsset selected]) {
			
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
        
    [self.parent selectedAssets:selectedAssetsImages];
}

- (void)assetSelected:(id)asset
{
    if (self.singleSelection) {

        for(ELCAsset *elcAsset in self.elcAssets) {
            if(asset != elcAsset) {
                elcAsset.selected = NO;
            }
        }
    }
    if (self.immediateReturn) {
        NSArray *singleAssetArray = [NSArray arrayWithObject:[asset asset]];
        [(NSObject *)self.parent performSelector:@selector(selectedAssets:) withObject:singleAssetArray afterDelay:0];
    }
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ceil([self.elcAssets count] / (float)self.columns);
}

- (NSArray *)assetsForIndexPath:(NSIndexPath *)path
{
    int index = path.row * self.columns;
    int length = MIN(self.columns, [self.elcAssets count] - index);
    return [self.elcAssets subarrayWithRange:NSMakeRange(index, length)];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
        
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {		        
        cell = [[[ELCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier] autorelease];

    } else {		
		[cell setAssets:[self assetsForIndexPath:indexPath]];
	}
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return BottomBarHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (!selectedImageViewer) {
        baseBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, BottomBarHeight)];
        [baseBottomView setBackgroundColor:[UIColor redColor]];
        
        UIImageView* bg = [[[UIImageView alloc] initWithFrame:baseBottomView.bounds] autorelease];
        [bg setImage:Image(@"tab_bar.png")];
        [baseBottomView addSubview:bg];
        
        selectedImageViewer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, BottomBarHeight)];
        [selectedImageViewer setShowsVerticalScrollIndicator:NO];
        [selectedImageViewer setShowsHorizontalScrollIndicator:NO];
        [baseBottomView addSubview:selectedImageViewer];
    }
    return baseBottomView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	return 79;
}

- (int)totalSelectedAssets {
    
    int count = 0;
    
    for(ELCAsset *asset in self.elcAssets) {
		if([asset selected]) {   
            count++;	
		}
	}
    
    return count;
}

- (void)dealloc 
{
    [_assetGroup release];    
    [_elcAssets release];
    [_selectedAssetsLabel release];
    [super dealloc];    
}

@end

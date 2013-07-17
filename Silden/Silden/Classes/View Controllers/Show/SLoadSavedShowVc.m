//
//  SLoadSavedShowVc.m
//  Sliden
//
//  Created by Amit Priyadarshi on 28/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SLoadSavedShowVc.h"
#import "STransitonSelectorVc.h"
#import "WorkSpace.h"


@interface LoadShowCells : UITableViewCell
@property(nonatomic, retain) UILabel* showTitleLabel;
@property(nonatomic, retain) UILabel* lastModifiedDateLabel;
@property(nonatomic, retain) UILabel* lastModifiedTimeLabel;
@end

@implementation LoadShowCells

@synthesize showTitleLabel=_showTitleLabel;
@synthesize lastModifiedDateLabel=_lastModifiedDateLabel;
@synthesize lastModifiedTimeLabel=_lastModifiedTimeLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //
        _showTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 18, 165, 18)];
        [_showTitleLabel setTextAlignment:NSTextAlignmentLeft];
        [_showTitleLabel setTextColor:RGBA(36, 143, 183, 1.0)];
        [_showTitleLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [_showTitleLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_showTitleLabel];

        _lastModifiedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 18, 165, 18)];
        [_lastModifiedDateLabel setTextAlignment:NSTextAlignmentLeft];
        [_lastModifiedDateLabel setTextColor:RGBA(93, 93, 93, 1.0)];
        [_lastModifiedDateLabel setFont:[UIFont boldSystemFontOfSize:11]];
        [_lastModifiedDateLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lastModifiedDateLabel];

        _lastModifiedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 18, 165, 18)];
        [_lastModifiedTimeLabel setTextAlignment:NSTextAlignmentLeft];
        [_lastModifiedTimeLabel setTextColor:RGBA(93, 93, 93, 1.0)];
        [_lastModifiedTimeLabel setFont:[UIFont boldSystemFontOfSize:11]];
        [_lastModifiedTimeLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lastModifiedTimeLabel];
        
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

@end

@interface SLoadSavedShowVc ()

@end

@implementation SLoadSavedShowVc
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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCell:(LoadShowCells *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WorkSpace *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.showTitleLabel.text = object.title;
    NSDateFormatter* formator = [[NSDateFormatter alloc] init];

    [formator setDateFormat:@"dd/MM/yy"];
    cell.lastModifiedDateLabel.text = [formator stringFromDate:object.dateModified];

    [formator setDateFormat:@"hh:mm"];
    cell.lastModifiedTimeLabel.text = [formator stringFromDate:object.dateModified];
    [formator release];
}

#pragma mark - TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    LoadShowCells* cell = (LoadShowCells*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[LoadShowCells alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    SPhotoSelectorVc* newObj = [[[SPhotoSelectorVc alloc] initWithNibName:@"SPhotoSelectorVc" bundle:nil] autorelease];
//    newObj.workSpace = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    [self.navigationController pushViewController:newObj animated:YES];
//

    _workSpace = [self.fetchedResultsController objectAtIndexPath:indexPath];
    STransitonSelectorVc* newObj = [[[STransitonSelectorVc alloc] initWithNibName:@"STransitonSelectorVc" bundle:nil] autorelease];
    newObj.workSpace = _workSpace;
    UINavigationController* nvc = [[[UINavigationController alloc] initWithRootViewController:newObj] autorelease];
    [APP_DELEGATE setNavigationBarBackground:NO];
    [[APP_DELEGATE window] setRootViewController:nvc];
}
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WorkSpace" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"dateModified" ascending:NO] autorelease];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"] autorelease];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}
- (NSManagedObjectContext*)managedObjectContext {
    if(!_managedObjectContext) {
        _managedObjectContext = [APP_DELEGATE managedObjectContext];
    }
    return _managedObjectContext;
}
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(LoadShowCells*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}
- (void)dealloc {
    _fetchedResultsController.delegate = nil;
    [_fetchedResultsController release];
    _fetchedResultsController = nil;
    _managedObjectContext= nil;
    [_tableView release];
    [super dealloc];
}
@end
//
//  SLoadSavedShowVc.h
//  Sliden
//
//  Created by Amit Priyadarshi on 28/05/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGrayViewController.h"
#import "WorkSpace.h"

@interface SLoadSavedShowVc : SGrayViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (assign, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) WorkSpace* workSpace;
@end

//
//  SCategorySelectorVc.h
//  Sliden
//
//  Created by Amit Priyadarshi on 27/07/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkSpace.h"

@interface SCategorySelectorVc : SGrayViewController <UITableViewDataSource, UITableViewDelegate> {
    
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) WorkSpace* workSpace;
@end

//
//  STrackSelectorVc.h
//  Sliden
//
//  Created by Amit Priyadarshi on 27/07/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WorkSpace.h"


@interface STrackSelectorVc : UIViewController <AVAudioPlayerDelegate> {
    AVAudioPlayer *audioPlayer;
}
@property(nonatomic, retain) NSString* selectedCategory;
@property(nonatomic, retain) NSArray* allSongs;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) WorkSpace* workSpace;
@end

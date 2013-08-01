//
//  SPreviewVc.h
//  Sliden
//
//  Created by Amit Priyadarshi on 17/07/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkSpace.h"
#import <MediaPlayer/MediaPlayer.h>


@interface SPreviewVc : SGrayViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) WorkSpace* workSpace;
@property (nonatomic, strong) MPMoviePlayerController* mpController;
@property (retain, nonatomic) IBOutlet UIView *infoView;
@property (retain, nonatomic) IBOutlet UIView *optionView;
@property (retain, nonatomic) IBOutlet UIImageView *videoThumbView;
@property (retain, nonatomic) IBOutlet UIView *optionHolder;

- (IBAction)uploadButtonTap:(UIButton *)sender;
- (IBAction)settingsButtonTap:(UIButton *)sender;
- (IBAction)playButtonTap:(id)sender;





@end

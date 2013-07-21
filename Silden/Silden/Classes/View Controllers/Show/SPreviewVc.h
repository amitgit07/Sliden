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

#define Video_W 640.0f
#define Video_H 480.0f
#define Video_Thumb_W 600.0f
#define Video_Thumb_H 350.0f

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

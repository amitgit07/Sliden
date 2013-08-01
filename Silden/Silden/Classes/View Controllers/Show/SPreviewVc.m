//
//  SPreviewVc.m
//  Sliden
//
//  Created by Amit Priyadarshi on 17/07/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SPreviewVc.h"
#import "WorkingImage.h"
#import "ImageToVideo.h"
#import "CALayer+DTUIKitAdditions.h"
#import <AVFoundation/AVFoundation.h>
@interface SPreviewVc ()

@end

@implementation SPreviewVc {
    UIImage* imageBase;
    NSArray* settingsOption;
    BOOL isSettingVisible;
    BOOL videoAlreadyMade;
    NSMutableArray* selectedTransitions;
}
@synthesize workSpace=_workSpace;
@synthesize mpController=_mpController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        imageBase = [[UIImage imageNamed:@"imageBase.png"] retain];
        settingsOption = [[NSArray arrayWithObjects:@"Change Transition", @"Change Photos", @"Edit Information", @"Change Background Track", nil] retain];
        isSettingVisible = NO;
        videoAlreadyMade = NO;
        selectedTransitions = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoConversionStarted:) name:kNotificationVideoConversionStarted object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoConversionFinished:) name:kNotificationVideoConversionFinished object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSArray* allImages = [self.workSpace.images allObjects];
    NSSortDescriptor* desc = [[[NSSortDescriptor alloc] initWithKey:@"imageIndex" ascending:YES] autorelease];
    allImages = [allImages sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
    for (WorkingImage* image in allImages) {
        [self resizeImageAtPath:image.imageUrl];
    }
    [self makeVideo];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    WorkingImage* image = [_workSpace.images anyObject];
    NSString* thumbPath = [[image.imageUrl stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"thumb.png"];
    [self.videoThumbView setImage:[UIImage imageWithContentsOfFile:thumbPath]];
    self.title = @"Preview";
}
- (void)resizeImageAtPath:(NSString*)path {
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = Video_W/Video_H;
    CGSize videoSize = CGSizeMake(Video_W, Video_H);
    float x=0, y=0;
    
    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = Video_H / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = Video_H;
            y = 0;
            x = (Video_W-actualWidth)/2.0f;
        }
        else{
            imgRatio = Video_W / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = Video_W;
            x = 0;
            y = (Video_H-actualHeight)/2.0f;
        }
    }
    else {
        actualWidth = Video_W;
        actualHeight = Video_H;
    }
    CGRect rect = CGRectMake(x, y, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(videoSize);
    [imageBase drawInRect:CGRectMake(0.0, 0.0, Video_W, Video_H)];
    [image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * binaryImageData = UIImagePNGRepresentation(newImage);
    [binaryImageData writeToFile:path atomically:YES];
}
-(void)videoConversionStarted:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationVideoConversionStarted object:nil];
    NSLog(@"Started Processing Images...");
}

-(void)videoConversionFinished:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationVideoConversionFinished object:nil];
    NSNumber* number = [notification object];
    switch ([number intValue]) {
        case AVAssetExportSessionStatusCompleted: {
            videoAlreadyMade = YES;
            _workSpace.isAnyChange = [NSNumber numberWithInt:0];
        }break;
        case AVAssetExportSessionStatusFailed:
        case AVAssetExportSessionStatusCancelled:
            [SCI showAlertWithMsg:@"Something went wrong\n Please go to previous screen and try again."];
        default:
        break;
    }
    [APP_DELEGATE showActivity:NO];
}
- (void)playMovie:(NSNotification *)notification {
    MPMoviePlayerController *player = notification.object;
    if (player.loadState & MPMovieLoadStatePlayable)
    {
        NSLog(@"Movie is Ready to Play");
        [player play];
    }
}
- (void)playCompletedVideo {
    WorkingImage* anyImages = [_workSpace.images anyObject];
    NSString* videoPath = [[anyImages.imageUrl stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"vido.mov"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playMovie:) name:MPMoviePlayerLoadStateDidChangeNotification object:_mpController];

        MPMoviePlayerViewController* player = [[MPMoviePlayerViewController alloc]
                                               initWithContentURL:[NSURL fileURLWithPath:videoPath]];
        
        [player.moviePlayer setScalingMode:MPMovieScalingModeNone];
        [self presentMoviePlayerViewControllerAnimated:player];
        [player.moviePlayer play];
    }
}
- (void)dealloc {
    sRelease(selectedTransitions);
    [_infoView release];
    [_optionView release];
    [_videoThumbView release];
    [_optionHolder release];
    [super dealloc];
}
- (void)getSelectedTransitons {
    NSString* allTranitionIndexes = _workSpace.transitions;
    NSArray* allObjs = [allTranitionIndexes componentsSeparatedByString:@"-"];
    for (NSString* transitionIndex in allObjs) {
        [selectedTransitions addObject:[NSNumber numberWithInt:[transitionIndex intValue]]];
    }
}

- (void)makeVideo {
    if (![_workSpace.isAnyChange integerValue])
        return;
    
    [APP_DELEGATE showActivity:YES];
    [APP_DELEGATE showLockScreenStatusWithMessage:@"Creating Video!"];

    [self getSelectedTransitons];
    int totalTransition = [selectedTransitions count];
    int counter=0;

    NSMutableArray *imageArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray *transitionArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray* allImages = [_workSpace.images allObjects];


    
    NSSortDescriptor* desc = [[[NSSortDescriptor alloc] initWithKey:@"imageIndex" ascending:YES] autorelease];
    allImages = [allImages sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
    
    int i = 0;
    NSString* path = nil;
    for (WorkingImage* image in allImages) {
        path = image.imageUrl;
        UIImage* img = [UIImage imageWithContentsOfFile:image.imageUrl];
        [imageArr addObject:img];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
        [dict setObject:[selectedTransitions objectAtIndex:counter] forKey:kKeyTransitionType];
        [dict setObject:[NSNumber numberWithInt:i] forKey:kKeyIndexForTransition];
        [transitionArr addObject:dict];
        i++;
        counter++;
        if (counter>=totalTransition) {
            counter=0;
        }
    }
    ImageToVideo *_imgToVdo = [[ImageToVideo alloc] init];
    _imgToVdo.musicFilePath = _workSpace.trackUrl;
    [_imgToVdo setTransitions:[NSMutableArray arrayWithArray:transitionArr]];
    NSString* destinationPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"vido.mov"];
    [_imgToVdo writeImagesAsMovie:imageArr toPath:destinationPath];

}

- (IBAction)uploadButtonTap:(UIButton *)sender {
    [SCI showDevelopmentAlert];
}

- (IBAction)settingsButtonTap:(UIButton *)sender {
    if (isSettingVisible) {
        isSettingVisible = NO;
        CGRect stillFrame = self.optionView.frame;
        self.infoView.frame = CGRectMake(0, stillFrame.size.height, stillFrame.size.width, stillFrame.size.height);
        [self.optionHolder bringSubviewToFront:self.infoView];
        [UIView animateWithDuration:0.5f animations:^{
            self.infoView.frame = CGRectMake(0, stillFrame.origin.y, stillFrame.size.width, stillFrame.size.height);
            self.optionView.frame = CGRectMake(0, stillFrame.size.height, stillFrame.size.width, stillFrame.size.height);
        }];
    }
    else {
        isSettingVisible = YES;
        CGRect stillFrame = self.infoView.frame;
        self.optionView.frame = CGRectMake(0, stillFrame.size.height, stillFrame.size.width, stillFrame.size.height);
        [self.optionHolder bringSubviewToFront:self.optionView];
        [UIView animateWithDuration:0.5f animations:^{
            self.optionView.frame = CGRectMake(0, stillFrame.origin.y, stillFrame.size.width, stillFrame.size.height);
            self.infoView.frame = CGRectMake(0, stillFrame.size.height, stillFrame.size.width, stillFrame.size.height);
        }];
    }
}

- (IBAction)playButtonTap:(id)sender {
    [self playCompletedVideo];
}
- (void)viewDidUnload {
    [self setInfoView:nil];
    [self setOptionView:nil];
    [self setVideoThumbView:nil];
    [self setOptionHolder:nil];
    [super viewDidUnload];
}

#pragma mark - TableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView setSeparatorColor:[UIColor lightGrayColor]];
    return [settingsOption count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.optionHolder.frame.size.height/4.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    cell.textLabel.text = [settingsOption objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==3) {
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"So UI to select track" object:nil];
    }
    else {
        videoAlreadyMade = NO;
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:indexPath.row] animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

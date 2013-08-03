//
//  STrackSelectorVc.m
//  Sliden
//
//  Created by Amit Priyadarshi on 27/07/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "STrackSelectorVc.h"
#import "SDefaultSlidenCells.h"

@interface STrackSelectorCell : UITableViewCell
@property(nonatomic, retain) UILabel* trackTitle;
@property(nonatomic, assign) UIButton* selectButton;
@property(nonatomic, assign) UIButton* playButton;
@property(nonatomic, retain) UIProgressView* progress;
@end

@implementation STrackSelectorCell

@synthesize trackTitle=_trackTitle;
@synthesize selectButton=_selectButton;
@synthesize playButton=_playButton;
@synthesize progress=_progress;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    
        _trackTitle = [[UILabel alloc] initWithFrame:CGRectMake(47, 11, 175, 20)];
        [_trackTitle setTextAlignment:NSTextAlignmentLeft];
        [_trackTitle setTextColor:RGBA(36, 143, 183, 1.0)];
        [_trackTitle setFont:[UIFont boldSystemFontOfSize:13]];
        [_trackTitle setLineBreakMode:NSLineBreakByTruncatingTail];
        [_trackTitle setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_trackTitle];
        
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setTitle:@"SELECT" forState:UIControlStateNormal];
        [_selectButton setTitle:@"SELECTED" forState:UIControlStateSelected];
        [_selectButton setBackgroundImage:Image(@"blueBtn37.png") forState:UIControlStateNormal];
        [_selectButton setBackgroundImage:Image(@"grabutton37.png") forState:UIControlStateSelected];
        [_selectButton.titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [_selectButton setFrame:CGRectMake(230, 4, 80, 37)];
        [self.contentView addSubview:_selectButton];
        [_selectButton setSelected:NO];

        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setBackgroundImage:Image(@"tracs_play_button.png") forState:UIControlStateNormal];
        [_playButton setFrame:CGRectMake(7, 7, 31, 31)];
        [self.contentView addSubview:_playButton];
        
        _progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        [_progress setTrackTintColor:[UIColor redColor]];
        [_progress setHidden:YES];
        [_progress setFrame:CGRectMake(0, 40, 320, 4)];
        //[self.contentView addSubview:_progress];
        
    }
    return self;
}
@end

@interface STrackSelectorVc ()

@end

@implementation STrackSelectorVc {
    NSMutableArray* _tracks;
    int _selectedSongIndex;
    int _plaingSongIndex;
}
@synthesize allSongs=_allSongs;
@synthesize selectedCategory=_selectedCategory;
@synthesize workSpace = _workSpace;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _tracks = [[NSMutableArray alloc] initWithCapacity:0];
        _selectedSongIndex = -1;
//        for (int i=0; i< 11; i++) {
//            [_tracks addObject:[NSString stringWithFormat:@"party%d.mp3",i+1]];
//        }

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (PFObject* obj in _allSongs) {
        if ([[obj objectForKey:@"cat_name"] isEqualToString:_selectedCategory]) {
            [_tracks addObject:obj];
        }
    }
    [_tableView reloadData];
    
    NSString* folderPath = [CACHE_DIR stringByAppendingPathComponent:_selectedCategory];
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES
                                                   attributes:nil error:nil];
    }
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated {
    self.title = @"Tracks";
}
- (void)viewWillDisappear:(BOOL)animated {
    if (audioPlayer && [audioPlayer isPlaying]) {
        [audioPlayer stop];
        sRelease(audioPlayer);
    }
    if (_selectedSongIndex != -1) {
        PFObject* song = [_tracks objectAtIndex:_selectedSongIndex];
        NSString* filePath = [[CACHE_DIR stringByAppendingPathComponent:_selectedCategory] stringByAppendingPathComponent:[song objectForKey:@"track_name"]];
        if (![_workSpace.trackUrl isEqualToString:filePath])
            _workSpace.isAnyChange = [NSNumber numberWithInt:([_workSpace.isAnyChange integerValue] | WorkSpaceChangedInSongsSelection)];
        _workSpace.trackUrl = filePath;
        [APP_DELEGATE saveContext];
    }
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
- (void)songSelected:(UIButton*)sender {
    PFObject* song = [_tracks objectAtIndex:sender.tag];
    NSString* filePath = [[CACHE_DIR stringByAppendingPathComponent:_selectedCategory] stringByAppendingPathComponent:[song objectForKey:@"track_name"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        _selectedSongIndex = sender.tag;
        NSArray* visibleCells = [_tableView visibleCells];
        for (STrackSelectorCell* cell in visibleCells) {
            [cell.selectButton setSelected:NO];
        }
        [sender setSelected:YES];
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Sliden" message:@"Track selected successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Choose Other", nil] autorelease];
        [alert show];
    }
    else {
        //download file
        [APP_DELEGATE showLockScreenStatusWithMessage:@"Downloading music file."];
        PFFile* songFile = [song objectForKey:@"music_file"];
        [APP_DELEGATE showActivity:YES];
        [songFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [data writeToFile:filePath atomically:YES];
            _selectedSongIndex = sender.tag;
            NSArray* visibleCells = [_tableView visibleCells];
            for (STrackSelectorCell* cell in visibleCells) {
                [cell.selectButton setSelected:NO];
            }
            [sender setSelected:YES];
            [APP_DELEGATE showActivity:NO];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Sliden" message:@"Track selected successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Choose Other", nil] autorelease];
            [alert show];
        } progressBlock:^(int percentDone) {
            [APP_DELEGATE setLockScreenProgress:percentDone/100.0f];
        }];
    }
}
- (void)playSong:(UIButton*)sender {
    PFObject* song = [_tracks objectAtIndex:sender.tag];
    NSString* filePath = [[CACHE_DIR stringByAppendingPathComponent:_selectedCategory] stringByAppendingPathComponent:[song objectForKey:@"track_name"]];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        NSError *error;
        if (audioPlayer) {
            [audioPlayer stop];
            sRelease(audioPlayer);
        }
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        audioPlayer.numberOfLoops = 0;
        
        if (audioPlayer == nil)
            NSLog(@"%@",[error description]);
        else
            [audioPlayer play];
    }
    else {
        //download file
        PFFile* songFile = [song objectForKey:@"music_file"];
        [APP_DELEGATE showActivity:YES];
        [APP_DELEGATE showLockScreenStatusWithMessage:@"Downloading music file."];
        [songFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [data writeToFile:filePath atomically:YES];
            if (audioPlayer) {
                [audioPlayer stop];
                sRelease(audioPlayer);
            }
            audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
            audioPlayer.numberOfLoops = 0;
            
            if (audioPlayer == nil)
                NSLog(@"%@",[error description]);
            else
                [audioPlayer play];
            [APP_DELEGATE showActivity:NO];
        } progressBlock:^(int percentDone) {
            [APP_DELEGATE setLockScreenProgress:percentDone/100.0f];
        }];
    }
}
#pragma mark - TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tracks count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    STrackSelectorCell* cell = (STrackSelectorCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[STrackSelectorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.selectButton addTarget:self action:@selector(songSelected:) forControlEvents:UIControlEventTouchUpInside];
        [cell.playButton addTarget:self action:@selector(playSong:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.selectButton.tag = indexPath.row;
    cell.playButton.tag = indexPath.row;
    [cell.selectButton setSelected:(_selectedSongIndex == indexPath.row)];
    PFObject* song = [_tracks objectAtIndex:indexPath.row];
    cell.trackTitle.text = [song objectForKey:@"track_name"];
    return cell;
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    PFObject* newSong = [PFObject objectWithClassName:@"MusicCat"];
//    [newSong setValue:@"NRJ Party Hits" forKey:@"cat_name"];
//    
//    NSString* trackName = [_tracks objectAtIndex:indexPath.row];
//    NSData* data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[trackName stringByDeletingPathExtension] ofType:@"mp3"]];
//    PFFile* file = [PFFile fileWithName:trackName data:data];
//    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            NSLog(@"Done saving file for %@",trackName);
//        }
//        else {
//            NSLog(@"Error saving file for %@",error);
//        }
//    }];
//    [newSong setValue:trackName forKey:@"track_name"];
//    [newSong setValue:file forKey:@"music_file"];
//    [newSong saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            NSLog(@"Done saving metadata for %@",trackName);
//        }
//        else {
//            NSLog(@"Error saving metadata for %@",error);
//        }
//    }];
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView cancelButtonIndex]==buttonIndex) {
        int count = [[self.navigationController viewControllers] count];
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:count-3] animated:YES];
    }
}
@end

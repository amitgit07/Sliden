//
//  ImageToVideo.m
//  PicToVideo
//
//  Created by prem prakash on 6/16/13.
//  Copyright (c) 2013 prem prakash. All rights reserved.
//

#import "ImageToVideo.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#include <math.h>
#import <QuartzCore/CATransform3D.h>
#import "CALayer+DTUIKitAdditions.h"


NSString * const kKeyTransitionType = @"TransitionType";
NSString * const kKeyIndexForTransition =  @"IndexForTransition";
NSString * const kKeyTrackID = @"TrackID";
NSString * const kNotificationVideoConversionStarted = @"VideoConversionStartedNotification";
NSString * const kNotificationVideoConversionFinished = @"VideoConversionCompletedNotification";

#define EXPORT_QUALITY AVAssetExportPresetMediumQuality  // Other Options AVAssetExportPresetHighestQuality,AVAssetExportPresetLowQuality


#define RADIANS(degree)  (degree * M_PI / 180)
#define MINIMUM_TIME_PER_IMAGE 3
#define ANIMATION_TIME 1.0f
#define BufferTime 0.5

#define DOCUMENT_DIR [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define TEMP_PATH [CACHE_DIR stringByAppendingPathComponent:@"temp.mov"]


@implementation ImageToVideo {
    AVAssetExportSession* _assetExport;
}
@synthesize allImages = _allImages;
@synthesize timePerImage = _timePerImage;
@synthesize transitions = _transitions;
@synthesize musicFilePath=_musicFilePath;
@synthesize progressTracker=_progressTracker;

-(id)init {
    self = [super init];
    if(self) {
        /**
         Allocate an array to store all Images for Video
         */
        _allImages = [[NSMutableArray alloc] initWithCapacity:0];
        
        
        /**
         Allocate an array to store all Transitions in video
         */
        _transitions = [[NSMutableArray alloc] initWithCapacity:0];
        
        /**
         Initiate Parent Layer & Video Layer for video. We will be adding layers on video layer to make transitions
         */
        parentLayer = [[CALayer layer] retain];
        videoLayer = [[CALayer layer] retain];
        [parentLayer addSublayer:videoLayer];
        _timePerImage = MINIMUM_TIME_PER_IMAGE;
    }
    return self;
}

/**
 Time Per Images has a minmimum value, defined on the top of this class
 */
-(void)setTimePerImage:(NSTimeInterval)timePerImage {
    if(timePerImage < MINIMUM_TIME_PER_IMAGE)
        _timePerImage = MINIMUM_TIME_PER_IMAGE;
    else
        _timePerImage = timePerImage;
}

-(NSTimeInterval)timePerImage {
    return _timePerImage;
}


/**
 For Fade animations, we have added a layer, which will be shown slowly required timestamp and then it will slowly dissolve. So we need two animations
 */
-(void)addFadeAnimationToLayer:(CALayer*)aLayer forAnimationAfterDelay:(NSTimeInterval)delay {
    /**
     On Layer we take Image for the next frame and animate it. this is done in such a way that after completion of transition, next image is shown on video(the same image which was being animated)
     */
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.additive = NO;
    fadeAnimation.removedOnCompletion = NO;
    fadeAnimation.beginTime = delay - ANIMATION_TIME;
    fadeAnimation.duration = ANIMATION_TIME;
    fadeAnimation.fillMode = kCAFillModeBoth;
    [aLayer addAnimation:fadeAnimation forKey:@"showAnimation"];
    
    
    /**
     Once transition complete, hide the layer
     */
    CABasicAnimation *fadeAnimation_ = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation_.toValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation_.additive = NO;
    fadeAnimation_.removedOnCompletion = NO;
    fadeAnimation_.beginTime = delay+0.1;
    fadeAnimation_.duration = BufferTime;
    fadeAnimation_.fillMode = kCAFillModeBoth;
    [aLayer addAnimation:fadeAnimation_ forKey:@"hideAnimation"];
}

-(void)addFlipAnimationFromLayer:(CALayer*)aLayer fromLayer:(CALayer*)fromLayer WithFlipType:(TransistionType)_transitionType forAnimationAfterDelay:(NSTimeInterval)delay  {
    
    /**
     Need to hide video at the time of Transition, so we have added one more layer over the superlayer and its opacity is set at the time of animation
     */
    CALayer *blackLayer = [CALayer layer];
    blackLayer.frame = CGRectMake(0, 0, CGRectGetWidth(aLayer.frame), CGRectGetHeight(aLayer.frame));
    blackLayer.bounds = CGRectMake(0, 0, CGRectGetWidth(aLayer.frame), CGRectGetHeight(aLayer.frame));
    blackLayer.backgroundColor = [[UIColor blackColor] CGColor];
    blackLayer.geometryFlipped = YES;
    blackLayer.opacity = 0;
    // This is required otherwise at the time of flip half of the layer will go behind it. We have just pushed layer in negative Z axis so  layer will not intersect while fliping
    
    blackLayer.transform = CATransform3DMakeTranslation(0, 0,-MAX(CGRectGetHeight(aLayer.frame), CGRectGetWidth(aLayer.frame)));
    [aLayer.superlayer insertSublayer:blackLayer below:aLayer];
    
    
    /**
     Create show animation for animation layers
     */
    CABasicAnimation *showAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    showAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    showAnimation.toValue = [NSNumber numberWithFloat:1.0];
    showAnimation.additive = NO;
    showAnimation.removedOnCompletion = NO;
    showAnimation.beginTime = delay;
    showAnimation.duration = 0.01;
    showAnimation.fillMode = kCAFillModeBoth;
    // Show all layers
    [aLayer addAnimation:showAnimation forKey:@"showAnimation"];
    [fromLayer addAnimation:showAnimation forKey:@"showAnimation"];
    [blackLayer addAnimation:showAnimation forKey:@"showAnimation"];

    /**
     Direction for flip
     */
    DTCALayerFlipAnimationDirection direction;
    switch (_transitionType) {
        case kTransitionTypeFlipFromLeft:
            direction = DTCALayerFlipAnimationDirectionFromLeft;
            
            break;
        case kTransitionTypeFlipFromRight:
            direction = DTCALayerFlipAnimationDirectionFromRight;
            break;
        case kTransitionTypeFlipFromTop:
            direction = DTCALayerFlipAnimationDirectionFromTop;
            break;
        case kTransitionTypeFlipFromBottom:
            direction = DTCALayerFlipAnimationDirectionFromBottom;
            break;
        default:
            direction = DTCALayerFlipAnimationDirectionFromLeft;
            break;
    }
    
    /**
     Flip the layer
     */
    [aLayer flipToLayer:fromLayer withDuration:ANIMATION_TIME direction:direction afterDelay:delay completion:^{
        
    }];
    
    
    /**
     Hide the layers after transition is completed
     */
    CABasicAnimation *hideAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    hideAnimation.toValue = [NSNumber numberWithFloat:0.0];
    hideAnimation.additive = NO;
    hideAnimation.removedOnCompletion = NO;
    hideAnimation.beginTime = delay+ANIMATION_TIME;
    hideAnimation.duration = 0.01;
    hideAnimation.fillMode = kCAFillModeBoth;
    [aLayer addAnimation:hideAnimation forKey:@"hideAnimation"];
    [fromLayer addAnimation:hideAnimation forKey:@"hideAnimation"];
    [blackLayer addAnimation:hideAnimation forKey:@"hideAnimation"];
}


-(void)addExitTransitionForLayer:(CALayer*)aLayer fromLayer:(CALayer*)fromLayer WithType:(TransistionType)_transitionType forAnimationAfterDelay:(int64_t)delay {
    
    /**
     Show the required layer at timeinterval
     */
    CABasicAnimation *showAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    showAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    showAnimation.toValue = [NSNumber numberWithFloat:1.0];
    showAnimation.additive = NO;
    showAnimation.removedOnCompletion = NO;
    showAnimation.beginTime = delay-BufferTime;
    showAnimation.duration = BufferTime;
    showAnimation.fillMode = kCAFillModeBoth;
    [fromLayer addAnimation:showAnimation forKey:@"showAnimation"];
    
    
    CABasicAnimation *moveOutTransform = [CABasicAnimation animationWithKeyPath:@"position"];
    //Set final position of Layer for transition
    switch (_transitionType) {
        case kTransitionTypeExitToLeft:
            moveOutTransform.toValue    = [NSValue valueWithCGPoint:CGPointMake(-CGRectGetWidth(fromLayer.frame), 0)];
            break;
        case kTransitionTypeExitToRight:
            moveOutTransform.toValue    = [NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(fromLayer.frame), 0)];
            break;
        case kTransitionTypeExitToTop:
            moveOutTransform.toValue    = [NSValue valueWithCGPoint:CGPointMake(0, CGRectGetHeight(fromLayer.frame))];
            break;
        case kTransitionTypeExitToBottom:
            moveOutTransform.toValue = [NSValue valueWithCGPoint:CGPointMake(0, -CGRectGetHeight(fromLayer.frame))];
            break;
        default:
            break;
    }
    
    moveOutTransform.duration   = ANIMATION_TIME;
    moveOutTransform.beginTime = delay;
    moveOutTransform.removedOnCompletion = NO;
    moveOutTransform.fillMode = kCAFillModeBoth;
    moveOutTransform.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [fromLayer addAnimation:moveOutTransform forKey:@"MoveOut"];
    
    /**
     Hide the layers after transition is completed
     */
    CABasicAnimation *hideAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    hideAnimation.toValue = [NSNumber numberWithFloat:0.0];
    hideAnimation.additive = NO;
    hideAnimation.removedOnCompletion = NO;
    hideAnimation.beginTime = delay+ANIMATION_TIME;
    hideAnimation.duration = BufferTime;
    hideAnimation.fillMode = kCAFillModeBoth;
    [fromLayer addAnimation:hideAnimation forKey:@"hideAnimation"];
}

-(void)addEnterTransitionForLayer:(CALayer*)aLayer fromLayer:(CALayer*)fromLayer WithType:(TransistionType)_transitionType forAnimationAfterDelay:(int64_t)delay {
    /**
     Create show animation for animation layers
     */
    CABasicAnimation *showAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    showAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    showAnimation.toValue = [NSNumber numberWithFloat:1.0];
    showAnimation.additive = NO;
    showAnimation.removedOnCompletion = NO;
    showAnimation.beginTime = delay-BufferTime;
    showAnimation.duration = 0.01;
    showAnimation.fillMode = kCAFillModeBoth;
    [aLayer setAnchorPoint:CGPointMake(0, 0)];
    [aLayer addAnimation:showAnimation forKey:@"showAnimation"];
    
    // All the layers will move to origin, previous positions are set accroding to transtions required
    CABasicAnimation *moveInTransform = [CABasicAnimation animationWithKeyPath:@"position"];
    moveInTransform.toValue    = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
    moveInTransform.duration   = ANIMATION_TIME;
    moveInTransform.beginTime = delay-ANIMATION_TIME;
    moveInTransform.removedOnCompletion = NO;
    moveInTransform.fillMode = kCAFillModeBoth;
    moveInTransform.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [aLayer addAnimation:moveInTransform forKey:@"MoveIn"];
    
//    /**
//     Hide the layers which was there previously
//     */
//    CABasicAnimation *hideAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    hideAnimation.toValue = [NSNumber numberWithFloat:0.0];
//    hideAnimation.additive = NO;
//    hideAnimation.removedOnCompletion = NO;
//    hideAnimation.beginTime = delay;
//    hideAnimation.duration = BufferTime;
//    hideAnimation.fillMode = kCAFillModeBoth;
//    [fromLayer addAnimation:hideAnimation forKey:@"hideAnimation"];
}


-(void)addTransitionType:(TransistionType)_transitionType forImageIndex:(NSInteger)indexOfImage forVideoComposition:
(AVMutableVideoComposition*)videoComposition andTrackID:(NSInteger)trackID {

    // Time Interval when the image at that index will be shown
    int64_t time = (indexOfImage)*_timePerImage ;
    
    // Get two images required for animations
    UIImage *image = [_allImages objectAtIndex:(indexOfImage)];
    UIImage *prevImage = nil;
    if(indexOfImage != 0)
       prevImage = [_allImages objectAtIndex:(indexOfImage-1)];
    
    
    // Set Frames
    parentLayer.frame = CGRectMake(0, 0, videoDimension.width, videoDimension.height);
    videoLayer.frame = CGRectMake(0, 0, videoDimension.width, videoDimension.height);
    
    // Add two layers for transitions
    CALayer *aLayer = [CALayer layer];
    aLayer.frame = CGRectMake(0, 0, CGRectGetWidth(videoLayer.frame), CGRectGetHeight(videoLayer.frame));
    aLayer.bounds = CGRectMake(0, 0, CGRectGetWidth(videoLayer.frame), CGRectGetHeight(videoLayer.frame));
    aLayer.contents = (id) image.CGImage;
    aLayer.geometryFlipped = YES;
    aLayer.opacity = 0;
    
    CALayer *fromLayer = [CALayer layer];
    fromLayer.frame = CGRectMake(0, 0, CGRectGetWidth(videoLayer.frame), CGRectGetHeight(videoLayer.frame));
    fromLayer.bounds = CGRectMake(0, 0, CGRectGetWidth(videoLayer.frame), CGRectGetHeight(videoLayer.frame));
    fromLayer.contents = (id)prevImage.CGImage;
    fromLayer.geometryFlipped = YES;
    fromLayer.opacity = 0;
    
    switch (_transitionType) {
        case kTransitionTypeNone:
            break;
        case kTransitionTypeFade:
            [videoLayer addSublayer:aLayer];
            [self addFadeAnimationToLayer:aLayer forAnimationAfterDelay:time];
            break;
        case kTransitionTypeEnterFromLeft:
            [aLayer setAnchorPoint:CGPointMake(0, 0)];
            [aLayer setFrame:CGRectMake(-CGRectGetWidth(aLayer.frame), 0, CGRectGetWidth(aLayer.frame), CGRectGetHeight(aLayer.frame))];
//            [videoLayer addSublayer:fromLayer];
            [videoLayer addSublayer:aLayer];
            [self addEnterTransitionForLayer:aLayer fromLayer:fromLayer WithType:_transitionType forAnimationAfterDelay:time];
            break;
        case kTransitionTypeEnterFromRight:
            [aLayer setAnchorPoint:CGPointMake(0, 0)];
            [aLayer setFrame:CGRectMake(CGRectGetWidth(aLayer.frame), 0, CGRectGetWidth(aLayer.frame), CGRectGetHeight(aLayer.frame))];
//            [videoLayer addSublayer:fromLayer];
            [videoLayer addSublayer:aLayer];
            [self addEnterTransitionForLayer:aLayer fromLayer:fromLayer WithType:_transitionType forAnimationAfterDelay:time];
            break;
        case kTransitionTypeEnterFromTop:
            [aLayer setAnchorPoint:CGPointMake(0, 0)];
            [aLayer setFrame:CGRectMake(0, CGRectGetHeight(aLayer.frame), CGRectGetWidth(aLayer.frame), CGRectGetHeight(aLayer.frame))];
//            [videoLayer addSublayer:fromLayer];
            [videoLayer addSublayer:aLayer];
            [self addEnterTransitionForLayer:aLayer fromLayer:fromLayer WithType:_transitionType forAnimationAfterDelay:time];
            break;
        case kTransitionTypeEnterFromBottom:
            [aLayer setAnchorPoint:CGPointMake(0, 0)];
            [aLayer setFrame:CGRectMake(0, -CGRectGetHeight(aLayer.frame), CGRectGetWidth(aLayer.frame), CGRectGetHeight(aLayer.frame))];
//            [videoLayer addSublayer:fromLayer];
            [videoLayer addSublayer:aLayer];
            [self addEnterTransitionForLayer:aLayer fromLayer:fromLayer WithType:_transitionType forAnimationAfterDelay:time];
            break;
            
        case kTransitionTypeExitToLeft:
        case kTransitionTypeExitToRight:
        case kTransitionTypeExitToTop:
        case kTransitionTypeExitToBottom:
            [videoLayer addSublayer:aLayer];
            [fromLayer setAnchorPoint:CGPointMake(0, 0)];
            fromLayer.frame = CGRectMake(0, 0, CGRectGetWidth(fromLayer.frame), CGRectGetHeight(fromLayer.frame));
            fromLayer.bounds = CGRectMake(0, 0, CGRectGetWidth(fromLayer.frame), CGRectGetHeight(fromLayer.frame));
            [videoLayer addSublayer:fromLayer];
            [self addExitTransitionForLayer:aLayer fromLayer:fromLayer WithType:_transitionType forAnimationAfterDelay:time];
            break;
            
            
        case kTransitionTypeFlipFromLeft:
        case kTransitionTypeFlipFromRight:
        case kTransitionTypeFlipFromTop:
        case kTransitionTypeFlipFromBottom:
            [videoLayer addSublayer:aLayer];
            [videoLayer addSublayer:fromLayer];
            [self addFlipAnimationFromLayer:aLayer fromLayer:fromLayer WithFlipType:_transitionType forAnimationAfterDelay:time];
            break;
        case kTransitionTypeCurlUp:
            // Not Implemented Yet
            break;
            
        case kTransitionTypeCurlDown:
            // Not Implemented Yet
            break;
            
        default:
            break;
    }
    
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithAdditionalLayer:aLayer asTrackID:trackID];
    
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}


-(void)configureVideoForTransistions:(NSArray*)_transitionList forVideoComposition:(AVMutableVideoComposition*)videoComposition  {
    for (NSDictionary *transitionDict in _transitionList) {
        TransistionType _transitionType = [[transitionDict objectForKey:kKeyTransitionType] integerValue];
        NSInteger indexOfImage = [[transitionDict objectForKey:kKeyIndexForTransition] integerValue];
        NSInteger trackID = [[transitionDict objectForKey:kKeyTrackID] integerValue]+ [_transitions indexOfObject:transitionDict];
        [self addTransitionType:_transitionType forImageIndex:indexOfImage forVideoComposition:videoComposition andTrackID:trackID];
    }
}

- (void)updateProgress {
    [APP_DELEGATE setLockScreenProgress:_assetExport.progress];
}
/**
 After Images has been converted to video, add transitions and save to destination path
 */
-(void)addTransitionsOnVideoAnsSaveToPath:(NSString*)destinationPath {
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVURLAsset* a_videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:TEMP_PATH] options:nil];
    CMTimeRange a_timeRange = CMTimeRangeMake(kCMTimeZero,a_videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray* v_tracks = [a_videoAsset tracksWithMediaType:AVMediaTypeVideo];

    [a_compositionVideoTrack insertTimeRange:a_timeRange ofTrack:([v_tracks count]>0)?[v_tracks objectAtIndex:0]:nil atTime:a_timeRange.start error:nil];
    

    if (_musicFilePath && [_musicFilePath length] > 5) {
        NSURL* path = [NSURL fileURLWithPath:_musicFilePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_musicFilePath]) {
            AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:path options:nil];
            
            AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
            NSArray* a_tracks = [audioAsset tracksWithMediaType:AVMediaTypeAudio];
            [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
                                                ofTrack:([a_tracks count]>0)?[a_tracks objectAtIndex:0]:nil
                                                 atTime:kCMTimeZero error:nil];
            
            float videoTime_s = CMTimeGetSeconds(a_videoAsset.duration);
            float audioTime_s = CMTimeGetSeconds(audioAsset.duration);
            if(videoTime_s > audioTime_s)
            {
                int numberOfLoop = ceil(videoTime_s/audioTime_s);
                for (int i = 1; i < numberOfLoop; i++) {
                    CMTime duration = CMTimeMakeWithSeconds(i*audioTime_s, audioAsset.duration.timescale);
                    if (CMTIME_IS_VALID(duration))
                    {
                        
                        CMTimeRange video_timeRange2 = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
                        //start from where left
                        CMTime nextClipStartTime2 = CMTimeMake(audioTime_s*i, audioAsset.duration.timescale);
                        //add in AVMutableCompositionTrack
                        [compositionCommentaryTrack insertTimeRange:video_timeRange2
                                                         ofTrack:([a_tracks count]>0)?[a_tracks objectAtIndex:0]:nil
                                                          atTime:nextClipStartTime2 error:nil];
                    }
                    else
                        NSLog(@"time is invalid");
                }
            }
                //new time range
        }
    }
    AVMutableVideoCompositionLayerInstruction * firstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:([v_tracks count]>0)?[v_tracks objectAtIndex:0]:nil];

    
    AVMutableVideoCompositionInstruction * instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration);
    instruction.layerInstructions = [NSArray arrayWithObjects:firstlayerInstruction, nil];
    
    
    AVMutableVideoComposition * videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.instructions = [NSArray arrayWithObject:instruction];
    [videoComp setRenderSize:videoDimension];
    [videoComp setFrameDuration:CMTimeMake(1, 30)];
    
    for (NSMutableDictionary *dict in _transitions) {
        [dict setObject:[NSNumber numberWithInt:[a_videoAsset unusedTrackID]] forKey:kKeyTrackID];
    }
    
    // Add Layer & Transistions
    [self configureVideoForTransistions:_transitions forVideoComposition:videoComp];

    NSURL *outputFileUrl = [NSURL fileURLWithPath:destinationPath];
    
    _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:EXPORT_QUALITY];
    _assetExport.videoComposition = videoComp;
    _assetExport.outputFileType = AVFileTypeMPEG4;
    _assetExport.outputURL = outputFileUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationVideoConversionFinished object:[NSNumber numberWithInt:_assetExport.status]];
         if (_progressTracker && [_progressTracker isValid]) {
             [_progressTracker invalidate];
             _progressTracker = nil;
         }
         switch (_assetExport.status)
         {
             case AVAssetExportSessionStatusFailed:
             {
                 NSError *exportError = _assetExport.error;
                 NSLog(@"Export Error : %@",exportError);
//                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationVideoConversionFinished object:exportError];
                 break;
             }
             case AVAssetExportSessionStatusCompleted:
             {
                 NSLog(@"Completed");
//                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationVideoConversionFinished object:@"Completed"];
                 break;
             }
             case AVAssetExportSessionStatusUnknown:
             {
                 NSLog(@"AVAssetExportSessionStatusUnknown");
//                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationVideoConversionFinished object:@"Unknown"];
                 break;
             }
             case AVAssetExportSessionStatusExporting:
             {
                 
                 NSLog(@"AVAssetExportSessionStatusExporting");
//                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationVideoConversionFinished object:@"Exporting"];
                 break;
             }
             case AVAssetExportSessionStatusCancelled:
             {
//                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationVideoConversionFinished object:@"Cancelled"];
                 NSLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             }
             case AVAssetExportSessionStatusWaiting:
             {
//                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationVideoConversionFinished object:@"Waiting"];
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             }
             default:
             {
//                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationVideoConversionFinished object:@"Could not get export status"];
                 NSLog(@"didn't get export status");
                 break;
             }
         };
     }
     ];
    
}

/**
 If file exists on that path, remove it
 */
-(BOOL)tryRemovingOlderFileOnPath:(NSString*)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    if([fileManager fileExistsAtPath:TEMP_PATH])
        [fileManager removeItemAtPath:TEMP_PATH error:&error];
    
    if([fileManager fileExistsAtPath:path])
        [fileManager removeItemAtPath:path error:&error];
    
    if(error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your request was not processed. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return NO;
    }
    else
        return YES;
    
}


- (void) writeImagesAsMovie:(NSArray *)ImageArray toPath:(NSString*)path
{
    if([self tryRemovingOlderFileOnPath:path])
    {
        _progressTracker=[NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];

        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationVideoConversionStarted object:nil];
        NSMutableArray *array = [NSMutableArray arrayWithArray:ImageArray];
        [self.allImages addObjectsFromArray:array];
        
        UIImage *first = [array objectAtIndex:0];
        videoDimension = first.size;
        
        NSError *error = nil;
        AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                      [NSURL fileURLWithPath:TEMP_PATH] fileType:AVFileTypeQuickTimeMovie
                                                                  error:&error];
        
        if(error) {
            NSLog(@"error creating AssetWriter: %@",[error description]);
        }
        NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       AVVideoCodecH264, AVVideoCodecKey,
                                       [NSNumber numberWithInt:videoDimension.width], AVVideoWidthKey,
                                       [NSNumber numberWithInt:videoDimension.height], AVVideoHeightKey,
                                       nil];
        
        
        
        AVAssetWriterInput* writerInput = [[AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings] retain];
        
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        [attributes setObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
        [attributes setObject:[NSNumber numberWithUnsignedInt:videoDimension.width] forKey:(NSString*)kCVPixelBufferWidthKey];
        [attributes setObject:[NSNumber numberWithUnsignedInt:videoDimension.height] forKey:(NSString*)kCVPixelBufferHeightKey];
        
        AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                         assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                         sourcePixelBufferAttributes:attributes];
        
        [videoWriter addInput:writerInput];
        
        // fixes all errors
        writerInput.expectsMediaDataInRealTime = YES;
        
        //Start a session:
        [videoWriter startWriting];
        
        [videoWriter startSessionAtSourceTime:kCMTimeZero];
        
        CVPixelBufferRef buffer = NULL;
        buffer = [self pixelBufferFromCGImage:[first CGImage] size:videoDimension];
        BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:kCMTimeZero];
        
        if (result == NO)
            NSLog(@"failed to append buffer");
        
        if(buffer) {
            CVBufferRelease(buffer);
        }
        
        int i = 0;
        
        /**
         Remove first Image as it has been added to buffer
         */
        if([array count])
            [array removeObjectAtIndex:0];
        
        /**
         Add other images in buffer
         */
        for (UIImage *imgFrame in array)
        {
            if (adaptor.assetWriterInput.readyForMoreMediaData) {
                CMTime frameTime = CMTimeMake(_timePerImage, 1);
                CMTime lastTime = CMTimeMake(_timePerImage*i, 1);
                CMTime presentTime = CMTimeAdd(lastTime, frameTime);
                                
                buffer = [self pixelBufferFromCGImage:[imgFrame CGImage] size:videoDimension];
                BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
                
                if (result == NO) //failes on 3GS, but works on iphone 4
                {
                    NSLog(@"failed to append buffer");
                    NSLog(@"The error is %@", [videoWriter error]);
                }
                
                if(buffer) {
                    CVBufferRelease(buffer);
                }
                
                i++;
                sleep(0.2); // Just to avoid some cases of error
            } else {
                NSLog(@"error %d",i);
                i--;
            }
            
        }
        
        //Finish the session:
        [writerInput markAsFinished];
        [videoWriter finishWritingWithCompletionHandler:^{
            NSLog(@"Movie created successfully");
            [self addTransitionsOnVideoAnsSaveToPath:path];
        }];
        
        CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
        [videoWriter release];
        [writerInput release];
    }
}


- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image size:(CGSize) size{
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width,
                                          size.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    CGContextDrawImage(context, CGRectMake(0, 0, size.width,
                                           size.height), image);
    
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}


@end

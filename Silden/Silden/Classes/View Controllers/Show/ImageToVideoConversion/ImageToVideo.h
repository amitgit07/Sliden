//
//  ImageToVideo.h
//  PicToVideo
//
//  Created by prem prakash on 6/16/13.
//  Copyright (c) 2013 prem prakash. All rights reserved.
//

#import <Foundation/Foundation.h>



extern NSString * const kKeyTransitionType;
extern NSString * const kKeyIndexForTransition;
extern NSString * const kKeyTrackID;
extern NSString * const kNotificationVideoConversionStarted;
extern NSString * const kNotificationVideoConversionFinished;


typedef enum {
    kTransitionTypeFade,
    kTransitionTypeEnterFromLeft,
    kTransitionTypeEnterFromRight,
    kTransitionTypeEnterFromTop,
    kTransitionTypeEnterFromBottom,
    kTransitionTypeExitToLeft,
    kTransitionTypeExitToRight,
    kTransitionTypeExitToTop,
    kTransitionTypeExitToBottom,
    kTransitionTypeFlipFromLeft,
    kTransitionTypeFlipFromRight,
    kTransitionTypeFlipFromTop,
    kTransitionTypeFlipFromBottom,
    kTransitionTypeCurlUp,
    kTransitionTypeCurlDown,
    kTransitionTypeNone
} TransistionType;

@interface ImageToVideo : NSObject {
    float delta;
    CALayer *parentLayer;
    CALayer *videoLayer;
    CGSize videoDimension;
    
}

@property(nonatomic,retain) NSMutableArray *allImages;
@property(nonatomic,retain) NSMutableArray *transitions;
@property(nonatomic) NSTimeInterval timePerImage;


- (void) writeImagesAsMovie:(NSArray *)array toPath:(NSString*)path;
//-(void)writeImageAsMovie:(NSArray *)array toPath:(NSString*)path size:(CGSize)size duration:(int)duration;
@end

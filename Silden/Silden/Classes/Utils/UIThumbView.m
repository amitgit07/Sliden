//
//  UIThumbView.m
//  DaCentrale
//
//  Created by Amit Priyadarshi on 20/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIThumbView.h"

#define ServerImageUrl  @"ServerUrl"
#define LocalImageUrl   @"LocalUrl"
#define ImageUrlMap     @"Local-Server image map"

@interface UIThumbView()
- (void)didTap:(UIButton*)sender;
@end

@implementation UIThumbView
@synthesize uniqueIdentifire;
@synthesize tapDelegate;
@synthesize imageType;
@synthesize imageUrlString;
@synthesize defaultImage;
@synthesize activity;
static NSMutableSet* allActiveRequsetUrl;
static NSMutableDictionary *allActiveRequestURLAndObjects;

+ (void)clearBuffer {
	NSString* docDirectory = [DOC_DIR stringByAppendingPathComponent:BaseBufferFolder];
	NSFileManager* fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:docDirectory])
	{
		[fm removeItemAtPath:docDirectory error:nil];
	}
}
+ (void)clearBufferOfImageType:(NSString*)type {
	NSString* docDirectory = [DOC_DIR stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",BaseBufferFolder,type]];
	NSFileManager* fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:docDirectory])
	{
		[fm removeItemAtPath:docDirectory error:nil];
	}
}
- (void)dealloc {
    SafeRelease(activity);
    //    CheckAndRelease(allActiveRequestURLAndObjects);
    //    CheckAndRelease(allActiveRequsetUrl);
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (!allActiveRequsetUrl) {
                allActiveRequsetUrl = [[NSMutableSet alloc] init];
            }
            if(!allActiveRequestURLAndObjects)
            {
                allActiveRequestURLAndObjects =[[NSMutableDictionary alloc] init];
            }
        });
        [self setContentMode:UIViewContentModeScaleAspectFit];
        
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activity setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
        [activity setHidesWhenStopped:YES];
        [self addSubview:activity];
        
        NSFileManager* fm = [NSFileManager defaultManager];
        NSString* thumbDocPath;
        thumbDocPath = [DOC_DIR stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",BaseBufferFolder,NoTypeFolder]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:thumbDocPath]) 
        {
            NSError* err = nil;
            [fm createDirectoryAtPath:thumbDocPath withIntermediateDirectories:YES attributes:nil error:&err];
            if (err)
                NSLog(@"%s:%@",__FUNCTION__,err);
        }
    }
    return self;
}
- (void)didTap:(UIButton*)sender {
    if (self.tapDelegate && [self.tapDelegate respondsToSelector:@selector(didTapOnImageView:)]) {
        [self.tapDelegate didTapOnImageView:self];
    }
}
- (void)addTapReceiver {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [button setFrame:self.frame];
    [button setFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height)];
    [button setAutoresizingMask:63];
    [self addSubview:button];
    [button addTarget:self action:@selector(didTap:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)setImageType:(NSString *)imageTyp {
    if (imageType != imageTyp) {
        CheckAndRelease(imageType);
        imageType = [imageTyp retain];
    }
    NSFileManager* fm = [NSFileManager defaultManager];
	NSString* thumbDocPath;
	thumbDocPath = [DOC_DIR stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",BaseBufferFolder,imageTyp]];
	if (![[NSFileManager defaultManager] fileExistsAtPath:thumbDocPath]) 
	{
		NSError* err = nil;
		[fm createDirectoryAtPath:thumbDocPath withIntermediateDirectories:YES attributes:nil error:&err];
		if (err)
			NSLog(@"%s:%@",__FUNCTION__,err);
	}
}
- (void)imageDownloadedFromUrl:(NSString*)urlStr {
    if ([self.imageUrlString isEqualToString:urlStr]) {
        [allActiveRequsetUrl removeObject:urlStr];
        NSArray* pathComponents = [urlStr pathComponents];
        NSString* finalPath = nil;
        if ([pathComponents count] > 2) {
            NSArray* lastTwoArray = [pathComponents subarrayWithRange:NSMakeRange([pathComponents count]-2,2)];
            finalPath = [NSString stringWithFormat:@"%@_%@",lastTwoArray[0],lastTwoArray[1]];
        }
        
        NSFileManager* fm = [NSFileManager defaultManager];
        NSString* localPath = [NSString stringWithFormat:@"%@/%@/%@/%@",DOC_DIR,BaseBufferFolder,
                               (([self.imageType length])?self.imageType:NoTypeFolder),
                               finalPath];
        if ([fm fileExistsAtPath:localPath]) {
            NSData* data = [NSData dataWithContentsOfFile:localPath];
            UIImage* image = nil;
            if ([data length] > 100) 
                image = [UIImage imageWithContentsOfFile:localPath];
            else
            {
                image = self.defaultImage;
                NSError* err = nil;
                [fm removeItemAtPath:localPath error:&err];
                if (err)
                    NSLog(@"%s:%@",__FUNCTION__,err);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                for(UIThumbView *view in [allActiveRequestURLAndObjects objectForKey:urlStr])
                {
                    [view setImage:image];
                    [view.activity performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
                }
                [allActiveRequestURLAndObjects removeObjectForKey:urlStr];
                
            });
            [activity performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
            self.imageUrlString = @"";
        }
    }
}
- (void)setImageFromUrl:(NSURL*)imageUrl {
    [self setImage:nil];
    NSString* imageUrlStr = [imageUrl absoluteString];
    if (!imageUrlStr || [imageUrlStr length] < 5) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:self.defaultImage];
        });
        self.imageUrlString = @"";
        return;
    }
    NSArray* pathComponents = [imageUrlStr pathComponents];
    NSString* finalPath = nil;
    if ([pathComponents count] > 2) {
        NSArray* lastTwoArray = [pathComponents subarrayWithRange:NSMakeRange([pathComponents count]-2,2)];
        finalPath = [NSString stringWithFormat:@"%@_%@",lastTwoArray[0],lastTwoArray[1]];
    }

    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* localPath = [NSString stringWithFormat:@"%@/%@/%@/%@",DOC_DIR,BaseBufferFolder,
                           (([self.imageType length])?self.imageType:NoTypeFolder),
                           finalPath];
    self.imageUrlString = imageUrlStr;
    if ([fm fileExistsAtPath:localPath]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:[UIImage imageWithContentsOfFile:localPath]];
        });
        [activity performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
        self.imageUrlString = @"";
    }
    else {
        [activity performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];
        if (![allActiveRequsetUrl containsObject:imageUrlStr]) {
            [allActiveRequsetUrl addObject:imageUrlStr];
            [allActiveRequestURLAndObjects setObject:[NSMutableArray arrayWithObject:self] forKey:imageUrlStr];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                NSData* data = [NSData dataWithContentsOfURL:imageUrl];
                if ([data length] > 50) {
                    NSFileManager* fm = [NSFileManager defaultManager];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) 
                    {
                        NSError* err = nil;
                        [fm removeItemAtPath:localPath error:&err];
                        if (err)
                            NSLog(@"%s:%@",__FUNCTION__,err);
                    }
                    [fm createFileAtPath:localPath contents:data attributes:nil];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self imageDownloadedFromUrl:imageUrlStr];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setImage:self.defaultImage];
                        [activity stopAnimating];
                    });
                    self.imageUrlString = @"";
                    [allActiveRequsetUrl removeObject:imageUrlStr];
                }
            });
        }
        else {
            DLog(@"Image Is in Queue");
            NSMutableArray *arr =   [allActiveRequestURLAndObjects objectForKey:imageUrlStr];
            if(![arr containsObject:self])
                [arr addObject:self];
            [allActiveRequestURLAndObjects setObject:arr forKey:imageUrlStr];
            
        }
    }
}
- (void)setImageFromUrlString:(NSString*)urlString {
    //    [self setImage:nil];
    //    if (!urlString || [urlString length] < 5) {
    //        [self setImage:self.defaultImage];
    //        self.imageUrlString = @"";
    //        return;
    //    }
    NSURL* url = [NSURL URLWithString:urlString];
    [self setImageFromUrl:url];
}

- (void)setImageForUser:(PFUser*)user {
    NSString* imageUrlStr = [NSString stringWithFormat:@"%@.jpg",[user objectForKey:kKeyUserId]];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* localPath = [NSString stringWithFormat:@"%@/%@/%@/%@",DOC_DIR,BaseBufferFolder,
                           (([self.imageType length])?self.imageType:NoTypeFolder),
                           [imageUrlStr lastPathComponent]];
    self.imageUrlString = imageUrlStr;
    if ([fm fileExistsAtPath:localPath]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:[UIImage imageWithContentsOfFile:localPath]];
        });
        [activity performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
        self.imageUrlString = @"";
    }
    else {
        [activity performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];
        if (![allActiveRequsetUrl containsObject:imageUrlStr]) {
            [allActiveRequsetUrl addObject:imageUrlStr];
            [allActiveRequestURLAndObjects setObject:[NSMutableArray arrayWithObject:self] forKey:imageUrlStr];
            PFFile *profilePic = [user objectForKey:kKeyProfilePic];
            [profilePic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if ([data length] > 50) {
                    NSFileManager* fm = [NSFileManager defaultManager];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath])
                    {
                        NSError* err = nil;
                        [fm removeItemAtPath:localPath error:&err];
                        if (err)
                            NSLog(@"%s:%@",__FUNCTION__,err);
                    }
                    [fm createFileAtPath:localPath contents:data attributes:nil];
                        [self imageDownloadedFromUrl:imageUrlStr];
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setImage:self.defaultImage];
                        [activity stopAnimating];
                    });
                    self.imageUrlString = @"";
                    [allActiveRequsetUrl removeObject:imageUrlStr];
                }
            }];
        }
        else {
            DLog(@"Image Is in Queue");
            NSMutableArray *arr =   [allActiveRequestURLAndObjects objectForKey:imageUrlStr];
            if(![arr containsObject:self])
                [arr addObject:self];
            [allActiveRequestURLAndObjects setObject:arr forKey:imageUrlStr];
            
        }
    }
}
@end

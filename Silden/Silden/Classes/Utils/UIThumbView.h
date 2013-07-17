//
//  UIThumbView.h
//  DaCentrale
//
//  Created by Amit Priyadarshi on 20/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef DOC_DIR
    #define DOC_DIR [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#endif

#ifndef SafeRelease
    #define SafeRelease(object)           \
    {	                                  \
        [object release];                 \
        object = nil;                     \
    }
    #define CheckAndRelease(object)       \
    {                                     \
        if (object) SafeRelease(object);  \
    }
#endif

#define BaseBufferFolder @"buffer"
#define NoTypeFolder @"no_type"

@class UIThumbView;
@protocol UIImageViewTapDelegate <NSObject>
@optional
- (void)didTapOnImageView:(UIThumbView*)clikableImage;
@end

@interface UIThumbView : UIImageView {
    UIActivityIndicatorView* activity;
}
@property(nonatomic, retain) id uniqueIdentifire;
@property(nonatomic, assign) id <UIImageViewTapDelegate> tapDelegate;
@property(nonatomic, retain) NSString* imageType;
@property(nonatomic, retain) NSString* imageUrlString;
@property(nonatomic, retain) UIImage* defaultImage;
@property(nonatomic,retain)UIActivityIndicatorView* activity;
/*!
 @method clearBuffer
 @abstract use when you want to clear all data downloaded from this class
 @discussion This method is used to delete the base folder i.e buffer folder and its content
 */
+ (void)clearBuffer;

/*!
 @method clearBufferOfImageType:
 @abstract use when you want to clear all data downloaded from this class of a particular type
 @param type: type of image or more specifically folder in which you want to store this image
 @discussion This method is used to delete perticular folder and content inside it.
 */
+ (void)clearBufferOfImageType:(NSString*)type;

/*!
 @method addTapReceiver
 @abstract used when you want to get an event when user taps on image.
 @discussion This method is used to create a event receiver transparent UI above ImageView that will call its delegate and preform a selector.
 */
- (void)addTapReceiver;

/*!
 @method setImageFromUrl:
 @abstract use when you want set image which has a URL and that is stored on remote server
 @param imageUrl: URL of image 
 @discussion This method is used to download image from remote server and save in local HD, in folder specified by ~/buffer/imageType with name equels to last path component of URL
 */
- (void)setImageFromUrl:(NSURL*)imageUrl;

/*!
 @method setImageFromUrlString:
 @abstract use when you want set image which has a URL(in string format) and that is stored on remote server
 @param urlString: string URL of image 
 @discussion This method is used to download image from remote server and save in local HD, in folder specified by ~/buffer/imageType with name equels to last path component of URL
 */
- (void)setImageFromUrlString:(NSString*)urlString;

- (void)setImageForUser:(PFUser*)user;
@end

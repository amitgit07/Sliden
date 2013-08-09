//
//  SharedUtility.h
//  Silden
//
//  Created by Amit Priyadarshi on 06/02/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCI [SharedUtility sharedInstance]

typedef enum {
    CheckboxStatusSelected = 1,
    CheckboxStatusUnselected = 2,
}CheckboxStatus;

@interface SharedUtility : NSObject {
    
}
+ (SharedUtility*)sharedInstance;
 
- (void)showDevelopmentAlert;
- (void)showDevelopmentAlertWithMsg:(NSString*)msg;
- (void)showAlertWithMsg:(NSString*)msg;
- (BOOL)isValidEmail:(NSString*)email;
- (BOOL)isValidText:(NSString*)text;

- (void)applyEffectOnBoldLable:(UILabel*)label;
- (NSArray*)getFbFriends;
- (NSArray*)getFbFriendsIds;
- (UIButton*)getACheckBoxButtonOnLocation:(CGPoint)origin;
- (void)scheduleFbPostOnFriendWithIds:(NSArray*)array;
- (NSString*)readableTextFromError:(NSString*)errString;
- (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
@end

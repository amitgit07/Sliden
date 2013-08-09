//
//  SharedUtility.m
//  Silden
//
//  Created by Amit Priyadarshi on 06/02/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SharedUtility.h"

@implementation SharedUtility {
    NSArray* _fbFriends;
    NSArray* _fbFriendIds;
}
static SharedUtility* instance;
+ (SharedUtility*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SharedUtility alloc] init];
    });
    [instance cacheFbFriends];
    return instance;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (instance == nil) {
            instance = [super allocWithZone:zone];
            return instance; 
        }
    }
    return nil;
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX;
}
- (oneway void)release {
    //do nothing
}
- (id)autorelease {
    return self;
}
#pragma mark - Instance methods
-(void)showDevelopmentAlert {
    [self showDevelopmentAlertWithMsg:@"This feature is under development"];
}
-(void)showDevelopmentAlertWithMsg:(NSString*)msg {
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Silden\nUnder Development!!" message:msg delegate:nil cancelButtonTitle:@"I understand :)" otherButtonTitles:nil] autorelease];
    [alert show];
}
- (void)showAlertWithMsg:(NSString*)msg {
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Sliden" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [alert show];
}

- (BOOL)isValidEmail:(NSString*)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL myStringMatchesRegEx=[emailTest evaluateWithObject:email];
    return myStringMatchesRegEx;
    
}
- (BOOL)isValidText:(NSString*)text {
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text && [text length]) {
        NSString *emailRegex = @"[A-Za-z\\s]*";
        NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        BOOL myStringMatchesRegEx=[emailTest evaluateWithObject:text];
        return myStringMatchesRegEx;
    }
    return NO;
}


- (void)applyEffectOnBoldLable:(UILabel*)label {
    label.layer.shadowColor = [[UIColor colorWithWhite:0.95f alpha:0.80f] CGColor];
    label.layer.shadowOffset = CGSizeMake(2.0f, 1.0f);
    label.layer.shadowRadius = 2.0f;
    label.layer.shadowOpacity = 0.40f;
}

- (void)cacheFbFriends {
    if (_fbFriends) return;
    FBSession * session = [FBSession activeSession];
    if (session.isOpen) {
        FBRequest* friendsRequest = [FBRequest requestForMyFriends];
        [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                      NSDictionary* result,
                                                      NSError *error) {
            _fbFriends = [[result objectForKey:@"data"] retain];
        }];
    }
}
- (NSArray*)getFbFriends {
    return _fbFriends;
}
- (NSArray*)getFbFriendsIds {
    NSMutableArray* array = [NSMutableArray array];
    for (PFUser* user in _fbFriends) {
        [array addObject:[user objectForKey:@"id"]];
    }
    _fbFriendIds = [array retain];
    return _fbFriendIds;
}
- (UIButton*)getACheckBoxButtonOnLocation:(CGPoint)origin {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(origin.x, origin.y, 20, 20)];
    [button setImage:Image(@"chk.png") forState:UIControlStateNormal];
    [button setImage:Image(@"chkd.png") forState:UIControlStateSelected];
    [button setSelected:NO];
    return button;
}
- (void)postOnUserWithId:(NSString*)fbId {
}
- (void)scheduleFbPostOnFriendWithIds:(NSArray*)array {
//    [array retain];
//    float delay = 0.0f;
//    for (NSString *fbId in array) {
//        
//        if ([fbId isKindOfClass:[NSString class]]) {
//            [self performSelector:@selector(postOnUserWithId:) withObject:fbId afterDelay:delay];
//            delay += 0.25f;
//        }
//    }
    [[SharedUtility sharedInstance] showDevelopmentAlert];
}
//Error: Error Domain=NSURLErrorDomain Code=-1004 "Could not connect to the server." UserInfo=0xb351010 {NSErrorFailingURLStringKey=https://api.parse.com/2/user_login, NSErrorFailingURLKey=https://api.parse.com/2/user_login, NSLocalizedDescription=Could not connect to the server., NSUnderlyingError=0xb225fa0 "Could not connect to the server."} (Code: 100, Version: 1.2.7)
- (NSString*)readableTextFromError:(NSString*)errString {
    if(errString.length > 50){
        NSRange sRange = [errString rangeOfString:@"NSLocalizedDescription="];
        NSString* result = errString;
        if (sRange.location != NSNotFound) {
            result = [errString substringFromIndex:sRange.location+[@"NSLocalizedDescription=" length]];
        }
        else {
            return result;
        }
        NSRange eRange = [result rangeOfString:@".,"];
        if (eRange.location != NSNotFound) {
            result = [result substringToIndex:eRange.location+1];
        }
        return result;
    }
    else return errString;
}
#define SIZE 300
- (UIImage*)resizeToSquareImage:(UIImage*)image {
    if(image.size.width == image.size.height) return image;

    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 1.0f;
    CGSize videoSize = CGSizeMake(SIZE, SIZE);
    float x=0, y=0;
    
    if(imgRatio!=maxRatio){
        if(imgRatio < maxRatio){
            imgRatio = SIZE / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = SIZE;
            x = 0;
            y = (SIZE-actualHeight)/2.0f;
        }
        else{
            imgRatio = SIZE / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = SIZE;
            y = 0;
            x = (SIZE-actualWidth)/2.0f;
        }
    }
    else {
        actualWidth = SIZE;
        actualHeight = SIZE;
    }
    CGRect rect = CGRectMake(x, y, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(videoSize);
    [image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage
{
    image = [self resizeToSquareImage:image];
    CGImageRef imgRef = [image CGImage];
    CGImageRef maskRef = [maskImage CGImage];
    CGImageRef actualMask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                              CGImageGetHeight(maskRef),
                                              CGImageGetBitsPerComponent(maskRef),
                                              CGImageGetBitsPerPixel(maskRef),
                                              CGImageGetBytesPerRow(maskRef),
                                              CGImageGetDataProvider(maskRef), NULL, false);
    CGImageRef masked = CGImageCreateWithMask(imgRef, actualMask);
    return [UIImage imageWithCGImage:masked];
}
@end

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
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Sliden" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
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
@end

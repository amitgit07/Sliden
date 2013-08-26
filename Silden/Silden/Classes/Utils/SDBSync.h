//
//  SDBSync.h
//  Sliden
//
//  Created by Amit Priyadarshi on 07/08/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DBS [SDBSync sharedInstance]

extern NSString* const kFollowersSynced;
extern NSString* const kFollowingSynced;

@interface SDBSync : NSObject {
}
@property(nonatomic, retain) NSMutableArray* followers;
@property(nonatomic, retain) NSMutableArray* following;
+ (SDBSync*)sharedInstance;

- (void)syncFollowers;
- (void)syncFollowings;
- (void)removeFollower:(PFUser*)notFollowingNow fromUser:(PFUser*)nonInterestingUser;
- (void)addFollower:(PFUser*)newFollower inUser:(PFUser*)interestingUser;
- (void)updateFollowingListWithArray:(NSArray*)newFollowing;
@end

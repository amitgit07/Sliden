//
//  SDBSync.m
//  Sliden
//
//  Created by Amit Priyadarshi on 07/08/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SDBSync.h"

NSString* const kFollowersSynced=@"kFollowersSynced";
NSString* const kFollowingSynced=@"kFollowingSynced";


@implementation SDBSync
static SDBSync* instance;
+ (SDBSync*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SDBSync alloc] init];
    });
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
#pragma mark -
- (NSMutableArray*)followers {
    if (!_followers) {
        _followers = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _followers;
}
- (NSMutableArray*)following {
    if (!_following) {
        _following = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _following;
}

- (void)syncFollowers {
    PFQuery *query = [PFQuery queryWithClassName:@"followTableList"];
    [query whereKey:@"user_id" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
            return;
        }
        if (objects && [objects count]) {
            PFObject* followTableForCU = [objects lastObject];
            NSArray* followers = [followTableForCU objectForKey:@"followers"];
            if(followers && [followers count]) {
                [self.followers removeAllObjects];
                __block int count  = 1;
                for (PFUser* usr in followers) {
                    [usr fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if (error) {
                            NSString *errorString = [[error userInfo] objectForKey:@"error"];
                            [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
                            return;
                        }
                        [self.followers addObject:object];
                        count++;
                        if (count>[followers count]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowersSynced object:nil];
                        }
                    }];
                }
            }
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:kFollowersSynced object:nil];
        }
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowersSynced object:nil];

    }];
}
- (void)syncFollowings {
    PFQuery *query = [PFQuery queryWithClassName:@"followTableList"];
    [query whereKey:@"user_id" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
            return;
        }
        if (objects && [objects count]) {
            PFObject* followTableForCU = [objects lastObject];
            NSArray* following = [followTableForCU objectForKey:@"following"];
            [self.following removeAllObjects];
            if(following && [following count]) {
                __block int count  = 1;
                for (PFUser* usr in following) {
                    [usr fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if (error) {
                            NSString *errorString = [[error userInfo] objectForKey:@"error"];
                            [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
                            return;
                        }
                        [self.following addObject:object];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFollowingSynced object:nil];
                        count++;
                        if (count>[following count]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowingSynced object:nil];
                        }
                    }];
                }
            }
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:kFollowingSynced object:nil];
        }
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowingSynced object:nil];
    }];
}
- (void)removeFollower:(PFUser*)notFollowingNow fromUser:(PFUser*)nonInterestingUser {
    PFQuery *query = [PFQuery queryWithClassName:@"followTableList"];
    [query whereKey:@"user_id" equalTo:nonInterestingUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
            return;
        }
        PFObject* followTableForCU = [objects lastObject];
        if (followTableForCU) {
            NSMutableArray* followers = [followTableForCU objectForKey:@"followers"];
            if (followers && [followers count]) {
                NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    PFUser* user = (PFUser*)evaluatedObject;
                    if ([[notFollowingNow objectForKey:@"objectId"] isEqualToString:[user objectForKey:@"objectId"]]) {
                        return NO;
                    }
                    return YES;
                }];
                [followers filterUsingPredicate:predicate];
                [followTableForCU setObject:followers forKey:@"followers"];
                [followTableForCU saveInBackground];
            }
        }
    }];
}
- (void)addFollower:(PFUser*)newFollower inUser:(PFUser*)interestingUser {
    PFQuery *query = [PFQuery queryWithClassName:@"followTableList"];
    [query whereKey:@"user_id" equalTo:interestingUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
            return;
        }
        PFObject* followTableForCU = [objects lastObject];
        if (followTableForCU) {
            NSMutableArray* followers = [followTableForCU objectForKey:@"followers"];
            [followTableForCU setObject:followers forKey:@"followers"];
            [followTableForCU saveInBackground];
        }
        else {
            PFObject* _followTableObject = [PFObject objectWithClassName:@"followTableList"];
            [_followTableObject setObject:interestingUser forKey:@"user_id"];
            NSArray* followers = [NSArray arrayWithObject:newFollower];
            [_followTableObject setObject:followers forKey:@"followers"];
            [_followTableObject saveInBackground];
        }
    }];
}
- (void)updateFollowingListWithArray:(NSArray*)newFollowing {
    [_following setArray:newFollowing];
    PFQuery *query = [PFQuery queryWithClassName:@"followTableList"];
    [query whereKey:@"user_id" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
            return;
        }
        if (objects && [objects count]) {
            PFObject* obj = [objects lastObject];
            [obj setObject:newFollowing forKey:@"following"];
            [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    [SCI showAlertWithMsg:[SCI readableTextFromError:errorString]];
                    return;
                }
                if (succeeded) {
                    [self syncFollowings];
                    [self syncFollowers];
                }
            }];
        }
    }];
}
@end

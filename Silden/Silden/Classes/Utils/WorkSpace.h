//
//  WorkSpace.h
//  Sliden
//
//  Created by Amit Priyadarshi on 21/07/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WorkingImage;

@interface WorkSpace : NSManagedObject

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * trackUrl;
@property (nonatomic, retain) NSString * videoDescription;
@property (nonatomic, retain) NSString * transitions;
@property (nonatomic, retain) NSSet *images;
@end

@interface WorkSpace (CoreDataGeneratedAccessors)

- (void)addImagesObject:(WorkingImage *)value;
- (void)removeImagesObject:(WorkingImage *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end

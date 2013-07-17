//
//  WorkingImage.h
//  Sliden
//
//  Created by Amit Priyadarshi on 17/07/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WorkSpace;

@interface WorkingImage : NSManagedObject

@property (nonatomic, retain) NSDate * imageAdded;
@property (nonatomic, retain) NSNumber * imageIndex;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSSet *inWorkSpace;
@end

@interface WorkingImage (CoreDataGeneratedAccessors)

- (void)addInWorkSpaceObject:(WorkSpace *)value;
- (void)removeInWorkSpaceObject:(WorkSpace *)value;
- (void)addInWorkSpace:(NSSet *)values;
- (void)removeInWorkSpace:(NSSet *)values;

@end

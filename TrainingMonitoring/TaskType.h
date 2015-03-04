//
//  TaskType.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 3/27/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session, Trial;

@interface TaskType : NSManagedObject

@property (nonatomic, retain) NSString * descriptor;
@property (nonatomic, retain) NSString * movieURLString;
@property (nonatomic, retain) NSNumber * numTrials;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) NSSet *trials;
@end

@interface TaskType (CoreDataGeneratedAccessors)

- (void)addTrialsObject:(Trial *)value;
- (void)removeTrialsObject:(Trial *)value;
- (void)addTrials:(NSSet *)values;
- (void)removeTrials:(NSSet *)values;

@end

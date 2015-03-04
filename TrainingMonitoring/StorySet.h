//
//  StorySet.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/22/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StorySession;

@interface StorySet : NSManagedObject

@property (nonatomic, retain) NSNumber * readyToEdit;
@property (nonatomic, retain) NSNumber * currentSessionID;
@property (nonatomic, retain) NSNumber * subjectID;
@property (nonatomic, retain) NSSet *storySessions;
@end

@interface StorySet (CoreDataGeneratedAccessors)

- (void)addStorySessionsObject:(StorySession *)value;
- (void)removeStorySessionsObject:(StorySession *)value;
- (void)addStorySessions:(NSSet *)values;
- (void)removeStorySessions:(NSSet *)values;

@end

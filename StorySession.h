//
//  StorySession.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/23/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StorySet, Trial;

@interface StorySession : NSManagedObject

@property (nonatomic, retain) NSNumber * sessionID;
@property (nonatomic, retain) StorySet *storySet;
@property (nonatomic, retain) NSSet *trials;
@end

@interface StorySession (CoreDataGeneratedAccessors)

- (void)addTrialsObject:(Trial *)value;
- (void)removeTrialsObject:(Trial *)value;
- (void)addTrials:(NSSet *)values;
- (void)removeTrials:(NSSet *)values;

@end

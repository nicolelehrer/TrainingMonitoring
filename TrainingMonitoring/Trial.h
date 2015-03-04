//
//  Trial.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/22/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Rating, StorySession, TaskType;

@interface Trial : NSManagedObject

@property (nonatomic, retain) NSNumber * coarseSliderStartTime;
@property (nonatomic, retain) NSNumber * coarseStartTime;
@property (nonatomic, retain) NSNumber * coarseStopTime;
@property (nonatomic, retain) NSNumber * fineSliderEndTime;
@property (nonatomic, retain) NSNumber * fineSliderStartTime;
@property (nonatomic, retain) NSNumber * fineStartTime;
@property (nonatomic, retain) NSNumber * fineStopTime;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * showFull;
@property (nonatomic, retain) NSNumber * storyIndex;
@property (nonatomic, retain) NSNumber * tag;
@property (nonatomic, retain) NSString * tagAnnotation;
@property (nonatomic, retain) Rating *rating;
@property (nonatomic, retain) TaskType *taskType;
@property (nonatomic, retain) StorySession *storySession;

@end

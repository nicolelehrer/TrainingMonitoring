//
//  Session.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 10/5/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Subject, SurveyAnswer, TaskType;

@interface Session : NSManagedObject

@property (nonatomic, retain) NSDate * sessionDate;
@property (nonatomic, retain) NSNumber * sessionID;
@property (nonatomic, retain) NSNumber * studySessionID;
@property (nonatomic, retain) NSNumber * finishedStory;
@property (nonatomic, retain) NSNumber * sharedStory;
@property (nonatomic, retain) Subject *subject;
@property (nonatomic, retain) NSSet *surveyAnswer;
@property (nonatomic, retain) NSSet *taskType;
@end

@interface Session (CoreDataGeneratedAccessors)

- (void)addSurveyAnswerObject:(SurveyAnswer *)value;
- (void)removeSurveyAnswerObject:(SurveyAnswer *)value;
- (void)addSurveyAnswer:(NSSet *)values;
- (void)removeSurveyAnswer:(NSSet *)values;

- (void)addTaskTypeObject:(TaskType *)value;
- (void)removeTaskTypeObject:(TaskType *)value;
- (void)addTaskType:(NSSet *)values;
- (void)removeTaskType:(NSSet *)values;

@end

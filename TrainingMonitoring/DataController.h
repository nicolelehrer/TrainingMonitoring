//
//  DataController.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 3/27/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Subject.h"
#import "Session.h"
#import "TaskType.h"
#import "StorySession.h"

@interface DataController : NSObject
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)createSubjectWithLocalID:(int)subjectID andStudyID:(int)studySubjectID;

- (void)createSubjectsWithCount:(int)numSubjects;
- (void)createSessionNumber:(int)sessionNumber withStudySessionID:(int)studySessionID forSubjectWithLocalID:(int)subjectID;

- (Subject *)fetchSubjectWithID:(int)subjectID;
- (Session *)fetchSessionNumber:(int)sessionID forSubject:(int)subjectID;
- (TaskType *)fetchTaskWithOrder:(int)order forSubject:(int)subjectID fromSession:(int)sessionID;
- (TaskType *)fetchTaskWithDescriptor:(NSString *)descriptor forSubject:(int)subjectID fromSession:(int)sessionID;
- (SurveyAnswer *)fetchSurveyAnswerWithIndex:(int)questionIndex forSubject:(int)subjectID fromSession:(int)sessionID;
- (Trial *)fetchTrialWithIndex:(int)trialIndex forTaskType:(NSString*)descriptor forSubject:(int)subjectID fromSession:(int)sessionID;
- (NSArray *)fetchTrialsWithBookMarkTag:(int)tag forTaskType:(NSString*)descriptor forSubject:(int)subjectID fromSession:(int)sessionID;
- (void)resetSegmentingTimesFor:(int)subjectID forTaskType:(NSString*)taskDescriptor inSession:(int)sessionID;

- (void)resetSegmentingTimesForTrial:(int)trialIndex forTaskType:(NSString*)taskDescriptor forSession:(int)sessionID forSubject:(int)subjectID;
- (void)resetOnlyCoarseSegmentingTimesFor:(int)subjectID forTaskType:(NSString*)taskDescriptor inSession:(int)sessionID;

- (NSString *)tagTranslatorForIntValue:(int)tag;

- (StorySet *)fetchStorySetForSession:(int)sessionID forSubject:(int)subjectID;


- (StorySession *)fetchStorySession:(int)sessionID fromStorySet:(StorySet*)storySet;

- (void)saveInitialStorySetForSession:(int)sessionID ForSubject:(int)subjectID;
-(void)updateNewStorySetFromSession:(int)sessionID ForSubject:(int)subjectID WithArray:(NSArray*)newCompoundArray;
-(NSArray*)returnArrayAfterOrderingStorySessionWithSessionID:(int)sessionID fromStorySet:(int)currentSessionID forSubject:(int)subjectID;

- (Trial *)fetchTrialWithStoryIndex:(int)trialIndex forStorySession:(StorySession*)storySession;

-(void)saveArray:(NSArray*)compoundArray ToPlistForSubjectID:(int)subjectID ForCurrentSessionID:(int)currentSessionID;
-(BOOL)checkIfDataExistsForSubjectID:(int)subjectID ForCurrentSessionID:(int)currentSessionID;
-(NSArray*)returnCompoundArrayFromPlistForSubjectID:(int)subjectID ForCurrentSessionID:(int)currentSessionID;


-(void)writeInitialBookmarkedDescriptorsToPlistForSession:(int)sessionID ForSubject:(int)subjectID;
-(Trial*)returnTrialForDescriptor:(NSString*)descriptor;


-(void)deleteSessionNumber:(int)sessionID forSubject:(int)subjectID;

- (void)addAnotherSubjectWithID:(int)subjectID;
- (int)fetchTotalSubjectCount;
- (void)deleteSubjectWithID:(int)subjectID;
@end

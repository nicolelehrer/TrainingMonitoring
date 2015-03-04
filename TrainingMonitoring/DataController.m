//
//  DataController.m
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 3/27/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import "DataController.h"
#import "Subject.h"
#import "Session.h"
#import "TaskType.h"
#import "Trial.h"
#import "SurveyAnswer.h"
#import "StorySet.h"
#import "StorySession.h"

@interface DataController ()
@end

@implementation DataController

@synthesize managedObjectContext = _managedObjectContext;

#define SESSION_COUNT 4
#define SURVEYQUES_COUNT 13

- (id)init
{
	self = [super init];
    if (self != nil) {
        
        [self copyStoryEditRecordPlist];
   
    }
    
	return self;
}

- (void) copyStoryEditRecordPlist
{
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"StoryEditRecord.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"StoryEditRecord" ofType:@"plist"]; //5
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    
    NSMutableDictionary *savedRecord = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
	if (savedRecord == nil) {
		NSLog( @"savedRecord is nil");
    }
    else {
    	NSLog( @"loaded %i components into savedRecord from StoryEditRecord", [savedRecord count]);
    }
}


- (Subject *)fetchSubjectWithID:(int)subjectID
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(subjectID == %@)", [NSNumber numberWithInt:subjectID]];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Error occured in fetcSubjectWithID: %@", error);
    }
    
    Subject * returnedSubject;
    
    for (Subject * s in fetchedObjects) {
        
//        NSLog(@"size of fetchedObjects: %i", [fetchedObjects count]);
//        NSLog(@"SubjectID: %i", [s.subjectID integerValue]);
        returnedSubject = s;
    }
    
    return returnedSubject;
}

- (int)fetchTotalSubjectCount
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = nil;
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return [fetchedObjects count];
}


- (Session *)fetchSessionNumber:(int)sessionID forSubject:(int)subjectID
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(subjectID == %@)", [NSNumber numberWithInt:subjectID]];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Error occured in fetcSubjectWithID: %@", error);
    }
    
    Subject * returnedSubject;
    
    for (Subject * s in fetchedObjects) {
        
//        NSLog(@"size of fetchedObjects: %i", [fetchedObjects count]);
//        NSLog(@"SubjectID: %i", [s.subjectID integerValue]);
        returnedSubject = s;
    }
    

    NSPredicate *predicate2 = [NSPredicate
                               predicateWithFormat:@"(sessionID == %@)", [NSNumber numberWithInt:sessionID]];
    
    NSSet *filteredSet = [returnedSubject.sessions filteredSetUsingPredicate:predicate2];
    
    Session * returnedSession;

    for (Session * ss in filteredSet) {
            returnedSession = ss;
        
//            NSLog(@"size of returnedSubject.sessions: %i", [returnedSubject.sessions count]);
//            NSLog(@"sessionID: %i", [returnedSession.sessionID integerValue]);
    }

    return returnedSession;
}



- (TaskType *)fetchTaskWithOrder:(int)order forSubject:(int)subjectID fromSession:(int)sessionID
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *subjectPredicate = [NSPredicate
                              predicateWithFormat:@"(subjectID == %@)", [NSNumber numberWithInt:subjectID]];
    
    [fetchRequest setPredicate:subjectPredicate];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Error occured in fetcSubjectWithID: %@", error);
    }
    
    Subject * returnedSubject;
    
    for (Subject * s in fetchedObjects) {
        
//        NSLog(@"size of fetchedObjects: %i", [fetchedObjects count]);
//        NSLog(@"SubjectID: %i", [s.subjectID integerValue]);
        returnedSubject = s;
    }
    
    
    NSPredicate *sessionPredicate = [NSPredicate
                               predicateWithFormat:@"(sessionID == %@)", [NSNumber numberWithInt:sessionID]];
    
    NSSet *filteredSessionSet = [returnedSubject.sessions filteredSetUsingPredicate:sessionPredicate];
    
    Session * returnedSession;
    
    for (Session * ss in filteredSessionSet) {
        returnedSession = ss;
        
//        NSLog(@"size of returnedSubject.sessions: %i", [returnedSubject.sessions count]);
//        NSLog(@"sessionID: %i", [returnedSession.sessionID integerValue]);
    }
    
    
    NSPredicate *taskTypePredicate = [NSPredicate
                               predicateWithFormat:@"(order == %@)", [NSNumber numberWithInt:order]];
    
    NSSet *filteredTaskTypeSet = [returnedSession.taskType filteredSetUsingPredicate:taskTypePredicate];
    
    
    TaskType * returnedTaskType;
    
    for (TaskType * tt in filteredTaskTypeSet) {
        returnedTaskType = tt;
        
//        NSLog(@"size of filteredTaskTypeSet: %i", [filteredTaskTypeSet count]);
//        NSLog(@"taskType: %@", returnedTaskType.descriptor);
    }
    
    return returnedTaskType;
}

- (TaskType *)fetchTaskWithDescriptor:(NSString *)descriptor forSubject:(int)subjectID fromSession:(int)sessionID
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *subjectPredicate = [NSPredicate
                                     predicateWithFormat:@"(subjectID == %@)", [NSNumber numberWithInt:subjectID]];
    
    [fetchRequest setPredicate:subjectPredicate];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Error occured in fetcSubjectWithID: %@", error);
    }
    
    Subject * returnedSubject;
    
    for (Subject * s in fetchedObjects) {
        
        //        NSLog(@"size of fetchedObjects: %i", [fetchedObjects count]);
        //        NSLog(@"SubjectID: %i", [s.subjectID integerValue]);
        returnedSubject = s;
    }
    
    
    NSPredicate *sessionPredicate = [NSPredicate
                                     predicateWithFormat:@"(sessionID == %@)", [NSNumber numberWithInt:sessionID]];
    
    NSSet *filteredSessionSet = [returnedSubject.sessions filteredSetUsingPredicate:sessionPredicate];
    
    Session * returnedSession;
    
    for (Session * ss in filteredSessionSet) {
        returnedSession = ss;
        
        //        NSLog(@"size of returnedSubject.sessions: %i", [returnedSubject.sessions count]);
        //        NSLog(@"sessionID: %i", [returnedSession.sessionID integerValue]);
    }
    
    
    NSPredicate *taskTypePredicate = [NSPredicate
                                      predicateWithFormat:@"(descriptor == %@)", descriptor];
    
    NSSet *filteredTaskTypeSet = [returnedSession.taskType filteredSetUsingPredicate:taskTypePredicate];
    
    
    TaskType * returnedTaskType;
    
    for (TaskType * tt in filteredTaskTypeSet) {
        returnedTaskType = tt;
        
        //        NSLog(@"size of filteredTaskTypeSet: %i", [filteredTaskTypeSet count]);
        //        NSLog(@"taskType: %@", returnedTaskType.descriptor);
    }
    
    return returnedTaskType;
}


- (Trial *)fetchTrialWithIndex:(int)trialIndex forTaskType:(NSString*)descriptor forSubject:(int)subjectID fromSession:(int)sessionID
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *subjectPredicate = [NSPredicate
                                     predicateWithFormat:@"(subjectID == %@)", [NSNumber numberWithInt:subjectID]];
    
    [fetchRequest setPredicate:subjectPredicate];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Error occured in fetchSubjectWithID: %@", error);
    }
    
    Subject * returnedSubject;
    
    for (Subject * s in fetchedObjects) {
        
        //        NSLog(@"size of fetchedObjects: %i", [fetchedObjects count]);
        //        NSLog(@"SubjectID: %i", [s.subjectID integerValue]);
        returnedSubject = s;
    }
    
    
    NSPredicate *sessionPredicate = [NSPredicate
                                     predicateWithFormat:@"(sessionID == %@)", [NSNumber numberWithInt:sessionID]];
    
    NSSet *filteredSessionSet = [returnedSubject.sessions filteredSetUsingPredicate:sessionPredicate];
    
    Session * returnedSession;
    
    for (Session * ss in filteredSessionSet) {
        returnedSession = ss;
        
        //        NSLog(@"size of returnedSubject.sessions: %i", [returnedSubject.sessions count]);
        //        NSLog(@"sessionID: %i", [returnedSession.sessionID integerValue]);
    }
    
    NSPredicate *taskTypePredicate = [NSPredicate
                                      predicateWithFormat:@"(descriptor == %@)", descriptor];
    
    NSSet *filteredTaskTypeSet = [returnedSession.taskType filteredSetUsingPredicate:taskTypePredicate];
    
    
    TaskType * returnedTaskType;
    
    for (TaskType * tt in filteredTaskTypeSet) {
        returnedTaskType = tt;
        
        //        NSLog(@"size of filteredTaskTypeSet: %i", [filteredTaskTypeSet count]);
        //        NSLog(@"taskType: %@", returnedTaskType.descriptor);
    }
        
    
    NSPredicate *trialsPredicate = [NSPredicate
                                          predicateWithFormat:@"(index == %@)", [NSNumber numberWithInt:trialIndex]];
    
    NSSet *filteredTrialSet = [returnedTaskType.trials filteredSetUsingPredicate:trialsPredicate];
    
    
    Trial * returnedTrial;
    
    for (Trial * tr in filteredTrialSet) {
        returnedTrial = tr;
        
        //        NSLog(@"size of filteredTaskTypeSet: %i", [filteredTaskTypeSet count]);
        //        NSLog(@"taskType: %@", returnedTaskType.descriptor);
    }
    
    return returnedTrial;
}





- (NSArray *)fetchTrialsWithBookMarkTag:(int)tag forTaskType:(NSString*)descriptor forSubject:(int)subjectID fromSession:(int)sessionID
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *subjectPredicate = [NSPredicate
                                     predicateWithFormat:@"(subjectID == %@)", [NSNumber numberWithInt:subjectID]];
    
    [fetchRequest setPredicate:subjectPredicate];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Error occured in fetchSubjectWithID: %@", error);
    }
    
    Subject * returnedSubject;
    
    for (Subject * s in fetchedObjects) {
        
        //        NSLog(@"size of fetchedObjects: %i", [fetchedObjects count]);
        //        NSLog(@"SubjectID: %i", [s.subjectID integerValue]);
        returnedSubject = s;
    }
    
    
    NSPredicate *sessionPredicate = [NSPredicate
                                     predicateWithFormat:@"(sessionID == %@)", [NSNumber numberWithInt:sessionID]];
    
    NSSet *filteredSessionSet = [returnedSubject.sessions filteredSetUsingPredicate:sessionPredicate];
    
    Session * returnedSession;
    
    for (Session * ss in filteredSessionSet) {
        returnedSession = ss;
        
        //        NSLog(@"size of returnedSubject.sessions: %i", [returnedSubject.sessions count]);
        //        NSLog(@"sessionID: %i", [returnedSession.sessionID integerValue]);
    }
    
    NSPredicate *taskTypePredicate = [NSPredicate
                                      predicateWithFormat:@"(descriptor == %@)", descriptor];
    
    NSSet *filteredTaskTypeSet = [returnedSession.taskType filteredSetUsingPredicate:taskTypePredicate];
    
    
    TaskType * returnedTaskType;
    
    for (TaskType * tt in filteredTaskTypeSet) {
        returnedTaskType = tt;
        
        //        NSLog(@"size of filteredTaskTypeSet: %i", [filteredTaskTypeSet count]);
        //        NSLog(@"taskType: %@", returnedTaskType.descriptor);
    }
    
    
    NSPredicate *bookMarkPredicate = [NSPredicate
                                    predicateWithFormat:@"(tag == %@)", [NSNumber numberWithInt:tag]];
    
    NSSet *filteredTrialSet = [returnedTaskType.trials filteredSetUsingPredicate:bookMarkPredicate];
    
    
    NSMutableSet * returnedTrials = [[NSMutableSet alloc] init];
    
    for (Trial * tr in filteredTrialSet) {
        [returnedTrials addObject:tr];
//        NSLog(@"size of returnedTrials: %i", [returnedTrials count]);
    }
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    return [returnedTrials sortedArrayUsingDescriptors:sortDescriptors];

}


-(void)saveInitialStorySetForSession:(int)sessionID ForSubject:(int)subjectID
{
    
    //look at all sessions that are earlier than this too 
    
    int sCount;
    
    for (sCount=1; sCount<=sessionID; sCount++) {
        
        NSMutableArray *array1 = [[self fetchTrialsWithBookMarkTag:0 forTaskType:@"graspCone" forSubject:subjectID fromSession:sCount] mutableCopy];
        
        int i;
        for (i=0; i<3; i++)
        {
            if (i>0) {
                NSArray *arrayTemp1 = [self fetchTrialsWithBookMarkTag:i forTaskType:@"graspCone" forSubject:subjectID fromSession:sCount];
                [array1 addObjectsFromArray:arrayTemp1];
            }
            
            NSArray *arrayTemp2 = [self fetchTrialsWithBookMarkTag:i forTaskType:@"elevatedTouch" forSubject:subjectID fromSession:sCount];
            [array1 addObjectsFromArray:arrayTemp2];
            
            NSArray *arrayTemp3 = [self fetchTrialsWithBookMarkTag:i forTaskType:@"transport" forSubject:subjectID fromSession:sCount];
            [array1 addObjectsFromArray:arrayTemp3];
            
        }
        
//        NSLog(@"size of grasp bookMarks %i", [array1 count]);
        
        //pull only this session's story set
        StorySet * storySet = [self fetchStorySetForSession:sessionID forSubject:subjectID];
        StorySession * storySession;
        
        //check if story session exists or create one with this session ID
        if ([self fetchStorySession:sCount fromStorySet:storySet])
        {            
            storySession = [self fetchStorySession:sCount fromStorySet:storySet];
        }
        else{
            storySession = (StorySession*)[NSEntityDescription
                                                          insertNewObjectForEntityForName:@"StorySession"
                                                          inManagedObjectContext:self.managedObjectContext];
            
            storySession.sessionID = [NSNumber numberWithInt:sCount];
        }
        
        //remove all trials already there
        NSMutableSet *mutableSet = [NSMutableSet setWithSet:storySession.trials];
        [mutableSet removeAllObjects];
        storySession.trials = mutableSet;

        
        //put in whole set that was bookmarked
        for (i=0; i<[array1 count]; i++) {
            
            Trial * trial = [array1 objectAtIndex:i];
            trial.storyIndex = [NSNumber numberWithInt:i];
            [storySession addTrialsObject:trial];   
        }
        
        [storySet addStorySessionsObject:storySession];
        
//        NSLog(@"number of story sessions is %i for current session %i", [storySet.storySessions count], sessionID);
        
        //save
        NSError *error = nil;
        
        if ( !  [self.managedObjectContext save:&error] ) {
            NSLog(@"An error! %@",error);
        }
        
    }
}





- (Trial *)fetchTrialWithStoryIndex:(int)trialIndex forStorySession:(StorySession*)storySession
{
    NSPredicate *trialsPredicate = [NSPredicate
                                    predicateWithFormat:@"(storyIndex == %@)", [NSNumber numberWithInt:trialIndex]];
    
    NSSet *filteredTrialSet = [storySession.trials filteredSetUsingPredicate:trialsPredicate];
    
    Trial * returnedTrial;
    
    for (Trial * tr in filteredTrialSet) {
        returnedTrial = tr;
        
        //        NSLog(@"size of filteredTaskTypeSet: %i", [filteredTaskTypeSet count]);
        //        NSLog(@"taskType: %@", returnedTaskType.descriptor);
    }
    
    return returnedTrial;
}









-(NSArray*)returnArrayAfterOrderingStorySessionWithSessionID:(int)sessionID fromStorySet:(int)currentSessionID forSubject:(int)subjectID
{
    StorySet* storySet = [self fetchStorySetForSession:currentSessionID forSubject:subjectID];
    
    StorySession * returnedStorySession =[self fetchStorySession:sessionID fromStorySet:storySet];
    
    
    NSMutableArray * tempArray = [[NSMutableArray alloc] initWithCapacity:[returnedStorySession.trials count]];
    
    int i;
    for (i=0; i<[returnedStorySession.trials count]; i++)
    {
        
        
        NSPredicate *trialsPredicate = [NSPredicate
                                        predicateWithFormat:@"(storyIndex == %@)", [NSNumber numberWithInt:i]];
        
        
        NSSet *filteredTrialSet = [returnedStorySession.trials filteredSetUsingPredicate:trialsPredicate];
        
        
        Trial * returnedTrial;
        
        for (Trial * tr in filteredTrialSet) {
            returnedTrial = tr;
            
            NSLog(@"returnedTrial storyIndex: %i", [returnedTrial.storyIndex intValue]);
        }
        
        [tempArray insertObject:returnedTrial atIndex:i];
    }
    
    return tempArray;
    
}

-(void)updateNewStorySetFromSession:(int)sessionID ForSubject:(int)subjectID WithArray:(NSArray*)newCompoundArray
{
    int i;
    
    StorySet * storySet = [self fetchStorySetForSession:sessionID forSubject:subjectID];
    NSArray * newArray;
    
    for (i=0; i<[newCompoundArray count]; i++) {
        
        newArray = [newCompoundArray objectAtIndex:i];
       
        NSLog(@"size of newArray : %i", [newArray count]);

        
        StorySession * storySession = [self fetchStorySession:i+1 fromStorySet:storySet];
        
        NSMutableSet *mutableSet = [NSMutableSet setWithSet:storySession.trials];
        [mutableSet removeAllObjects];
        storySession.trials = mutableSet;
        
            
        NSLog(@"storySession.trials count before array: %i", [storySession.trials count]);
        
        for (i=0; i<[newArray count]; i++) {
            
            Trial * trial = (Trial*)[NSEntityDescription
                                     insertNewObjectForEntityForName:@"Trial"
                                     inManagedObjectContext:self.managedObjectContext];
            

//            trial = [newArray objectAtIndex:i];
            
            trial = [self clone:[newArray objectAtIndex:i] inContext:self.managedObjectContext];
            
            trial.storyIndex = [NSNumber numberWithInt:i];
            [storySession addTrialsObject:trial];
            
            
            //save
            NSError *error = nil;
            
            if ( !  [self.managedObjectContext save:&error] ) {
                NSLog(@"An error! %@",error);
            }
        }
        
        
//        NSLog(@"size of storyset trials after array: %i", [storySession.trials count]);

    }
}



-(Trial *) clone:(NSManagedObject *)source inContext:(NSManagedObjectContext *)context
{

    //create new object in data store
    Trial *clonedTrial = [NSEntityDescription
                               insertNewObjectForEntityForName:@"Trial"
                               inManagedObjectContext:self.managedObjectContext];
    
    //loop through all attributes and assign then to the clone
    NSDictionary *attributes = [[NSEntityDescription
                                 entityForName:@"Trial"
                                 inManagedObjectContext:self.managedObjectContext] attributesByName];
    
    for (NSString *attr in attributes) {
        [clonedTrial setValue:[source valueForKey:attr] forKey:attr];
    }
    
    //Loop through all relationships, and clone them.
//    NSDictionary *relationships = [[NSEntityDescription
//                                    entityForName:@"Trial"
//                                    inManagedObjectContext:self.managedObjectContext] relationshipsByName];
////    for (NSRelationshipDescription *rel in relationships){
//        NSString *keyName = [NSString stringWithFormat:@"%@",rel];
//        //get a set of all objects in the relationship
//        NSMutableSet *sourceSet = [source mutableSetValueForKey:keyName];
//        NSMutableSet *clonedSet = [clonedTrial mutableSetValueForKey:keyName];
//        NSEnumerator *e = [sourceSet objectEnumerator];
//        NSManagedObject *relatedObject;
//        while ( relatedObject = [e nextObject]){
//            //Clone it, and add clone to set
//            NSManagedObject *clonedRelatedObject = [self clone:relatedObject
//                                                                    inContext:self.managedObjectContext];
//            [clonedSet addObject:clonedRelatedObject];
//        }
//        
//    }
    
    return clonedTrial;


}


- (StorySet *)fetchStorySetForSession:(int)currentSessionID forSubject:(int)subjectID
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StorySet" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(subjectID == %@) AND (currentSessionID == %@)", [NSNumber numberWithInt:subjectID], [NSNumber numberWithInt:currentSessionID]];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Error occured in fetchSubjectWithID: %@", error);
    }
    
    StorySet * returnedStorySet;
    
    for (StorySet * ss in fetchedObjects) {
        
        returnedStorySet = ss;
//        NSLog(@"returned story set current session ID %i", [returnedStorySet.currentSessionID intValue]);
//        NSLog(@"returned story set subject ID %i", [returnedStorySet.subjectID intValue]);

    }
    
    return returnedStorySet;
}


- (StorySession *)fetchStorySession:(int)sessionID fromStorySet:(StorySet*)storySet
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StorySession" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(sessionID == %@)", [NSNumber numberWithInt:sessionID]];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Error occured in fetchStorySessions: %@", error);
    }
    
    StorySession * returnedStorySession;
    
    for (StorySession * ss in fetchedObjects) {
        
        returnedStorySession = ss;
    }
    
    return returnedStorySession;
}



- (SurveyAnswer *)fetchSurveyAnswerWithIndex:(int)questionIndex forSubject:(int)subjectID fromSession:(int)sessionID
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subject" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *subjectPredicate = [NSPredicate
                                     predicateWithFormat:@"(subjectID == %@)", [NSNumber numberWithInt:subjectID]];
    
    [fetchRequest setPredicate:subjectPredicate];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Error occured in fetchSubjectWithID: %@", error);
    }
    
    Subject * returnedSubject;
    
    for (Subject * s in fetchedObjects) {
        
        //        NSLog(@"size of fetchedObjects: %i", [fetchedObjects count]);
        //        NSLog(@"SubjectID: %i", [s.subjectID integerValue]);
        returnedSubject = s;
    }
    
    
    NSPredicate *sessionPredicate = [NSPredicate
                                     predicateWithFormat:@"(sessionID == %@)", [NSNumber numberWithInt:sessionID]];
    
    NSSet *filteredSessionSet = [returnedSubject.sessions filteredSetUsingPredicate:sessionPredicate];
    
    Session * returnedSession;
    
    for (Session * ss in filteredSessionSet) {
        returnedSession = ss;
        
        //        NSLog(@"size of returnedSubject.sessions: %i", [returnedSubject.sessions count]);
        //        NSLog(@"sessionID: %i", [returnedSession.sessionID integerValue]);
    }
    
    
    NSPredicate *surveyAnswerPredicate = [NSPredicate
                                      predicateWithFormat:@"(questionIndex == %@)", [NSNumber numberWithInt:questionIndex]];
    
    NSSet *filteredSurveyAnswerSet = [returnedSession.surveyAnswer filteredSetUsingPredicate:surveyAnswerPredicate];
    
    
    SurveyAnswer * returnedSurveyAnswer;
    
    for (SurveyAnswer * sa in filteredSurveyAnswerSet) {
        returnedSurveyAnswer = sa;
        
        //        NSLog(@"size of filteredTaskTypeSet: %i", [filteredTaskTypeSet count]);
        //        NSLog(@"taskType: %@", returnedTaskType.descriptor);
    }
    
    return returnedSurveyAnswer;
}


- (void)createSubjectsWithCount:(int)numSubjects
{
    int i = 0;
    for (i=0; i<numSubjects; i++) {
      
        if ([self fetchSubjectWithID:i+1]) {
            NSLog(@"Subject %i already exists", i+1);
        }
        else
        {
            Subject * subject = (Subject*)[NSEntityDescription
                                           insertNewObjectForEntityForName:@"Subject"
                                           inManagedObjectContext:self.managedObjectContext];
            
            subject.subjectID = [NSNumber numberWithInt:i+1];
            
            
            
            //save
            NSError *error = nil;

            if ( !  [self.managedObjectContext save:&error] ) {
                NSLog(@"An error! %@",error);
            }

        }
    }
    
}

- (void)createSubjectWithLocalID:(int)subjectID andStudyID:(int)studySubjectID
{
    if ([self fetchSubjectWithID:subjectID]) {
        NSLog(@"Subject %i already exists", subjectID);
    }
    else
    {
        Subject * subject = (Subject*)[NSEntityDescription
                                       insertNewObjectForEntityForName:@"Subject"
                                       inManagedObjectContext:self.managedObjectContext];
        
        subject.subjectID = [NSNumber numberWithInt:subjectID];
        subject.studySubjectID = [NSNumber numberWithInt:studySubjectID];

        
        
        //save
        NSError *error = nil;
        
        if ( !  [self.managedObjectContext save:&error] ) {
            NSLog(@"An error! %@",error);
        }
        
    }
}



- (void)addAnotherSubjectWithID:(int)subjectID
{
    if ([self fetchSubjectWithID:subjectID]) {
        NSLog(@"Subject %i already exists", subjectID);
    }
    else{
        Subject * subject = (Subject*)[NSEntityDescription
                                       insertNewObjectForEntityForName:@"Subject"
                                       inManagedObjectContext:self.managedObjectContext];
        
        subject.subjectID = [NSNumber numberWithInt:subjectID];
        
        
        
        //save
        NSError *error = nil;
        
        if ( !  [self.managedObjectContext save:&error] ) {
            NSLog(@"An error! %@",error);
        }
    }
}

- (void)deleteSubjectWithID:(int)subjectID
{
    if (![self fetchSubjectWithID:subjectID]) {
        NSLog(@"Subject %i does NOT exist", subjectID);
    }
    else{
        
        [self.managedObjectContext deleteObject:[self fetchSubjectWithID:subjectID]];
        
        //save? might not need to here
        NSError *error = nil;
        
        if ( !  [self.managedObjectContext save:&error] ) {
            NSLog(@"An error! %@",error);
        }
    }
}



- (void)createSessionNumber:(int)sessionNumber withStudySessionID:(int)studySessionID forSubjectWithLocalID:(int)subjectID
{
    Subject * subject = [self fetchSubjectWithID:subjectID];
    
    if ([self fetchSessionNumber:sessionNumber forSubject:subjectID]) {
        NSLog(@"session #: %i exists for subject #: %i", sessionNumber, subjectID);
    }
    else{
    
    
        Session * session = (Session*)[NSEntityDescription
                                       insertNewObjectForEntityForName:@"Session"
                                       inManagedObjectContext:self.managedObjectContext];
        
        session.sessionID = [NSNumber numberWithInt:sessionNumber];
        session.sessionDate = [NSDate date];
        session.studySessionID = [NSNumber numberWithInt:studySessionID];
    
        //first training monitoring session requires 5 transports, performed first
        int transportOrder;
        int coneOrder;
        int touchOrder;
        int transportTrialNumber;
        
        if (sessionNumber==1) {
            transportOrder = 1;
            coneOrder = 2;
            touchOrder = 3;
            transportTrialNumber = 10;
        }
        else{
            transportOrder = 3;
            coneOrder = 1;
            touchOrder = 2;
            transportTrialNumber = 4;
        }
        
        TaskType * task = (TaskType*)[NSEntityDescription
                                      insertNewObjectForEntityForName:@"TaskType"
                                      inManagedObjectContext:self.managedObjectContext];
        task.descriptor = @"transport";
        task.order = [NSNumber numberWithInt:transportOrder];
        task.numTrials = [NSNumber numberWithInt:transportTrialNumber];
        
        int k=0;
        for (k=0; k<[task.numTrials intValue]; k++) {
            
            Trial * trial = (Trial*)[NSEntityDescription
                                     insertNewObjectForEntityForName:@"Trial"
                                     inManagedObjectContext:self.managedObjectContext];
            trial.index = [NSNumber numberWithInt:k+1];
            [task addTrialsObject:trial];
        }
        
    [session addTaskTypeObject:task];
        
        TaskType * task2 = (TaskType*)[NSEntityDescription
                                       insertNewObjectForEntityForName:@"TaskType"
                                       inManagedObjectContext:self.managedObjectContext];
        task2.descriptor = @"graspCone";
        task2.order = [NSNumber numberWithInt:coneOrder];
        task2.numTrials = [NSNumber numberWithInt:5];

        k=0;
        for (k=0; k<[task2.numTrials intValue]; k++) {
            
            Trial * trial = (Trial*)[NSEntityDescription
                                     insertNewObjectForEntityForName:@"Trial"
                                     inManagedObjectContext:self.managedObjectContext];
            trial.index = [NSNumber numberWithInt:k+1];
            [task2 addTrialsObject:trial];
        }
        
    [session addTaskTypeObject:task2];

        TaskType * task3 = (TaskType*)[NSEntityDescription
                                       insertNewObjectForEntityForName:@"TaskType"
                                       inManagedObjectContext:self.managedObjectContext];
        task3.descriptor = @"elevatedTouch";
        task3.order = [NSNumber numberWithInt:touchOrder];
        task3.numTrials = [NSNumber numberWithInt:5];

        k=0;
        for (k=0; k<[task3.numTrials intValue]; k++) {
            
            Trial * trial = (Trial*)[NSEntityDescription
                                     insertNewObjectForEntityForName:@"Trial"
                                     inManagedObjectContext:self.managedObjectContext];
            trial.index = [NSNumber numberWithInt:k+1];
            [task3 addTrialsObject:trial];
        }
        
    [session addTaskTypeObject:task3];

        //create survey answers
        int l = 0;
        for (l=0; l<SURVEYQUES_COUNT; l++) {
            SurveyAnswer * answer = (SurveyAnswer*)[NSEntityDescription
                                                    insertNewObjectForEntityForName:@"SurveyAnswer"
                                                    inManagedObjectContext:self.managedObjectContext];
            answer.questionIndex = [NSNumber numberWithInt:l+1];

            [session addSurveyAnswerObject:answer];

        }
        
        
        [subject addSessionsObject:session];
        
        
        
        //not associated with session directly but carries same ID's and should be created same time
        StorySet * storySet = (StorySet*)[NSEntityDescription
                                          insertNewObjectForEntityForName:@"StorySet"
                                          inManagedObjectContext:self.managedObjectContext];
        
        storySet.currentSessionID = [NSNumber numberWithInt:sessionNumber];
        storySet.subjectID = [NSNumber numberWithInt:subjectID];

        

        //save
        NSError *error = nil;
        
        if ( !  [self.managedObjectContext save:&error] ) {
            NSLog(@"An error! %@",error);
        }
        
    }
    

}


-(void)resetSegmentingTimesFor:(int)subjectID forTaskType:(NSString*)taskDescriptor inSession:(int)sessionID
{
    TaskType * taskType  = [self fetchTaskWithDescriptor:taskDescriptor forSubject:subjectID fromSession:sessionID];
    Trial * trial;
    int i;
    for(i=0; i<[taskType.trials count]; i++) {
        
        trial = [self fetchTrialWithIndex:i+1 forTaskType:taskDescriptor forSubject:subjectID fromSession:sessionID];
        trial.fineSliderEndTime = [NSNumber numberWithFloat:1];
        trial.fineSliderStartTime = [NSNumber numberWithFloat:0];
        
        trial.fineStartTime = [NSNumber numberWithFloat:-1];
        trial.fineStopTime = [NSNumber numberWithFloat:-1];
        
        trial.coarseSliderStartTime = [NSNumber numberWithFloat:0];

        trial.coarseStartTime = [NSNumber numberWithFloat:-1];
        trial.coarseStopTime = [NSNumber numberWithFloat:-1];
        
        trial.tag = [NSNumber numberWithInt:-1];
        trial.tagAnnotation = @"Type notes here";
        
        NSError *error = nil;
        
        if ( !  [self.managedObjectContext save:&error] ) {
            NSLog(@"An error! %@",error);
        }

    }
    
}

-(void)resetOnlyCoarseSegmentingTimesFor:(int)subjectID forTaskType:(NSString*)taskDescriptor inSession:(int)sessionID
{
    TaskType * taskType  = [self fetchTaskWithDescriptor:taskDescriptor forSubject:subjectID fromSession:sessionID];
    Trial * trial;
    int i;
    for(i=0; i<[taskType.trials count]; i++) {
        
        trial = [self fetchTrialWithIndex:i+1 forTaskType:taskDescriptor forSubject:subjectID fromSession:sessionID];
        
        trial.coarseSliderStartTime = [NSNumber numberWithFloat:0];
        
        trial.coarseStartTime = [NSNumber numberWithFloat:-1];
        trial.coarseStopTime = [NSNumber numberWithFloat:-1];
        
        NSError *error = nil;
        
        if ( !  [self.managedObjectContext save:&error] ) {
            NSLog(@"An error! %@",error);
        }
        
    }
    
}

-(void)resetSegmentingTimesForTrial:(int)trialIndex forTaskType:(NSString*)taskDescriptor forSession:(int)sessionID forSubject:(int)subjectID
{    
    Trial * trial = [self fetchTrialWithIndex:trialIndex forTaskType:taskDescriptor forSubject:subjectID fromSession:sessionID];
      
        trial.fineSliderEndTime = [NSNumber numberWithFloat:1];
        trial.fineSliderStartTime = [NSNumber numberWithFloat:0];
        
        trial.fineStartTime = [NSNumber numberWithFloat:-1];
        trial.fineStopTime = [NSNumber numberWithFloat:-1];
        
        trial.coarseSliderStartTime = [NSNumber numberWithFloat:0];
        
        trial.coarseStartTime = [NSNumber numberWithFloat:-1];
        trial.coarseStopTime = [NSNumber numberWithFloat:-1];
        
        trial.tag = [NSNumber numberWithInt:-1];
        trial.tagAnnotation = @"Type notes here";
        
        NSError *error = nil;
        
        if ( !  [self.managedObjectContext save:&error] ) {
            NSLog(@"An error! %@",error);
        }
}



-(NSString *)tagTranslatorForIntValue:(int)tag
{
    NSString * returnedString;
    if (tag==0) {
        returnedString = @"Good";
    }
    if (tag==1) {
        returnedString = @"Could Improve";
    }
    if (tag==2) {
        returnedString = @"Other";
    }
    if (tag==3) {
        returnedString = @"DELETED";
    }


    return returnedString;
}


-(void)saveArray:(NSArray*)compoundArray ToPlistForSubjectID:(int)subjectID ForCurrentSessionID:(int)currentSessionID
{
 
    //get new data
    
    NSMutableArray * currentSession = [[NSMutableArray alloc] init];
    int i;
    for (i=0; i<currentSessionID; i++) {

        NSLog(@"size of compound array %i", [compoundArray count]);
        [currentSession addObject:[compoundArray objectAtIndex:i]];
    }
    
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"StoryEditRecord.plist"]; //3
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    NSString * subjectKey = [@"Subject" stringByAppendingFormat:@"%i", subjectID];
    
    if ([[data allKeys] containsObject:subjectKey]) {

    
        NSArray * subjectAllSessionsHistory = [data objectForKey:subjectKey];
        
        
        NSMutableArray * copySubjectSessionHistory = [subjectAllSessionsHistory mutableCopy];
        
        //does this session exist yet
        if ([copySubjectSessionHistory count]>=currentSessionID) {
            
            NSLog(@"replacing with new currentSession compound array at index %i", currentSessionID-1);
            
            [copySubjectSessionHistory replaceObjectAtIndex:currentSessionID-1 withObject:currentSession];
        }
        else if ([copySubjectSessionHistory count]==currentSessionID-1){
            
            NSLog(@"adding new currentSession to the end");

            [copySubjectSessionHistory addObject:currentSession];
        }
        else{
            
            NSString * skipMessage = @"adding filler since session skipped";
            int i;
            for (i=[copySubjectSessionHistory count]; i<currentSessionID-1; i++) {
                
                NSLog(@"%@", skipMessage);
                [copySubjectSessionHistory addObject:skipMessage];

            }
            
            NSLog(@"adding new currentSession to the end");
            [copySubjectSessionHistory addObject:currentSession];
        }
        
        
        if ([[data allKeys] containsObject:subjectKey]) {

            [data setObject:copySubjectSessionHistory forKey:subjectKey];
            
            [data writeToFile:path atomically:YES];

        }
    }
    
}


-(BOOL)checkIfDataExistsForSubjectID:(int)subjectID ForCurrentSessionID:(int)currentSessionID
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"StoryEditRecord.plist"]; //3
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    NSString * subjectKey = [@"Subject" stringByAppendingFormat:@"%i", subjectID];
    
    
    if ([[data allKeys] containsObject:subjectKey]) {

        NSArray * subjectAllSessionsHistory = [data objectForKey:subjectKey];
        
        
        NSMutableArray * copySubjectSessionHistory = [subjectAllSessionsHistory mutableCopy];
        
        //does this session exist yet
        if ([copySubjectSessionHistory count]>=currentSessionID) {
                    
                if ([[copySubjectSessionHistory objectAtIndex:currentSessionID-1] isKindOfClass:[NSString class]]) {
                    NSLog(@"return NO - object class is type NSString");
                    return NO;
                }
                else{
                    if ([[copySubjectSessionHistory objectAtIndex:currentSessionID-1] count] < currentSessionID) {
                        NSLog(@"return NO - haven't added in this last session to history yet");
                        return NO;
                    }
                    else{
                        NSLog(@"return YES - session exists in array & object class is NOT type NSString");
                        return YES;
                    }
                }
            }
            else{ 
                
                NSLog(@"return NO - Entire session history hasn't been logged in plist yet");
                return NO;
            }
    }
    else{

        [data setObject:[[NSMutableArray alloc] init] forKey:subjectKey];
        [data writeToFile:path atomically:YES];

        NSLog(@"data doesn't exist");
        
        return NO;
    }
}

////new methods --------------------------------------


-(NSArray*)returnCompoundArrayFromPlistForSubjectID:(int)subjectID ForCurrentSessionID:(int)currentSessionID
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"StoryEditRecord.plist"]; //3
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    NSString * subjectKey = [@"Subject" stringByAppendingFormat:@"%i", subjectID];
    NSMutableArray * copyStoryIndicesCompoundArrayTemp;
    
    if ([[data allKeys] containsObject:subjectKey]) {
        
       NSArray * subjectAllSessionsHistory = [data objectForKey:subjectKey];
        
        //does this session exist yet
        if (!([subjectAllSessionsHistory count]>=currentSessionID)) {
            NSLog(@"This session was not logged in Plist - WTF");
    //        return 0;
        }
       
        
        //get compound array from plist
        NSArray * storyIndicesCompoundArray = [subjectAllSessionsHistory objectAtIndex:currentSessionID-1];
        
        //create new compound mutable array so you can replace each story index with its trial
        NSMutableArray * copyStoryIndicesCompoundArray = [storyIndicesCompoundArray mutableCopy];
        
                            //find storySet based on currentSessionID
                        //    StorySet* storySet = [self fetchStorySetForSession:currentSessionID forSubject:subjectID];
        
        int i;
        for (i=0; i<currentSessionID; i++) {
            
            NSMutableArray * singleSessionTrialsArray = [[NSMutableArray alloc] init];
            
                                //get individual story session
                        //        StorySession * returnedStorySession =[self fetchStorySession:i+1 fromStorySet:storySet];

            NSArray * singleSessionStoryInicesArray = [storyIndicesCompoundArray objectAtIndex:i];
            
            
            int j;
            for(j=0; j<[singleSessionStoryInicesArray count]; j++){
                
                            //            Trial * trial = [self fetchTrialWithStoryIndex:[[singleSessionStoryInicesArray objectAtIndex:j] intValue] forStorySession:returnedStorySession];
                
                Trial * trial = [self returnTrialForDescriptor:[singleSessionStoryInicesArray objectAtIndex:j]];

                if (trial) {
                    //insert into array individual session array
                    NSLog(@"trial fetched with tag %@ - task descriptor %@ - comment %@", [self tagTranslatorForIntValue:[trial.tag intValue]],  trial.taskType.descriptor, trial.tagAnnotation);
                    
                    [singleSessionTrialsArray addObject:trial];
                }
                else{
                    
                    NSLog(@"trial is nil FOR SECTION %i and descriptor: %@", i, [singleSessionStoryInicesArray objectAtIndex:j]);

                }
                
            }
            
            //insert into compound array
            [copyStoryIndicesCompoundArray replaceObjectAtIndex:i withObject:singleSessionTrialsArray];
        
        }
        
        copyStoryIndicesCompoundArrayTemp = copyStoryIndicesCompoundArray;
    }
    return copyStoryIndicesCompoundArrayTemp;
}





-(void)writeInitialBookmarkedDescriptorsToPlistForSession:(int)sessionID ForSubject:(int)subjectID
{
    int sCount;
    
    NSMutableArray * allSessionsArray = [[NSMutableArray alloc] init];

    
    for (sCount=0; sCount<sessionID; sCount++) {
        
        NSMutableArray *array1;
        
        array1 = [[self fetchTrialsWithBookMarkTag:0 forTaskType:@"graspCone" forSubject:subjectID fromSession:sCount+1] mutableCopy];
        
        int tag;
        for (tag=0; tag<3; tag++)
        {
            if (tag>0) {
                NSArray *arrayTemp1 = [self fetchTrialsWithBookMarkTag:tag forTaskType:@"graspCone" forSubject:subjectID fromSession:sCount+1];
                [array1 addObjectsFromArray:arrayTemp1];
            }
            
            NSArray *arrayTemp2 = [self fetchTrialsWithBookMarkTag:tag forTaskType:@"elevatedTouch" forSubject:subjectID fromSession:sCount+1];
            [array1 addObjectsFromArray:arrayTemp2];
            
            NSArray *arrayTemp3 = [self fetchTrialsWithBookMarkTag:tag forTaskType:@"transport" forSubject:subjectID fromSession:sCount+1];
            [array1 addObjectsFromArray:arrayTemp3];
        }
    
        
            NSMutableArray * singleSessionArray = [[NSMutableArray alloc] init];
            
            NSLog(@"session: %i trial count: %i", sCount+1, [array1 count]);
            
            int j;
            for (j=0; j<[array1 count]; j++) {
                
                Trial * trial = [array1 objectAtIndex:j];
                
                NSString * tag = [self tagTranslatorForIntValue:[trial.tag intValue]];
                
                NSString * savedDescriptor = [tag stringByAppendingFormat:@"_%@_trial%i_sub%i_sess%i", trial.taskType.descriptor, [trial.index intValue], subjectID, sCount+1];
                                                
                NSLog(@"%@ saved at position %i",savedDescriptor, j);
                
                [singleSessionArray insertObject:savedDescriptor atIndex:j];
            }
        
            [allSessionsArray addObject:singleSessionArray];
    }
    
    NSLog(@"allSessionsArray count is %i", [allSessionsArray count]);
    
   [self saveArray:allSessionsArray ToPlistForSubjectID:subjectID ForCurrentSessionID:sessionID];
    
}

-(Trial*)returnTrialForDescriptor:(NSString*)descriptor
{
    int trialNumber;
    int sessionID;
    int subjectID;
    NSString * tasktype;
    
    NSString *numberString;
    
    NSScanner *scanner = [NSScanner scannerWithString:descriptor];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    [scanner scanUpToString:@"trial" intoString:NULL];
    [scanner setScanLocation:[scanner scanLocation] + 1];

    // Throw away characters before the first number.
    [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
    
    // Collect numbers.
    [scanner scanCharactersFromSet:numbers intoString:&numberString];
    
    // Result.
    trialNumber = [numberString integerValue];
    
    
    
    [scanner scanUpToString:@"sub" intoString:NULL];
    [scanner setScanLocation:[scanner scanLocation] + 1];
    
    // Throw away characters before the first number.
    [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
    
    // Collect numbers.
    [scanner scanCharactersFromSet:numbers intoString:&numberString];
    
    // Result.
    subjectID = [numberString integerValue];
    
    
    [scanner scanUpToString:@"sess" intoString:NULL];
    [scanner setScanLocation:[scanner scanLocation] + 1];
    
    // Throw away characters before the first number.
    [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
    
    // Collect numbers.
    [scanner scanCharactersFromSet:numbers intoString:&numberString];
    
    // Result.
    sessionID = [numberString integerValue];

    
    if ([descriptor rangeOfString:@"grasp"].location != NSNotFound) tasktype = @"graspCone";
    if ([descriptor rangeOfString:@"elevated"].location != NSNotFound) tasktype = @"elevatedTouch";
    if ([descriptor rangeOfString:@"transport"].location != NSNotFound) tasktype = @"transport";

    
//    NSLog(@"subject %i session %i trialNum %i", subjectID, sessionID, trialNumber);

    return [self fetchTrialWithIndex:trialNumber forTaskType:tasktype forSubject:subjectID fromSession:sessionID];
    
}


//[self.dataController deleteSessionNumber:indexPath.row+1 forSubject:indexPath.section+1];

-(void)deleteSessionNumber:(int)sessionID forSubject:(int)subjectID
{
    Subject * subject = [self fetchSubjectWithID:subjectID];
    
    Session * session = [self fetchSessionNumber:sessionID forSubject:subjectID];
   
    [subject removeSessionsObject:session];

    //save
    NSError *error = nil;
    
    if ( !  [self.managedObjectContext save:&error] ) {
        NSLog(@"An error! %@",error);
    }

}


@end

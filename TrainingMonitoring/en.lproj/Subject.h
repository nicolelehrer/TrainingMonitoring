//
//  Subject.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 10/5/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

@interface Subject : NSManagedObject

@property (nonatomic, retain) NSNumber * subjectID;
@property (nonatomic, retain) NSNumber * studySubjectID;
@property (nonatomic, retain) NSSet *sessions;
@end

@interface Subject (CoreDataGeneratedAccessors)

- (void)addSessionsObject:(Session *)value;
- (void)removeSessionsObject:(Session *)value;
- (void)addSessions:(NSSet *)values;
- (void)removeSessions:(NSSet *)values;

@end

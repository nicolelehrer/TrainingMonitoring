//
//  SurveyAnswer.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 3/26/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

@interface SurveyAnswer : NSManagedObject

@property (nonatomic, retain) NSNumber * answerValue;
@property (nonatomic, retain) NSString * followUp;
@property (nonatomic, retain) NSNumber * questionIndex;
@property (nonatomic, retain) Session *session;

@end

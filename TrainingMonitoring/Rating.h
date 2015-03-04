//
//  Rating.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 10/7/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trial;

@interface Rating : NSManagedObject

@property (nonatomic, retain) NSNumber * compensationScore;
@property (nonatomic, retain) NSNumber * manipulationScore;
@property (nonatomic, retain) NSNumber * ratingOrderIndex;
@property (nonatomic, retain) NSNumber * overallScoreFinal;
@property (nonatomic, retain) NSNumber * overallScoreInitial;
@property (nonatomic, retain) NSNumber * releaseScore;
@property (nonatomic, retain) NSString * scoreChangeAnnotation;
@property (nonatomic, retain) NSNumber * trajectoryScore;
@property (nonatomic, retain) NSNumber * transportScore;
@property (nonatomic, retain) Trial *trial;

@end

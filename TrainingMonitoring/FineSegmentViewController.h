//
//  FineSegmentViewController.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/13/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import "AVMovieViewController.h"

@interface FineSegmentViewController : AVMovieViewController <UITextViewDelegate>
@property (assign, nonatomic) int sessionID;
@property (assign, nonatomic) int subjectID;
@property (assign, nonatomic) int numTrials;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSString * taskDescriptor;
@property (nonatomic, assign) float initialLeftSliderVal;
@property (nonatomic, assign) float initialRightSliderVal;
@property(nonatomic, assign) int trialCounter;

@property (nonatomic, retain) NSString* commentString;
@property (nonatomic, assign) BOOL doShowComment;

@property(nonatomic, retain) NSMutableArray * bookmarkedTrials;

@property(nonatomic, assign) int rowIndexComingFromShareProg;
@property(nonatomic, assign) int sectionIndexComingFromShareProg;

@end

//
//  CoarseSegmentViewController.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/13/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVMovieViewController.h"

@interface CoarseSegmentViewController : AVMovieViewController
@property (assign, nonatomic) int sessionID;
@property (assign, nonatomic) int subjectID;
@property (assign, nonatomic) int numTrials;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSString * taskDescriptor;
@property (assign, nonatomic) int markerCounter;
@property (assign, nonatomic) BOOL allowFreePlacement;
@end

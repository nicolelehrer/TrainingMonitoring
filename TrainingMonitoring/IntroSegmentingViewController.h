//
//  IntroSegmentingViewController.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/13/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroSegmentingViewController : UIViewController
@property (assign, nonatomic) int sessionID;
@property (assign, nonatomic) int subjectID;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

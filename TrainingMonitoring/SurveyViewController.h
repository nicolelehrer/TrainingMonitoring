//
//  SurveyViewController.h
//  ClinicianAssist
//
//  Created by Nicole Lehrer on 2/19/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SurveyViewController : UIViewController <UITextViewDelegate>
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(assign, nonatomic) int sessionID;
@property(assign, nonatomic) int subjectID;

@end

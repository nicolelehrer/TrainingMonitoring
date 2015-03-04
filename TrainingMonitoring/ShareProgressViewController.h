//
//  ShareProgressViewController.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 5/1/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareProgressViewController : UITableViewController

@property (assign, nonatomic) int sessionID;
@property (assign, nonatomic) int subjectID;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) BOOL updateFromPlist;
@end
//
//  StoryViewController.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/14/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryViewController : UITableViewController
@property (assign, nonatomic) int sessionID;
@property (assign, nonatomic) int subjectID;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) BOOL updateFromPlist;
@end

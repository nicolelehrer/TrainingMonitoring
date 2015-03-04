//
//  MainTableViewController.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 3/25/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTableViewController : UITableViewController
@property(nonatomic, assign) int subjectID;
@property(nonatomic, assign) int sessionID;
@property(nonatomic, retain) NSManagedObjectContext * managedObjectContext;
@end

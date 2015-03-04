//
//  SubjectTableViewController.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 3/26/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"


@interface SubjectTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

//
//  CaptureTaskViewController.h
//  ClinicianAssistant
//
//  Created by Nicole Lehrer on 12/26/12.
//  Copyright (c) 2012 Nicole Lehrer. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "TaskController.h"
#import "TaskType.h"



@interface CaptureTaskViewController : UIViewController 


@property(assign, nonatomic) int sessionID;
@property(assign, nonatomic) int subjectID;
@property(retain, nonatomic) NSString * firstTaskDescriptor;



//@property(retain) TaskController * gTaskController;
@property (retain) NSString * stringForTitle;
@property (retain) NSString * stringForInstruction;
@property (assign) int currentTaskType;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


//-(void) setTaskController:(TaskController *)taskController;

@property (nonatomic, retain) TaskType * graspCone;
@property (nonatomic, retain) TaskType * elevatedTouch;
@property (nonatomic, retain) TaskType * transport1;
@property (nonatomic, retain) TaskType * transport2;

@end

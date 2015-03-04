//
//  IntroSegmentingViewController.m
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/13/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import "IntroSegmentingViewController.h"
#import "DataController.h"
#import "AppDelegate.h"
#import "CoarseSegmentViewController.h"
#import "TaskType.h"

@interface IntroSegmentingViewController ()
@property (retain, nonatomic) DataController * dataController;
@end

@implementation IntroSegmentingViewController
@synthesize sessionID = _sessionID;
@synthesize subjectID = _subjectID;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize dataController = _dataController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.dataController = [[DataController alloc] init];
    self.dataController.managedObjectContext = self.managedObjectContext;
    
    
    self.title = @"Segment Videos";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        
    if ([[segue identifier] isEqualToString:@"SegmentCone"]) {
                
        CoarseSegmentViewController * coarseSegmentVC = segue.destinationViewController;
        
        
        coarseSegmentVC.taskDescriptor = @"graspCone";
        TaskType * taskType = [self.dataController fetchTaskWithDescriptor:coarseSegmentVC.taskDescriptor forSubject:self.subjectID fromSession:self.sessionID];
    
        coarseSegmentVC.movieURL = [NSURL URLWithString:taskType.movieURLString];
        coarseSegmentVC.numTrials = [taskType.trials count];
        
        coarseSegmentVC.subjectID = self.subjectID;
        coarseSegmentVC.sessionID = self.sessionID;

    }
    
    if ([[segue identifier] isEqualToString:@"SegmentTouch"]) {
        
        CoarseSegmentViewController * coarseSegmentVC = segue.destinationViewController;
        
        
        coarseSegmentVC.taskDescriptor = @"elevatedTouch";
        TaskType * taskType = [self.dataController fetchTaskWithDescriptor:coarseSegmentVC.taskDescriptor forSubject:self.subjectID fromSession:self.sessionID];
        
        coarseSegmentVC.movieURL = [NSURL URLWithString:taskType.movieURLString];
        coarseSegmentVC.numTrials = [taskType.trials count];
        
        coarseSegmentVC.subjectID = self.subjectID;
        coarseSegmentVC.sessionID = self.sessionID;
        
    }
    
    if ([[segue identifier] isEqualToString:@"SegmentTransport"]) {
        
        CoarseSegmentViewController * coarseSegmentVC = segue.destinationViewController;
        
        
        coarseSegmentVC.taskDescriptor = @"transport";
        TaskType * taskType = [self.dataController fetchTaskWithDescriptor:coarseSegmentVC.taskDescriptor forSubject:self.subjectID fromSession:self.sessionID];
        
        coarseSegmentVC.movieURL = [NSURL URLWithString:taskType.movieURLString];
        coarseSegmentVC.numTrials = [taskType.trials count];
        
        coarseSegmentVC.subjectID = self.subjectID;
        coarseSegmentVC.sessionID = self.sessionID;
        
    }
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

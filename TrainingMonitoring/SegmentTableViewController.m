//
//  SegmentTableViewController.m
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/19/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import "SegmentTableViewController.h"
#import "DataController.h"
#import "AppDelegate.h"
#import "CoarseSegmentViewController.h"
#import "TaskType.h"
#import "Trial.h"
#import "FineSegmentViewController.h"

@interface SegmentTableViewController ()
@property (retain, nonatomic) DataController * dataController;
@property (retain, nonatomic) NSArray * taskSectionNames;
@property (retain, nonatomic) NSArray * taskCoarseTrials;
@property (retain, nonatomic) NSArray * coarseSegueDescriptors;

@property (assign, nonatomic) BOOL hasDoneCoarseSegmenting;

@property (retain, nonatomic) NSDictionary * taskDict;

@property (nonatomic, assign) int rowSelectedForTrial;
@property (nonatomic, assign) int headerWidth;

@end

@implementation SegmentTableViewController
@synthesize sessionID = _sessionID;
@synthesize subjectID = _subjectID;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize dataController = _dataController;
@synthesize taskSectionNames = _taskSectionNames;
@synthesize coarseSegueDescriptors = _coarseSegueDescriptors;
@synthesize hasDoneCoarseSegmenting = _hasDoneCoarseSegmenting;

@synthesize taskDict = _taskDict;
@synthesize rowSelectedForTrial = _rowSelectedForTrial;

@synthesize headerWidth = _headerWidth;



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkIfDidFinishCoarseSegment:)
                                                 name:@"didFinishCoarseSegment"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkIfDidChangeFine:)
                                                 name:@"didChangeFine"
                                               object:nil];
    
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.dataController = [[DataController alloc] init];
    self.dataController.managedObjectContext = self.managedObjectContext;
    
        
    self.taskSectionNames = [NSArray arrayWithObjects:@"Grasp cone", @"Elevated touch", @"Transport", nil];

    self.coarseSegueDescriptors = [NSArray arrayWithObjects:@"GraspCone", @"ElevatedTouch", @"Transport", nil];


    NSArray *objects = [NSArray arrayWithObjects:[self returnArrayForTaskType:@"graspCone"],
                                                [self returnArrayForTaskType:@"elevatedTouch"],
                                                [self returnArrayForTaskType:@"transport"], nil];
    
    self.taskDict = [[NSDictionary alloc] initWithObjects:objects forKeys:self.taskSectionNames];
    

    [self makeCustomToolBarTitleWithString:@"Segment videos"];
    
    NSLog(@"count of dict is %i", [self.taskDict count]);
    

    if (self.interfaceOrientation != UIInterfaceOrientationPortrait)
    {
        [self showAlertView];
    }
    
    
}

-(void)viewWillLayoutSubviews{

    self.headerWidth = self.tableView.frame.size.width;

}

- (void)showAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"IPad orientation"
                                                    message:@"Please make sure the iPad is oriented vertically for best viewing."
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)doManualReset:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Start segmenting from scratch"]
                                                    message:@"Are you sure you want to start segmenting from scratch?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Reset Cone", @"Reset Touch", @"Reset Transport", nil];
    
    alert.tag = 1;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        NSLog(@"resetting cone");
        
        [self.dataController resetSegmentingTimesFor:self.subjectID forTaskType:@"graspCone" inSession:self.sessionID];
        [self.tableView reloadData];
    }
    if (buttonIndex == 2) {
        
        NSLog(@"resetting touch");
        
        [self.dataController resetSegmentingTimesFor:self.subjectID forTaskType:@"elevatedTouch" inSession:self.sessionID];
        [self.tableView reloadData];
    }
    if (buttonIndex == 3) {
        
        NSLog(@"resetting transport");
        
        [self.dataController resetSegmentingTimesFor:self.subjectID forTaskType:@"transport" inSession:self.sessionID];
        [self.tableView reloadData];
    }
}


-(void)makeCustomToolBarTitleWithString:(NSString*)titleString
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:28];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.text = titleString;
    
    self.navigationItem.titleView = label;
}




-(NSArray*)returnArrayForTaskType:(NSString *)taskDescriptor
{
    TaskType * taskType = [self.dataController fetchTaskWithDescriptor:taskDescriptor forSubject:self.subjectID fromSession:self.sessionID];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSArray * array = [taskType.trials sortedArrayUsingDescriptors:sortDescriptorArray];
    
    int i;
    for (i=0; i<[array count]; i++) {
        Trial * trial = [array objectAtIndex:i];
        NSLog(@"%@ object at index %i is trial %i", taskDescriptor, i, [trial.index intValue]);
    }
    
    return array;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) checkIfDidFinishCoarseSegment:(NSNotification *) notification
{
    NSLog(@"coarse notification called");

    NSString * descriptorString = [notification object];
    
    NSLog(@"string is %@", descriptorString);
    
    [self.tableView reloadData];
}

- (void) checkIfDidChangeFine:(NSNotification *) notification
{
    NSLog(@"fine notification called");
    
    [self.tableView reloadData];
}

- (IBAction)celarVals:(id)sender {
    
    [self.dataController resetSegmentingTimesFor:self.subjectID forTaskType:@"transport" inSession:self.sessionID];
    
    NSLog(@"data clear");
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.taskSectionNames count];
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle;// = [self.taskSectionNames objectAtIndex:section];
    
    
    NSArray * trials = [self.taskDict objectForKey:[self.taskSectionNames objectAtIndex:section]];
    
    for (Trial * trial in trials) {
        if ([trial.coarseStartTime floatValue] == -1) {
            sectionTitle = [self.taskSectionNames objectAtIndex:section];

        }
        else{
            NSString * temp = [self.taskSectionNames objectAtIndex:section];
            sectionTitle = [temp stringByAppendingString:@": Review each trial individually"];

        }
    }
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, self.headerWidth, 35);
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font =  [UIFont systemFontOfSize:18];
    ///[UIFont fontWithName:@"Helvetica" size:20];
    label.text = sectionTitle;
    label.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.headerWidth, 100)];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * trials = [self.taskDict objectForKey:[self.taskSectionNames objectAtIndex:section]];
    
    int count;
    for (Trial * trial in trials) {
        if ([trial.coarseStartTime floatValue]<0) {
            count = 1;
        }
        else {
            count = [trials count];
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSArray * trials = [self.taskDict objectForKey:[self.taskSectionNames objectAtIndex:indexPath.section]];
    
    for (Trial * trial in trials) {
        if ([trial.coarseStartTime floatValue] == -1) {
            cell.textLabel.text = [NSString stringWithFormat:@"Segment %@", [self.taskSectionNames objectAtIndex:indexPath.section]];
        }
        else {
            Trial * trial = [trials objectAtIndex:indexPath.row];
            
            if ([trial.tag intValue]>=0) {
                cell.textLabel.text = [NSString stringWithFormat:@"Trial %i - %@", [trial.index intValue], [self.dataController tagTranslatorForIntValue:[trial.tag intValue]]];
            }
            else{
                cell.textLabel.text = [NSString stringWithFormat:@"Trial %i", [trial.index intValue]];
            }
            
            if ([trial.fineStartTime floatValue] != -1 && [trial.fineStopTime floatValue] != -1 ) {
                
                cell.imageView.image = [UIImage imageNamed:@"Checkmark.png"];
                
            }
            else{
                cell.imageView.image = nil;
            }
        }
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    int numRowsForSection = [self.tableView numberOfRowsInSection:indexPath.section];
    NSLog(@"numRowsForSection is %i", numRowsForSection);
    
    if (numRowsForSection > 1) {
        
        NSString * fineSegueDescriptor = [@"Fine" stringByAppendingString:[self.coarseSegueDescriptors objectAtIndex:indexPath.section]];

        NSLog(@"fineSegueDescriptor is %@", fineSegueDescriptor);
        self.rowSelectedForTrial = indexPath.row+1;
        NSLog(@"self.rowSelectedForTrial in didSelectRowForPath %i", self.rowSelectedForTrial);

        [self performSegueWithIdentifier:fineSegueDescriptor sender:indexPath];
    }
    else {
     [self performSegueWithIdentifier:[self.coarseSegueDescriptors objectAtIndex:indexPath.section] sender:indexPath];
    }
   
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [self handleCoarseSegue:segue WithSegueDescriptor:@"GraspCone" forTask:@"graspCone"];
    [self handleCoarseSegue:segue WithSegueDescriptor:@"ElevatedTouch" forTask:@"elevatedTouch"];
    [self handleCoarseSegue:segue WithSegueDescriptor:@"Transport" forTask:@"transport"];
    
    [self handleFineSegue:segue WithSegueDescriptor:@"FineGraspCone" forTask:@"graspCone"];
    [self handleFineSegue:segue WithSegueDescriptor:@"FineElevatedTouch" forTask:@"elevatedTouch"];
    [self handleFineSegue:segue WithSegueDescriptor:@"FineTransport" forTask:@"transport"];
    
}


-(void) handleCoarseSegue:(UIStoryboardSegue *)segue WithSegueDescriptor:(NSString*)segueDescriptor forTask:(NSString *)taskDescriptor
{
    if ([[segue identifier] isEqualToString:segueDescriptor]) {

        CoarseSegmentViewController * coarseSegmentVC = segue.destinationViewController;
        
        coarseSegmentVC.taskDescriptor = taskDescriptor;
        TaskType * taskType = [self.dataController fetchTaskWithDescriptor:coarseSegmentVC.taskDescriptor forSubject:self.subjectID fromSession:self.sessionID];
        
        coarseSegmentVC.movieURL = [NSURL URLWithString:taskType.movieURLString];
        coarseSegmentVC.numTrials = [taskType.trials count];
        
        coarseSegmentVC.subjectID = self.subjectID;
        coarseSegmentVC.sessionID = self.sessionID;
        coarseSegmentVC.markerCounter = 0;
    }

}


-(void) handleFineSegue:(UIStoryboardSegue *)segue WithSegueDescriptor:(NSString*) segueDescriptor forTask:(NSString *)taskDescriptor
{
    if ([[segue identifier] isEqualToString:segueDescriptor]) {
        
        
        FineSegmentViewController * fineSegmentVC = segue.destinationViewController;
        
        fineSegmentVC.taskDescriptor = taskDescriptor;
        
        TaskType * taskType = [self.dataController fetchTaskWithDescriptor:fineSegmentVC.taskDescriptor forSubject:self.subjectID fromSession:self.sessionID];
        
        fineSegmentVC.movieURL = [NSURL URLWithString:taskType.movieURLString];
        fineSegmentVC.numTrials = [taskType.trials count];
        
        fineSegmentVC.subjectID = self.subjectID;
        fineSegmentVC.sessionID = self.sessionID;
        
        Trial * trial = [self.dataController fetchTrialWithIndex:self.rowSelectedForTrial
                                                     forTaskType:fineSegmentVC.taskDescriptor
                                                      forSubject:fineSegmentVC.subjectID
                                                     fromSession:fineSegmentVC.sessionID];
        
        NSLog(@"self.rowSelectedForTrial in prepare segue is %i", self.rowSelectedForTrial);
        fineSegmentVC.trialCounter = self.rowSelectedForTrial;
        
        if ([trial.fineStartTime floatValue] != -1 && [trial.fineStopTime floatValue] != -1){
            
            fineSegmentVC.newStartTime = CMTimeMakeWithSeconds([trial.fineStartTime floatValue], 600);
            fineSegmentVC.initialLeftSliderVal = [trial.fineSliderStartTime floatValue];
            
            fineSegmentVC.newStopTime = CMTimeMakeWithSeconds([trial.fineStopTime floatValue], 600);
            fineSegmentVC.initialRightSliderVal = [trial.fineSliderEndTime floatValue];
        }
        else{ //if you have not, then use the coarse time stamps
            fineSegmentVC.newStartTime = CMTimeMakeWithSeconds([trial.coarseStartTime floatValue], 600);
            fineSegmentVC.initialLeftSliderVal = 0;
            
            fineSegmentVC.newStopTime = CMTimeMakeWithSeconds([trial.coarseStopTime floatValue], 600);
            fineSegmentVC.initialRightSliderVal = 1.0;
        }
        
        fineSegmentVC.startSliderTime =  fineSegmentVC.newStartTime;
        fineSegmentVC.endSliderTime =  fineSegmentVC.newStopTime;
        
    }

}

-(void)viewWillDisappear:(BOOL)animated{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"segmentDone" object:nil];
    
    [self.dataController writeInitialBookmarkedDescriptorsToPlistForSession:self.sessionID ForSubject:self.subjectID];
    
    [super viewWillDisappear:YES];

}




- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}




@end

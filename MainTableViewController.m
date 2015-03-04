//
//  MainTableViewController.m
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 3/25/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import "MainTableViewController.h"
#import "DataController.h"
#import "CaptureTaskViewController.h"
#import "SurveyViewController.h"
#import "StoryViewController.h"
#import "SegmentTableViewController.h"
#import "StorySet.h"
#import "SurveyAnswer.h"
#import "Trial.h"

@interface MainTableViewController ()
@property (nonatomic, retain) DataController * dataController;
@property (nonatomic, retain) NSArray * sessionSteps;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *readyToEditStoryBarButton;

@end

@implementation MainTableViewController
@synthesize sessionID = _sessionID;
@synthesize subjectID = _subjectID;
@synthesize dataController = _dataController;
@synthesize sessionSteps = _sessionSteps;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize readyToEditStoryBarButton = _readyToEditStoryBarButton;

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkIfTaskMonitoringDone:)
                                                 name:@"taskMonitoringDone"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkIfSurveyDone:)
                                                 name:@"surveyDone"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkIfStoryDone:)
                                                 name:@"storyDone"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkIfSegmentDone:)
                                                 name:@"segmentDone"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkIfSharedStoryDone:)
                                                 name:@"sharedStoryDone"
                                               object:nil];
    
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;

    
    self.dataController = [[DataController alloc] init];
    self.dataController.managedObjectContext = self.managedObjectContext;

    //if first session, no video story yet
    
   
    if (self.sessionID==1) {
         self.sessionSteps = [NSArray arrayWithObjects:
                              @"1. Administer training monitoring tasks",
                              @"2. Administer system experience questionnaire",
                              @"3. Segment Videos",
                              @"4. Create story for next week", nil];
    }
    else{
        self.sessionSteps = [NSArray arrayWithObjects:
                             @"1. Administer training monitoring tasks",
                             @"2. Administer system experience questionnaire",
                             @"3. Share videos from previous sessions",
                             @"4. Segment videos from this session",
                             @"5. Edit shared videos for next week", nil];
    }
     
    [self makeCustomToolBarTitleWithString:self.title];
    
}

-(void)makeCustomToolBarTitleWithString:(NSString*)titleString
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:28];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.text = titleString;
    
    self.navigationItem.titleView = label;
}



- (void) checkIfTaskMonitoringDone:(NSNotification *) notification
{    
    [self.tableView reloadData];

}

- (void) checkIfSurveyDone:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void) checkIfSegmentDone:(NSNotification *) notification
{    
    [self.tableView reloadData];
}


- (void) checkIfStoryDone:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void) checkIfSharedStoryDone:(NSNotification *) notification
{
    [self.tableView reloadData];
}

-(BOOL)areAllTrialsSegmentedForTaskWithDescriptor:(NSString*)taskDescriptor forSession:(int)sessionID
{
    TaskType * task = [self.dataController fetchTaskWithDescriptor:taskDescriptor forSubject:self.subjectID fromSession:sessionID];
    
    int numComplete = 0;
    
    int i;
    for (i=0; i<[task.numTrials intValue]; i++){
        
        Trial * trial = [self.dataController fetchTrialWithIndex:i+1 forTaskType:taskDescriptor forSubject:self.subjectID fromSession:sessionID];
        
        if ([trial.fineStartTime floatValue] != -1 && [trial.fineStopTime floatValue] != -1) {
            numComplete++;
        }
    }
    
//    NSLog(@"numComplete for %@ = %i", taskDescriptor, numComplete);
    
    if (numComplete==[task.numTrials intValue]) {
        return YES;
    }
    else{
        return NO;
    }
    
}



-(void)updateImageForCell:(int)indexRowPath
{
    NSLog(@" suvey bool is true");
    
    NSArray *visible = [self.tableView indexPathsForVisibleRows];
    NSIndexPath *indexpath = (NSIndexPath*)[visible objectAtIndex:indexRowPath];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexpath];
    
    cell.imageView.image = [UIImage imageNamed:@"Checkmark.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.sessionSteps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.text = [self.sessionSteps objectAtIndex:indexPath.row];
    
    int segmentingRow;
    int storyEditRow;
    
    BOOL thereIsStoryToShow = NO;
    
    if (self.sessionID==1) {
        segmentingRow=2;
        storyEditRow=3;
    }
    else{
        segmentingRow=3;
        storyEditRow=4;
        thereIsStoryToShow = YES;
    }
    
    if ((indexPath.row == 0 && [self checkIfTaskMonitoringComplete]) ||
        (indexPath.row == 1 && [self checkIfAllSurveyComplete]) ||
        (indexPath.row == segmentingRow && [self checkIfSegmentIsCompleteForSession:self.sessionID]) ||
        (indexPath.row == storyEditRow && [self checkIfStoryEditComplete]) ||
        (indexPath.row == 2 && thereIsStoryToShow && [self checkIfStorySharedComplete])) {
            cell.imageView.image = [UIImage imageNamed:@"Checkmark.png"];
            NSLog(@"index path is %i", indexPath.row);
    }
    else{
        cell.imageView.image = nil;
    }
    
    if (indexPath.row == [self.sessionSteps count]-1){
        if ([self checkIfSegmentIsCompleteForSession:self.sessionID]){
            cell.userInteractionEnabled = YES;
            cell.textLabel.textColor = [UIColor blackColor];            
        }else{
            cell.userInteractionEnabled = NO;
            cell.textLabel.textColor = [UIColor grayColor];
        }
    }
    
    if (indexPath.row == [self.sessionSteps count]-2){
        if ([self checkIfTaskMonitoringComplete]){
            cell.userInteractionEnabled = YES;
            cell.textLabel.textColor = [UIColor blackColor];
        }else{
            cell.userInteractionEnabled = NO;
            cell.textLabel.textColor = [UIColor grayColor];
        }
    }
    
    if (self.sessionID > 1 && indexPath.row == [self.sessionSteps count]-3){
        if ([self checkIfSegmentIsCompleteForSession:self.sessionID-1]){
            cell.userInteractionEnabled = YES;
            cell.textLabel.textColor = [UIColor blackColor];
        }else{
            cell.userInteractionEnabled = NO;
            cell.textLabel.textColor = [UIColor grayColor];
        }
    }
    

    return cell;
}

-(BOOL)checkIfAllSurveyComplete
{
    BOOL allMCAnswered = NO;
    BOOL lastQuestionAnswered = NO;
    
    Session* session = [self.dataController fetchSessionNumber:self.sessionID forSubject:self.subjectID];
    
    int i;
    for (i=0; i<[session.surveyAnswer count]; i++) {
        
        SurveyAnswer * sa = [self.dataController fetchSurveyAnswerWithIndex:i+1 forSubject:self.subjectID fromSession:self.sessionID];
        
        if (i<[session.surveyAnswer count]-1) {
//            NSLog(@"question %i answer is %i", i+1, [sa.answerValue intValue]);
            if ([sa.answerValue intValue]== -1) {
                allMCAnswered = NO;
            }
            else{
                allMCAnswered = YES;
            }
        }
        if(i==[session.surveyAnswer count]-1){
            
            if ([sa.followUp isEqualToString:@"Type annotation text here"] || [sa.followUp isEqualToString:@""]) {
//                NSLog(@"no follow up on last question");
                lastQuestionAnswered = NO;
            }
            else{
                lastQuestionAnswered = YES;
            }
        }
    }
    if (lastQuestionAnswered && allMCAnswered) {
        NSLog(@"yes");
        return YES;
    }
    else{
        NSLog(@"no");
        return  NO;
    }
}

-(BOOL)checkIfStoryEditComplete
{
    Session* session = [self.dataController fetchSessionNumber:self.sessionID forSubject:self.subjectID];
    return [session.finishedStory boolValue];
}

-(BOOL)checkIfStorySharedComplete
{
    Session* session = [self.dataController fetchSessionNumber:self.sessionID forSubject:self.subjectID];
    return [session.sharedStory boolValue];
}

-(BOOL)checkIfTaskMonitoringComplete
{
    TaskType * task1 = [self.dataController fetchTaskWithOrder:1 forSubject:self.subjectID fromSession:self.sessionID];
    TaskType * task2 = [self.dataController fetchTaskWithOrder:2 forSubject:self.subjectID fromSession:self.sessionID];
    TaskType * task3 = [self.dataController fetchTaskWithOrder:3 forSubject:self.subjectID fromSession:self.sessionID];

    if (task1.movieURLString && task2.movieURLString && task3.movieURLString){
        return YES;
    }
    else{
        return NO;
    }
}

-(BOOL)checkIfSegmentIsCompleteForSession:(int)sessionID
{
    if ([self areAllTrialsSegmentedForTaskWithDescriptor:@"graspCone" forSession:sessionID]
        && [self areAllTrialsSegmentedForTaskWithDescriptor:@"elevatedTouch" forSession:sessionID]
        && [self areAllTrialsSegmentedForTaskWithDescriptor:@"transport" forSession:sessionID]){
        return YES;
    }
    else{
        return NO;
    }

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //not passing self.managedObjectContext; getting directly from appDelegate

    
    if ([[segue identifier] isEqualToString:@"CaptureTask"]) {
        CaptureTaskViewController * captureVC = segue.destinationViewController;
        captureVC.subjectID = self.subjectID;
        captureVC.sessionID = self.sessionID;
        captureVC.currentTaskType = 1;
        }
    
    if ([[segue identifier] isEqualToString:@"Survey"]) {
        SurveyViewController * surveyVC = segue.destinationViewController;
        surveyVC.subjectID = self.subjectID;
        surveyVC.sessionID = self.sessionID;
    }
    
    if ([[segue identifier] isEqualToString:@"Segment"]) {
        SegmentTableViewController * segVC = segue.destinationViewController;
        segVC.subjectID = self.subjectID;
        segVC.sessionID = self.sessionID;
        
//        [self.dataController resetSegmentingTimesFor:1 forTaskType:@"graspCone" inSession:2];

        

    }
    
    if ([[segue identifier] isEqualToString:@"CreateStory"]) {
        StoryViewController * storyVC = segue.destinationViewController;
        storyVC.subjectID = self.subjectID;
        storyVC.sessionID = self.sessionID;
        

        if (![self.dataController checkIfDataExistsForSubjectID:self.subjectID ForCurrentSessionID:self.sessionID]) {
            
            NSLog(@"saveInitialStorySetForSession is called");
            storyVC.updateFromPlist = NO;
            
            [self.dataController writeInitialBookmarkedDescriptorsToPlistForSession:self.sessionID ForSubject:self.subjectID];
            
        }//also calling this in viewWillDisapper inside segmentTableViewController so that if they go back and edit videos it will resave plist - this will in effect delete any edits that were made in storyViewTable

    }
    
    if ([[segue identifier] isEqualToString:@"Progress"]) {
        StoryViewController * storyVC = segue.destinationViewController;
        storyVC.subjectID = self.subjectID;
        storyVC.sessionID = self.sessionID;
        
        
        if (![self.dataController checkIfDataExistsForSubjectID:self.subjectID ForCurrentSessionID:self.sessionID]) {
            
            NSLog(@"saveInitialStorySetForSession is called");
            storyVC.updateFromPlist = NO;
            
//            [self.dataController writeInitialBookmarkedDescriptorsToPlistForSession:self.sessionID ForSubject:self.subjectID];
            
        }//also calling this in viewWillDisapper inside segmentTableViewController so that if they go back and edit videos it will resave plist - this will in effect delete any edits that were made in storyViewTable
        
    }

    
}




-(BOOL)returnStoryRecordForSubject:(int)subjectID forSession:(int)sessionID
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"StoryEditRecord.plist"]; //3
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    NSString * subjectKey = [@"Subject" stringByAppendingFormat:@"%i", subjectID];
    
    NSNumber* boolNumber = [[data objectForKey:subjectKey] objectAtIndex:sessionID-1];

//    NSLog(@"from returnStoryRecord %@", [boolNumber boolValue] ?  @"YES":@"NO");
    return [boolNumber boolValue];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"CaptureTask" sender:indexPath];
    }
    
    if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"Survey" sender:indexPath];
    }
    
    if (self.sessionID==1) {
        
        if (indexPath.row == 2) {
            [self performSegueWithIdentifier:@"Segment" sender:indexPath];
        }
        if (indexPath.row == 3) {
            [self performSegueWithIdentifier:@"CreateStory" sender:indexPath];
        }
        
    }
    else{
    
        if (indexPath.row == 2) {
            [self performSegueWithIdentifier:@"Progress" sender:indexPath];
        }
        if (indexPath.row == 3) {
            [self performSegueWithIdentifier:@"Segment" sender:indexPath];
        }
        if (indexPath.row == 4) {
            [self performSegueWithIdentifier:@"CreateStory" sender:indexPath];
        }

    }
    


}



-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"percentDone" object:nil];

    
}

@end

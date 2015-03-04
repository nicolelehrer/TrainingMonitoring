//
//  SubjectTableViewController.m
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 3/26/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import "SubjectTableViewController.h"
#import "DataController.h"
#import "MainTableViewController.h"
#import "Session.h"
#import "SurveyAnswer.h"
#import "Subject.h"
#import "Constants.h"
#import "Trial.h"


@interface SubjectTableViewController ()

@property (nonatomic, retain) NSMutableArray * subjectIDs;
@property (nonatomic, retain) DataController * dataController;
@property (nonatomic, retain) NSMutableArray * displayCounts;
@property (nonatomic, retain) NSIndexPath * indexPathToBeDeleted;
@property (nonatomic, retain) NSIndexPath * indexPathToSegueFrom;

@property (nonatomic, assign) int subjectCount;
@property (nonatomic, retain) NSString * segueID;
@property (nonatomic, assign) float headerWidth;

@property (nonatomic, retain) NSMutableArray * cellNames;
@property (nonatomic, retain) NSMutableArray * toDoArray;

@end

@implementation SubjectTableViewController
@synthesize managedObjectContext = _managedObjectContext;

@synthesize subjectIDs = _subjectIDs;

@synthesize dataController = _dataController;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize displayCounts = _displayCounts;

@synthesize indexPathToBeDeleted = _indexPathToBeDeleted;
@synthesize indexPathToSegueFrom = _indexPathToSegueFrom;

@synthesize subjectCount = _subjectCount;

@synthesize segueID = _segueID;
@synthesize headerWidth = _headerWidth;
@synthesize cellNames = _cellNames;
@synthesize toDoArray = _toDoArray;


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
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self createCustomModel];
      
    //there's a reason for doing this ??
    self.subjectCount = INITIAL_SUBJECT_COUNT;

    /*
    self.subjectIDs = [[NSMutableArray alloc] initWithCapacity:self.subjectCount];
    self.displayCounts = [[NSMutableArray alloc] initWithCapacity:self.subjectCount];
    
    for (i=0; i<[self.dataController fetchTotalSubjectCount]; i++) {
        
        if (i<INITIAL_SUBJECT_COUNT) {
<<<<<<< mine
            [self.subjectIDs insertObject:[NSString stringWithFormat:@"Subject %i", i] atIndex:i];
=======
            [self.subjectIDs insertObject:[NSString stringWithFormat:@"Subject %i", i+11] atIndex:i];
>>>>>>> theirs
        }
        else{
            [self.subjectIDs insertObject:[NSString stringWithFormat:@"Additional Subject %i", i] atIndex:i];
        }
        
        Subject * subject = [self.dataController fetchSubjectWithID:i+1];
        [self.displayCounts insertObject:[NSNumber numberWithInt:[subject.sessions count]] atIndex:i];
    }
     */
    

    
    [self makeCustomToolBarTitleWithString:@"Training Monitoring Sessions"];
    
//    [self createNavigationBarItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkPercentDone:)
                                                 name:@"percentDone"
                                               object:nil];
    
 
    [self initCellNames];
    [self updateCellNames];
    
    self.toDoArray = [[NSMutableArray alloc] init];

}

-(void)initCellNames
{
    self.cellNames = [[NSMutableArray alloc] initWithCapacity: INITIAL_SUBJECT_COUNT];//[self.dataController fetchTotalSubjectCount]];
    
}

-(void)updateCellNames
{
    int i;
    for (i=0; i<INITIAL_SUBJECT_COUNT; i++) {
        
//        Subject * subject = [self.dataController fetchSubjectWithID:i+1];
//        int sessionCount = [subject.sessions count];
        NSMutableArray * sessionFillerArray = [[NSMutableArray alloc] initWithCapacity:SESSION_COUNT];
        
        int j;
        for(j=0; j<SESSION_COUNT; j++){
            [sessionFillerArray addObject:[self sessionLabelForSection:i andRow:j]];
        }
        
        [self.cellNames addObject:sessionFillerArray];
    }
}


- (void) checkPercentDone:(NSNotification *) notification
{
    [self initCellNames];
    [self updateCellNames]; //needed to take out of the cell creation/update method - was lagging  app
    [self.tableView reloadData];
}



-(void)createCustomModel
{
    self.dataController = [[DataController alloc] init];
    self.dataController.managedObjectContext = self.managedObjectContext;
    
    [self.dataController createSubjectWithLocalID:1 andStudyID:11];
    [self.dataController createSubjectWithLocalID:2 andStudyID:12];
    [self.dataController createSubjectWithLocalID:3 andStudyID:13];
    [self.dataController createSubjectWithLocalID:4 andStudyID:14];
    [self.dataController createSubjectWithLocalID:5 andStudyID:15];

    int i;
    for (i=0; i<SESSION_COUNT; i++) {
        [self.dataController createSessionNumber:i+1 withStudySessionID:(3*i+6) forSubjectWithLocalID:1];
        [self.dataController createSessionNumber:i+1 withStudySessionID:(3*i+6) forSubjectWithLocalID:2];
        [self.dataController createSessionNumber:i+1 withStudySessionID:(3*i+6) forSubjectWithLocalID:3];
        [self.dataController createSessionNumber:i+1 withStudySessionID:(3*i+6) forSubjectWithLocalID:4];
        [self.dataController createSessionNumber:i+1 withStudySessionID:(3*i+6) forSubjectWithLocalID:5];

    }
}

-(void)createNavigationBarItems
{
    // Uncomment the following line to preserve selection between presentations.
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //  self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addSubjectButton = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                         target:self
                                         action:@selector(addSubjectWithID)];
    
    UIBarButtonItem *deleteSubjectButton = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemUndo
                                            target:self
                                            action:@selector(deleteSubjectWithID)];
    
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:addSubjectButton, deleteSubjectButton, nil];

}



-(void)makeCustomToolBarTitleWithString:(NSString*)titleString
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:24];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.text = titleString;
    
    self.navigationItem.titleView = label;
}

-(void)addSubjectWithID
{
    [self warnBeforeAddingSubject];

}
-(void)deleteSubjectWithID
{
    [self warnBeforeDeletingSubject];
    
   
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
    //return [self.subjectIDs count];
    
    return INITIAL_SUBJECT_COUNT;//[self.dataController fetchTotalSubjectCount];
}

-(void) viewWillLayoutSubviews
{
    self.headerWidth = self.tableView.frame.size.width;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
//    NSString *sectionTitle = [self.subjectIDs objectAtIndex:section];
    
    NSString *sectionTitle = [NSString stringWithFormat:@"Subject %i",[[[self.dataController fetchSubjectWithID:section+1] studySubjectID] intValue] ];
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    
    label.frame = CGRectMake(0, 0, self.headerWidth, 35);
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font =  [UIFont systemFontOfSize:18];
// [UIFont fontWithName:@"Helvetica" size:20];
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
    Subject * subject = [self.dataController fetchSubjectWithID:section+1];
    NSLog(@"numberOfRowInSection: %i", [subject.sessions count]);
    return   [subject.sessions count];
//    return [[self.displayCounts objectAtIndex:section] intValue]+1;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    

//    int count = [[self.displayCounts objectAtIndex:indexPath.section] intValue];
//    NSLog(@"editing status is %@", tableView.editing ? @"YES" : @"NO");

    
    // Configure the cell...
    
    
    NSString * holder = [[self.cellNames objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = holder;//[self sessionLabelForSection:indexPath.section andRow:indexPath.row];

    /*
    if (indexPath.row == count) {
        
        cell.textLabel.text = @"Add new session";
        
        if (count == SESSION_COUNT) {
            cell.userInteractionEnabled = NO;
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.text = @"Max sessions added";

        }
        
    }
    else if (indexPath.row < count){
        
        cell.textLabel.text = [self sessionLabelForSection:indexPath.section andRow:indexPath.row];
    }
     */
    return cell;
}

-(float)returnPercentageCompleteForSubject:(int)subjectID andSession:(int)sessionID
{
    float total = 0;
    int factor;
    
    if (sessionID==1) {
        factor = 4;
    }
    else{
        factor = 5;
    }
    
    if ([self checkIfAllSurveyCompleteForSubject:subjectID andSession:sessionID]) {
        total = total + 100/factor;
    }
    if ([self checkIfSegmentIsCompleteForSessionForSubject:subjectID andSession:sessionID]) {
        total = total + 100/factor;
    }
    if ([self checkIfStoryEditCompleteForSubject:subjectID andSession:sessionID]) {
        total = total + 100/factor;
    }
    if ([self checkIfTaskMonitoringCompleteForSubject:subjectID andSession:sessionID]) {
        total = total + 100/factor;
    }
    if ([self checkIfSharedStoryCompleteForSubject:subjectID andSession:sessionID]) {
        total = total + 100/factor;
    }

    
    return total;
}

-(NSMutableArray*)returnToDoListFor:(int)subjectID andSession:(int)sessionID
{
//    NSMutableArray * toDoArray = [[NSMutableArray alloc] init];
    
    if (self.toDoArray != nil) {
        [self.toDoArray removeAllObjects];
    }
    
    if (![self checkIfAllSurveyCompleteForSubject:subjectID andSession:sessionID]) {
        [self.toDoArray addObject:@"survey"];
    }
    if (![self checkIfSegmentIsCompleteForSessionForSubject:subjectID andSession:sessionID]) {
        [self.toDoArray addObject:@"segment videos"];
    }
    if (![self checkIfStoryEditCompleteForSubject:subjectID andSession:sessionID]) {
        [self.toDoArray addObject:@"edit video story"];
    }
    if (![self checkIfTaskMonitoringCompleteForSubject:subjectID andSession:sessionID]) {
        [self.toDoArray addObject:@"video record tasks"];
    }
    if (![self checkIfSharedStoryCompleteForSubject:subjectID andSession:sessionID]) {
        [self.toDoArray addObject:@"share video story"];
    }
    
    return self.toDoArray;
}




-(NSString*)sessionLabelForSection:(int)section andRow:(int)row
{
   
    Session * session = [self.dataController fetchSessionNumber:row+1 forSubject:section+1];
    
//	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//	[dateFormatter setDateFormat:@"MM-dd-YYYY"];
//	NSString *sessionLabel = [@"Session" stringByAppendingFormat:@" %i : %@", row+1,[dateFormatter stringFromDate:session.sessionDate]];

    
    /*
    NSString * toDoItems = @" ";
    int numItemsLeft = [[self returnToDoListFor:section+1 andSession:row+1] count];
    int i;
    for(i=0;i<numItemsLeft;i++)
    {
        toDoItems = [toDoItems stringByAppendingString:[[self returnToDoListFor:section+1 andSession:row+1] objectAtIndex:i]];
        if (i<numItemsLeft-1) {
            toDoItems = [toDoItems stringByAppendingString:@", "];
        }
    }
    */
    
    NSString *sessionLabel;

    float percentDone = [self returnPercentageCompleteForSubject:section+1 andSession:row+1];

    if (percentDone == 0) {
        sessionLabel = [@"Session" stringByAppendingFormat:@" %i", [session.studySessionID intValue]];
    }
    else //if (percentDone == 100)
    {
        sessionLabel = [@"Session" stringByAppendingFormat:@" %i - %.f%@", [session.studySessionID intValue], percentDone, @"% complete"];
    }
//    else{
//        sessionLabel = [@"Session" stringByAppendingFormat:@" %i - %.f%@ - To do:%@", [session.studySessionID intValue], percentDone, @"% complete", toDoItems];
//
//    }
    

    return sessionLabel;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


-(void)warnBeforeDeletingForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int sessionID = indexPath.row+1;
    int subjectID = indexPath.section+1;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Delete Session %i for Subject %i",sessionID,subjectID+3]
                                                    message:@"Are you sure you want to delete this session? All data collected for this session will be lost."
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    
    self.indexPathToBeDeleted = indexPath;
    
    alert.tag = 2;

    [alert show];

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    int sessionID = self.indexPathToBeDeleted.row+1;
    int subjectID = self.indexPathToBeDeleted.section+1;
    
    if (buttonIndex == 1 && alertView.tag == 2) {
        
        NSLog(@"this came from deleting a session");

        [self.dataController deleteSessionNumber:sessionID forSubject:subjectID];
        
        int newCount = [[self.displayCounts objectAtIndex:self.indexPathToBeDeleted.section] intValue]-1;
        [self.displayCounts replaceObjectAtIndex:self.indexPathToBeDeleted.section withObject:[NSNumber numberWithInt:newCount]];
       
        // Delete the row from the data source in this line then, update table
        
        [self.tableView deleteRowsAtIndexPaths:@[self.indexPathToBeDeleted] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        
    }
    
    if (buttonIndex == 1 && alertView.tag == 1) {
        
//        NSLog(@"this came from adding a subject");
        
        int subjectID = [self.subjectIDs count]+1;
        
        [self.dataController addAnotherSubjectWithID:subjectID];
        
        [self.subjectIDs addObject:[NSString stringWithFormat:@"Additional Subject %i", subjectID+3]];
    
        Subject * subject = [self.dataController fetchSubjectWithID:subjectID];
        [self.displayCounts addObject:[NSNumber numberWithInt:[subject.sessions count]]];
        
        [self.tableView reloadData];
        
        if ([self.subjectIDs count]>INITIAL_SUBJECT_COUNT) {
            
            NSLog(@"Renabling remove subject feature");
            [[self.navigationItem.leftBarButtonItems objectAtIndex:1] setEnabled:YES];
        }

    }
    
    if (buttonIndex == 1 && alertView.tag == 3) {
        
//        NSLog(@"this came from DELETING a subject");
        
        int subjectID = [self.subjectIDs count];
        
        [self.dataController deleteSubjectWithID:subjectID];
        
        [self.subjectIDs removeLastObject];
        
        [self.displayCounts removeLastObject];
        
        [self.tableView reloadData];
        
        if ([self.subjectIDs count]==INITIAL_SUBJECT_COUNT) {
        
            NSLog(@"Can't delete anymore subjects after this");
            [[self.navigationItem.leftBarButtonItems objectAtIndex:1] setEnabled:NO];
        }
        
    }
}

-(void)warnBeforeAddingSubject
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Add a subject"]
                                                    message:@"Are you sure you want to add an additional subject?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    
    alert.tag = 1;
        
    [alert show];
    
}

-(void)warnBeforeDeletingSubject
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Delete last subject added"]
                                                    message:@"Are you sure you want to delete the last subject you added?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    
    alert.tag = 3;
    
    [alert show];
    
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self warnBeforeDeletingForRowAtIndexPath:indexPath];

//        int newCount = [[self.displayCounts objectAtIndex:indexPath.section] intValue]-1;
//        [self.displayCounts replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithInt:newCount]];
//        
//        
//        // Delete the row from the data source in this line then, update table
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    }   
    else
        
    if (editingStyle == UITableViewCellEditingStyleInsert) {
       
        if (indexPath.row < SESSION_COUNT) {
            
//            [self.dataController createSessionNumber:indexPath.row+1 forSubject:indexPath.section+1];
            
            int newCount = [[self.displayCounts objectAtIndex:indexPath.section] intValue]+1;
            
            [self.displayCounts replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithInt:newCount]];

            [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}




- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
    int count = [[self.displayCounts objectAtIndex:indexPath.section] intValue];

    if (indexPath.row==count && indexPath.row<SESSION_COUNT) {
        return UITableViewCellEditingStyleInsert;
    }
    else if(indexPath.row<count){
       return UITableViewCellEditingStyleDelete;
    }
    else{
        return UITableViewCellEditingStyleNone;
    }*/
    
    return UITableViewCellEditingStyleNone;
}


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
    self.indexPathToSegueFrom = indexPath;

    [self pickSegueForIndexPath:indexPath];
    
}

-(void) pickSegueForIndexPath:(NSIndexPath *)indexPath 
{
    NSString * segueDescriptor = [NSString stringWithFormat:@"Subject-Session"];

    /*
    if (indexPath.row < [[self.displayCounts objectAtIndex:indexPath.section] intValue]) {
        [self performSegueWithIdentifier:segueDescriptor sender:indexPath];
    }
    else{
        NSLog(@"last row touched");
        [self setEditing:YES animated:YES];
    }*/
    
    [self performSegueWithIdentifier:segueDescriptor sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    int subjectIDNum = self.indexPathToSegueFrom.section+1;
    Subject * subject = [self.dataController fetchSubjectWithID:subjectIDNum];
    int studySubjectID = [subject.studySubjectID intValue];
    int sessionIDNum = self.indexPathToSegueFrom.row+1;
    Session * session = [self.dataController fetchSessionNumber:sessionIDNum forSubject:subjectIDNum];
    int studySessionID = [session.studySessionID intValue];

    NSString * segueDescriptor = [NSString stringWithFormat:@"Subject-Session"];
    
    if ([[segue identifier] isEqualToString:segueDescriptor]) {
        
        MainTableViewController * mainTVC = segue.destinationViewController;
        mainTVC.title = [NSString stringWithFormat:@"Subject %i - Session %i", studySubjectID,studySessionID];
        
        mainTVC.managedObjectContext = self.managedObjectContext;
        mainTVC.subjectID = subjectIDNum;
        mainTVC.sessionID = sessionIDNum;
    }

}



///////////////repeat functions

-(BOOL)checkIfAllSurveyCompleteForSubject:(int)subjectID andSession:(int)sessionID
{
    BOOL allMCAnswered = NO;
    BOOL lastQuestionAnswered = NO;
    
    Session* session = [self.dataController fetchSessionNumber:sessionID forSubject:subjectID];
    
    int i;
    for (i=0; i<[session.surveyAnswer count]; i++) {
        
        SurveyAnswer * sa = [self.dataController fetchSurveyAnswerWithIndex:i+1 forSubject:subjectID fromSession:sessionID];
        
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
//        NSLog(@"yes");
        return YES;
    }
    else{
//        NSLog(@"no");
        return  NO;
    }
}

-(BOOL)checkIfStoryEditCompleteForSubject:(int)subjectID andSession:(int)sessionID
{
    Session* session = [self.dataController fetchSessionNumber:sessionID forSubject:subjectID];
    return [session.finishedStory boolValue];
}

-(BOOL)checkIfSharedStoryCompleteForSubject:(int)subjectID andSession:(int)sessionID
{
    Session* session = [self.dataController fetchSessionNumber:sessionID forSubject:subjectID];
    return [session.sharedStory boolValue];
}

-(BOOL)checkIfTaskMonitoringCompleteForSubject:(int)subjectID andSession:(int)sessionID
{
    TaskType * task1 = [self.dataController fetchTaskWithOrder:1 forSubject:subjectID fromSession:sessionID];
    TaskType * task2 = [self.dataController fetchTaskWithOrder:2 forSubject:subjectID fromSession:sessionID];
    TaskType * task3 = [self.dataController fetchTaskWithOrder:3 forSubject:subjectID fromSession:sessionID];
    
    if (task1.movieURLString && task2.movieURLString && task3.movieURLString){
        return YES;
    }
    else{
        return NO;
    }
}

-(BOOL)checkIfSegmentIsCompleteForSessionForSubject:(int)subjectID andSession:(int)sessionID
{
    if ([self areAllTrialsSegmentedForTaskWithDescriptor:@"graspCone" forSession:sessionID forSubjectID:subjectID]
        && [self areAllTrialsSegmentedForTaskWithDescriptor:@"elevatedTouch" forSession:sessionID forSubjectID:subjectID]
        && [self areAllTrialsSegmentedForTaskWithDescriptor:@"transport" forSession:sessionID forSubjectID:subjectID]){
        return YES;
    }
    else{
        return NO;
    }
    
}

-(BOOL)areAllTrialsSegmentedForTaskWithDescriptor:(NSString*)taskDescriptor forSession:(int)sessionID forSubjectID:(int)subjectID
{
    TaskType * task = [self.dataController fetchTaskWithDescriptor:taskDescriptor forSubject:subjectID fromSession:sessionID];
    
    int numComplete = 0;
    
    int i;
    for (i=0; i<[task.numTrials intValue]; i++){
        
        Trial * trial = [self.dataController fetchTrialWithIndex:i+1 forTaskType:taskDescriptor forSubject:subjectID fromSession:sessionID];
        
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

////////////////end repeat functions




- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}





@end

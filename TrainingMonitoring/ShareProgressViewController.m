//
//  ShareProgressViewController.m
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 5/1/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import "ShareProgressViewController.h"

#import "DataController.h"
#import "AppDelegate.h"
#import "Trial.h"
#import "FineSegmentViewController.h"
#import "StorySet.h"

@interface ShareProgressViewController ()
@property(nonatomic, retain) DataController * dataController;
@property(nonatomic, retain) NSMutableArray * bookmarkedTrials;
//@property(nonatomic, retain) NSMutableArray * bookmarkedTrials;
@property(nonatomic, retain) Trial * currentTrial;
@property(nonatomic, retain) TaskType * currentTask;
@property(retain) NSMutableDictionary * storyRecord;
@property(retain, nonatomic)NSArray * sectionCounts;
@property(nonatomic, assign) int rowSelected;
@property(nonatomic, assign) int sectionSelected;

@end

@implementation ShareProgressViewController
@synthesize sessionID = _sessionID;
@synthesize subjectID = _subjectID;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize dataController = _dataController;
@synthesize bookmarkedTrials  = _bookmarkedTrials;
@synthesize currentTrial = _currentTrial;
@synthesize currentTask = _currentTask;
@synthesize updateFromPlist = _updateFromPlist;
@synthesize storyRecord = _storyRecord;
@synthesize sectionCounts = _sectionCounts;
@synthesize rowSelected = _rowSelected;
@synthesize sectionSelected = _sectionSelected;

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
    
    
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.dataController = [[DataController alloc] init];
    self.dataController.managedObjectContext = self.managedObjectContext;
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    /*
    UIBarButtonItem *undoButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemUndo
                                   target:self
                                   action:@selector(showAlertView)];
    
    self.navigationItem.rightBarButtonItems =
    [NSArray arrayWithObjects:self.editButtonItem, undoButton, nil];
     */
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Finished sharing story" style:UIBarButtonItemStyleBordered target:self action:@selector(updateSessionModel)];
    
    self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:saveButton, nil];

    
    
    self.bookmarkedTrials = [[NSMutableArray alloc] initWithCapacity:1];
    
    
    NSArray * compoundArray = [self.dataController returnCompoundArrayFromPlistForSubjectID:self.subjectID ForCurrentSessionID:self.sessionID-1];
    
//    int i;
//    for (i=self.sessionID; i<self.sessionID+1; i++) {
        [self.bookmarkedTrials insertObject:[compoundArray objectAtIndex:self.sessionID-2] atIndex:0];
//    }
    
    [self makeCustomToolBarTitleWithString:@"Videos from previous sessions"];
    
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait)
    {
        [self showOrientationAlertView];
    }
    
    [self updateFinishedButton];

}


-(void)updateSessionModel
{
    Session * session = [self.dataController fetchSessionNumber:self.sessionID forSubject:self.subjectID];
    session.sharedStory = [NSNumber numberWithBool:YES];
    //save
    NSError *error = nil;
    
    if ( !  [self.managedObjectContext save:&error] ) {
        NSLog(@"An error! %@",error);
    }
    
    [self updateFinishedButton];
    
}

-(void)updateFinishedButton
{
    Session * session = [self.dataController fetchSessionNumber:self.sessionID forSubject:self.subjectID];
    UIBarButtonItem * savedButton = [self.navigationItem.rightBarButtonItems objectAtIndex:0];
    
    if([session.sharedStory boolValue]){
        savedButton.tintColor = [UIColor blueColor];
        savedButton.title = @"Finished";
        
    }
    else{
        savedButton.tintColor = [UIColor clearColor];
        savedButton.title = @"Finished sharing story";
        
    }
    
}


- (void)showOrientationAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"IPad orientation"
                                                    message:@"Please make sure the iPad is oriented vertically for best viewing."
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
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



-(void)showAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Undo your edits"
                                                    message:@"Are you sure you want to undo your edits? All original videos will be restored in the orginal order provided."
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self restoreOriginalFilesFromPlist];
        
    }
}

-(void)restoreOriginalFilesFromPlist
{
    
    //    NSArray *viewControllers = self.navigationController.viewControllers;
    
    //    [self.navigationController popToViewController: [viewControllers objectAtIndex:1] animated: YES];
    
    [self.dataController writeInitialBookmarkedDescriptorsToPlistForSession:self.sessionID ForSubject:self.subjectID];
    
    [self.bookmarkedTrials removeAllObjects];
    
    NSArray * compoundArray = [self.dataController returnCompoundArrayFromPlistForSubjectID:self.subjectID ForCurrentSessionID:self.sessionID];
    
    int i;
    for (i=0; i<self.sessionID; i++) {
        [self.bookmarkedTrials insertObject:[compoundArray objectAtIndex:i] atIndex:i];
    }
    
    [self.tableView reloadData];
    
}






-(void)editStoryRecordForSubject:(int)subjectID forSession:(int)sessionID withBool:(BOOL)boolValue
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"StoryEditRecord.plist"]; //3
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    NSString * subjectKey = [@"Subject" stringByAppendingFormat:@"%i", subjectID];
    NSArray * boolRecord = [data objectForKey:subjectKey];
    
    NSMutableArray * copyBoolRecord = [boolRecord mutableCopy];
    [copyBoolRecord replaceObjectAtIndex:sessionID-1 withObject:[NSNumber numberWithBool:boolValue]];
    
    if ([[data allKeys] containsObject:subjectKey]) {

    
        [data setObject:copyBoolRecord forKey:subjectKey];
        
        [data writeToFile:path atomically:YES];
        
        
        NSMutableDictionary *newData = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        
        int i;
        for (i = 0; i<[[newData objectForKey:subjectKey] count]; i++) {
            
            NSNumber* boolNumber = [[newData objectForKey:subjectKey] objectAtIndex:i];
            NSLog(@"storyRecord for subject %i is %@ for session %i", self.subjectID, [boolNumber boolValue] ? @"YES" : @"NO", i+1);
        }
    }
    
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
    return [self.bookmarkedTrials count];
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Session %i", section+1];
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //fetch videos with bookmark - need to do for all tasks all tags
    
    return [[self.bookmarkedTrials objectAtIndex:section] count];
    
}


-(NSArray*)returnAllBookmarkedTrialsForSession:(int)section
{
    NSMutableArray *array1 = [[self.dataController fetchTrialsWithBookMarkTag:0 forTaskType:@"graspCone" forSubject:self.subjectID fromSession:section+1] mutableCopy];
    
    int i;
    for (i=0; i<3; i++)
    {
        if (i>0) {
            NSArray *arrayTemp1 = [self.dataController fetchTrialsWithBookMarkTag:i forTaskType:@"graspCone" forSubject:self.subjectID fromSession:section+1];
            [array1 addObjectsFromArray:arrayTemp1];
        }
        
        NSArray *arrayTemp2 = [self.dataController fetchTrialsWithBookMarkTag:i forTaskType:@"elevatedTouch" forSubject:self.subjectID fromSession:section+1];
        [array1 addObjectsFromArray:arrayTemp2];
        
        NSArray *arrayTemp3 = [self.dataController fetchTrialsWithBookMarkTag:i forTaskType:@"transport" forSubject:self.subjectID fromSession:section+1];
        [array1 addObjectsFromArray:arrayTemp3];
        
    }
    
    //    NSLog(@"size of grasp bookMarks %i", [array1 count]);
    
    return array1;
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    Trial * trial = [[self.bookmarkedTrials objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    
    NSString * filteredNotesMessage;
    if ([trial.tagAnnotation isEqualToString:@"Type notes here"]) {
        filteredNotesMessage = @"No notes added";
    }
    else{
        filteredNotesMessage = trial.tagAnnotation;
    }
    
//    NSString * tagPlusAnnotation = [[[[self.dataController tagTranslatorForIntValue:[trial.tag intValue]] stringByAppendingFormat:@" - %@", trial.taskType.descriptor] stringByAppendingFormat:@" - Session %i", [trial.taskType.session.studySessionID intValue]] stringByAppendingFormat:@" : %@", filteredNotesMessage];
    
     NSString * tagPlusAnnotation = [[[self.dataController tagTranslatorForIntValue:[trial.tag intValue]] stringByAppendingFormat:@" - Session %i %@", [trial.taskType.session.studySessionID intValue], trial.taskType.descriptor] stringByAppendingFormat:@" : %@", filteredNotesMessage];
    
    NSString * cellLabel = tagPlusAnnotation;
    
    cell.textLabel.text = cellLabel;
    
    if ([trial.tag intValue]== 0) {
        cell.textLabel.textColor = [UIColor blueColor];
    }
    else if ([trial.tag intValue]== 1) {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    
    return cell;
}

-(void)test:(UIButton*)sender
{
    NSLog(@"HI from test");
    
    
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [[self.bookmarkedTrials objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //    Subject * subject = [self.dataController fetchSubjectWithID:indexPath.section+1];
    
    //    int count = [[self.bookmarkedTrials objectAtIndex:indexPath.section] count];
    
    /*
     if (indexPath.row==count-1) {
     return UITableViewCellEditingStyleInsert;
     }
     
     else{
     return UITableViewCellEditingStyleDelete;
     //        return UITableViewCellEditingStyleNone;
     }*/
    
    return UITableViewCellEditingStyleDelete;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSString *stringToMove = [[self.bookmarkedTrials objectAtIndex:sourceIndexPath.section] objectAtIndex:sourceIndexPath.row];
    [[self.bookmarkedTrials objectAtIndex:sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
    [[self.bookmarkedTrials objectAtIndex:sourceIndexPath.section] insertObject:stringToMove atIndex:destinationIndexPath.row];
    //    [stringToMove release];
    
    
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    
    
    NSUInteger sectionCount = [[self.bookmarkedTrials objectAtIndex:sourceIndexPath.section] count];
    
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        NSUInteger rowInSourceSection =
        (sourceIndexPath.section > proposedDestinationIndexPath.section) ?
        0 : sectionCount - 1;
        return [NSIndexPath indexPathForRow:rowInSourceSection inSection:sourceIndexPath.section];
    } else if (proposedDestinationIndexPath.row >= sectionCount) {
        return [NSIndexPath indexPathForRow:sectionCount - 1 inSection:sourceIndexPath.section];
    }
    // Allow the proposed destination.
    return proposedDestinationIndexPath;
    
}




// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentTrial = [[self.bookmarkedTrials objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    self.rowSelected = indexPath.row;
    
    [self performSegueWithIdentifier:@"ShowMovie" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowMovie"]) {
        
        FineSegmentViewController * fineSegmentVC = segue.destinationViewController;
        
        
        
        fineSegmentVC.bookmarkedTrials = self.bookmarkedTrials;
        fineSegmentVC.rowIndexComingFromShareProg = self.rowSelected;
        fineSegmentVC.sectionIndexComingFromShareProg = self.sectionSelected;

        fineSegmentVC.trialCounter = [self.currentTrial.index intValue];
        fineSegmentVC.taskDescriptor = self.currentTrial.taskType.descriptor;
        
        fineSegmentVC.subjectID = [self.currentTrial.taskType.session.subject.subjectID intValue];
        fineSegmentVC.sessionID = [self.currentTrial.taskType.session.sessionID intValue];
        
        TaskType * taskTypeOfTrial = [self.dataController fetchTaskWithDescriptor:self.currentTrial.taskType.descriptor
                                                                       forSubject:fineSegmentVC.subjectID
                                                                      fromSession:fineSegmentVC.sessionID];
        
        fineSegmentVC.movieURL = [NSURL URLWithString:taskTypeOfTrial.movieURLString];
        fineSegmentVC.numTrials = [taskTypeOfTrial.trials count];
        
        fineSegmentVC.newStartTime = CMTimeMakeWithSeconds([self.currentTrial.fineStartTime floatValue], 600);
        fineSegmentVC.newStopTime = CMTimeMakeWithSeconds([self.currentTrial.fineStopTime floatValue], 600);
        
               
        
        fineSegmentVC.startSliderTime =  fineSegmentVC.newStartTime;
        fineSegmentVC.endSliderTime =  fineSegmentVC.newStopTime;
        
        fineSegmentVC.doShowComment = YES;
        
        
        NSString * filteredNotesMessage;
        if ([self.currentTrial.tagAnnotation isEqualToString:@"Type notes here"]) {
            filteredNotesMessage = @"No notes added";
        }
        else{
            filteredNotesMessage = self.currentTrial.tagAnnotation;
        }
        
        fineSegmentVC.commentString = filteredNotesMessage;
        
    

        
    }
}



-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sharedStoryDone" object:nil];
    
    [super viewWillDisappear:animated];
    
    //need to fill an array with the story index properties from each trial object
    /*
    NSMutableArray * allSessionsArray = [[NSMutableArray alloc] init];
    
    int i;
    for (i=0; i<self.sessionID; i++) {
        
        NSMutableArray * singleSessionArray= [[NSMutableArray alloc] init];
        
        NSLog(@"size of section %i is %i", i, [[self.bookmarkedTrials objectAtIndex:i] count]);
        int j;
        for (j=0; j<[[self.bookmarkedTrials objectAtIndex:i] count]; j++) {
            
            Trial * trial = [[self.bookmarkedTrials objectAtIndex:i] objectAtIndex:j];
            
            NSString * tag = [self.dataController tagTranslatorForIntValue:[trial.tag intValue]];
            
            NSString * savedDescriptor = [tag stringByAppendingFormat:@"_%@_trial%i_sub%i_sess%i", trial.taskType.descriptor, [trial.index intValue], self.subjectID, i+1];
            
            NSLog(@"%@ saved at position %i",savedDescriptor, j);
            
            [singleSessionArray insertObject:savedDescriptor atIndex:j];
        }
        
        NSLog(@"size of singleSessionArray %i is %i", i, [singleSessionArray count]);
        [allSessionsArray addObject:singleSessionArray];
    }
    
    [self.dataController saveArray:allSessionsArray ToPlistForSubjectID:self.subjectID ForCurrentSessionID:self.sessionID];
    */
}




- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}



@end

//
//  FineSegmentViewController.m
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/13/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import "FineSegmentViewController.h"
#import "DataController.h"
#import "AppDelegate.h"
#import "Trial.h"
#import "CoarseSegmentViewController.h"

@interface FineSegmentViewController ()
@property(nonatomic, retain) DataController * dataController;
@property (weak, nonatomic) IBOutlet UISlider *trimLeftSlider;
@property (weak, nonatomic) IBOutlet UISlider *trimRightSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeDurationDisplay;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *currentTrialNumber;
@property (weak, nonatomic) IBOutlet UIProgressView *trialProgressBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *bookmarkTag;
@property (nonatomic, retain) UITextView *textView;

@property (assign) BOOL dontUpdateTime;
@property (weak, nonatomic) IBOutlet UILabel *commentDisplay;
@property (weak, nonatomic) IBOutlet UIButton *showFullTrialButton;
@property (weak, nonatomic) IBOutlet UIButton *addNotesButton;
@property (weak, nonatomic) IBOutlet UIButton *bigPlayButton;

@end

@implementation FineSegmentViewController
@synthesize sessionID = _sessionID;
@synthesize subjectID = _subjectID;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize dataController = _dataController;
@synthesize numTrials = _numTrials;
@synthesize taskDescriptor = _taskDescriptor;
@synthesize trialCounter = _trialCounter;
@synthesize dontUpdateTime = _dontUpdateTime;
@synthesize initialLeftSliderVal = _initialLeftSliderVal;
@synthesize initialRightSliderVal = _initialRightSliderVal;
@synthesize textView = _textView;
@synthesize commentString = _commentString;
@synthesize doShowComment = _doShowComment;
@synthesize commentDisplay = _commentDisplay;
@synthesize bookmarkedTrials = _bookmarkedTrials;
@synthesize rowIndexComingFromShareProg = _rowIndexComingFromShareProg;
@synthesize sectionIndexComingFromShareProg = _sectionIndexComingFromShareProg;
@synthesize showFullTrialButton = _showFullTrialButton;
@synthesize addNotesButton = _addNotesButton;
@synthesize bigPlayButton = _bigPlayButton;

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
    
    self.playerLayerView.backgroundColor = [UIColor blackColor];

    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    self.dataController = [[DataController alloc] init];
    self.dataController.managedObjectContext = self.managedObjectContext;

//    self.currentTrialNumber.text = [NSString stringWithFormat:@"%i", self.trialCounter];
    
    self.timeDurationDisplay.text = [NSString stringWithFormat:@"%.1f",[self calcTimeDurationFromStart:self.startSliderTime ToEnd:self.endSliderTime]];

    self.dontUpdateTime = NO;
    
//    self.trialProgressBar.progress = 0.0;
    
//    [self performSelectorOnMainThread:@selector(updateProgressBar) withObject:nil waitUntilDone:NO];
    
    [self.backButton setHidden:YES];

    [self setupSliders];
    
    [self.bookmarkTag addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    UIFont *font = [UIFont boldSystemFontOfSize:18.0];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:UITextAttributeFont];
    [self.bookmarkTag setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    
    [self.bookmarkTag setFrame:CGRectMake(self.bookmarkTag.frame.origin.x, self.bookmarkTag.frame.origin.y, self.bookmarkTag.frame.size.width, 50)];
    
    CGRect textViewFrame = CGRectMake(20, self.view.frame.size.height/2, self.view.frame.size.width-40.0f, 124.0f);
    self.textView = [[UITextView alloc] initWithFrame:textViewFrame];
    self.textView.layer.cornerRadius = 15.0;
    self.textView.clipsToBounds = YES;
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.returnKeyType = UIReturnKeyDefault;
    self.textView.font = [UIFont fontWithName:@"Arial" size:20];
    self.textView.delegate = self;
    [self.view addSubview: self.textView];
    
    self.textView.hidden = YES;
    
    [self updateInterface];
    
    if (self.doShowComment) {
        self.commentDisplay.hidden = NO;
        self.commentDisplay.text = self.commentString;
        self.commentDisplay.numberOfLines = 0;
        self.commentDisplay.textAlignment = NSTextAlignmentCenter;
    }
    else{
        self.commentDisplay.hidden = YES;
    }
    
    
    
    
 

}

- (void)segmentAction:(id)sender
{
    NSLog(@"book mark is %i", [sender selectedSegmentIndex]);
    
    Trial * trial = [self.dataController fetchTrialWithIndex:self.trialCounter
                                                 forTaskType:self.taskDescriptor
                                                  forSubject:self.subjectID
                                                 fromSession:self.sessionID];

    trial.tag = [NSNumber numberWithInt:[sender selectedSegmentIndex]];
    
    NSError *error = nil;
    
    if ( !  [self.dataController.managedObjectContext save:&error] ) {
        NSLog(@"An error! %@",error);
    }   
}


-(void) setupSliders
{
    UIImage * trackImage = [UIImage imageNamed:@"grey.png"];
    UIImage * trackImage2 = [UIImage imageNamed:@"green2.png"];
    UIImage * trackImage3 = [UIImage imageNamed:@"blankReak.png"];
    
    [self.trimLeftSlider setMinimumTrackImage:trackImage forState:UIControlStateNormal];
    [self.trimLeftSlider setMaximumTrackImage:trackImage2 forState:UIControlStateNormal];
    
    [self.trimRightSlider setMinimumTrackImage:trackImage3 forState:UIControlStateNormal];
    [self.trimRightSlider setMaximumTrackImage:trackImage forState:UIControlStateNormal];
    
    [self.trimLeftSlider setValue:self.initialLeftSliderVal];
    [self.trimRightSlider setValue:self.initialRightSliderVal];
}

- (void)updateProgressBar {
    
    float actual = self.trialProgressBar.progress;
    if (actual < 1) {
        self.trialProgressBar.progress = (self.trialCounter/(float)self.numTrials);
        [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:NO];
    }
    else{
        //        NSLog(@"YOURE DONE");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)preventScrubbing:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]])
    {
        UISlider * slider = sender;
        
        if (self.trimRightSlider.value - self.trimLeftSlider.value <= .1) {
            self.dontUpdateTime = YES;
//            NSLog(@"dontUpdateTime");
            
            self.timeDurationDisplay.text = [NSString stringWithFormat:@"%.1f", CMTimeGetSeconds(self.playerItemDuration)*.1];
            
        }
        else{
            self.dontUpdateTime = NO;
        }
        
        if (slider.tag == 0) {
            
            if (self.trimLeftSlider.value >= self.trimRightSlider.value - .1) {
//                NSLog(@"flag0");
                self.trimLeftSlider.value = self.trimRightSlider.value - .1;
            }
        }
        if (slider.tag == 1) {
            
            if (self.trimRightSlider.value <= self.trimLeftSlider.value + .1) {
//                NSLog(@"flag1");
                self.trimRightSlider.value = self.trimLeftSlider.value + .1;
            }
        }
    }
}

- (IBAction)halfSlider:(id)sender {
    
    if (!self.dontUpdateTime) {
        self.timeDurationDisplay.text = [NSString stringWithFormat:@"%.1f",[self calcTimeDurationFromStart:self.startSliderTime ToEnd:self.endSliderTime]];
    }
    
}

- (IBAction)halfSlider2:(id)sender {
    
    if (!self.dontUpdateTime) {
        self.timeDurationDisplay.text = [NSString stringWithFormat:@"%.1f",[self calcTimeDurationFromStart:self.startSliderTime ToEnd:self.endSliderTime]];
    }
}

-(Float64)calcTimeDurationFromStart:(CMTime)startTime ToEnd:(CMTime)endTime
{
    CMTime duration = CMTimeSubtract(endTime, startTime);
    Float64 durationInSecs = CMTimeGetSeconds(duration);
    //    NSLog(@"duration is %f", durationInSecs);
    return durationInSecs;
}

-(void)resetTimes:(id)sender
{
    NSLog(@"resetTimes getting called");
    
    if ([sender isKindOfClass:[UISlider class]])
    {
        
        
        UISlider * slider = sender;
        if (slider.tag == 0) {
            self.startSliderTime = [self.player currentTime];
            NSLog(@"self.startSliderTime is %f", CMTimeGetSeconds(self.startSliderTime));

        }
        if (slider.tag == 1) {
            self.endSliderTime = [self.player currentTime];
            NSLog(@"endSliderTime is %f", CMTimeGetSeconds(self.endSliderTime));

        }
    }
}

-(void)updateVideoWithNewTimes
{
//        self.newStartTime = self.startSliderTime;
    //    self.newStopTime = self.endSliderTime;
    //
    
    [self.player seekToTime:self.startSliderTime
            toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimeZero];
}

//-(void)syncScrubber{}

//-(IBAction)play:(id)sender {
//
//	if (self.seekToZeroBeforePlay)
//	{
//		self.seekToZeroBeforePlay = NO;
//        
//        [self.player seekToTime:self.startSliderTime
//                toleranceBefore:kCMTimeZero
//                 toleranceAfter:kCMTimeZero];
//	}
//    
//	[self.player play];
//    [self showStopButton];
//}

-(void)pauseAtTime
{
    if (CMTIME_COMPARE_INLINE([self.player currentTime],>=, self.endSliderTime)) {
        //        NSLog(@"time is EQUAL");
        [self.player pause];
        self.seekToZeroBeforePlay = YES;
    }
}

-(void)updateVals
{
    //blank to overwrite super class definition
}


- (IBAction)goBackATrial:(id)sender {
   
    
    [self saveEdits];

    if (self.trialCounter>1) {
        
        self.trialCounter--;
        [self updateToTrialWithinSetSize:self.numTrials];
        [self updateInterface];
        if (!self.textView.hidden) {
            [self hideAnnotationView];
        }

        if (self.trialCounter < self.numTrials) {
//            [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
        }
        
        if (self.trialCounter == 1) {
            [self.backButton setHidden:YES];
        }
    }
    
}
- (IBAction)goToNextTrial:(id)sender {
    
    [self saveEdits];
    
    self.trialCounter++;
    
    if (self.trialCounter<=self.numTrials) {
        
        [self updateToTrialWithinSetSize:self.numTrials];
        [self updateInterface];
        if (!self.textView.hidden) {
            [self hideAnnotationView];
        }

    }
    
    if (self.trialCounter > self.numTrials) {
        
        NSArray *viewControllers = self.navigationController.viewControllers;
        //
        //         [[NSNotificationCenter defaultCenter] postNotificationName:@"coneSegmentingDone" object:[NSNumber numberWithBool:YES]];
        //
        [self.navigationController popToViewController: [viewControllers objectAtIndex:2] animated: YES];
        
        
    }
    
    
    
    
    if (self.trialCounter > 1) {
        [self.backButton setHidden:NO];
    }
    
}

- (IBAction)goToNextBookMarkedTrial:(id)sender {
    
//    self.playerLayerView.hidden = YES;
    
    NSLog(@"self.indexComingFromShareProg - %i", self.rowIndexComingFromShareProg);
   
    self.rowIndexComingFromShareProg++;
    
    if (self.rowIndexComingFromShareProg>0) {
        self.backButton.hidden = NO;
    }
    
    
    Trial * currentTrial;
    if (self.rowIndexComingFromShareProg<[[self.bookmarkedTrials objectAtIndex:self.sectionIndexComingFromShareProg] count]) {
        currentTrial = [[self.bookmarkedTrials objectAtIndex:self.sectionIndexComingFromShareProg] objectAtIndex:self.rowIndexComingFromShareProg];
   
    
        self.trialCounter = [currentTrial.index intValue];
        self.taskDescriptor = currentTrial.taskType.descriptor;
        
        self.subjectID = [currentTrial.taskType.session.subject.subjectID intValue];
        self.sessionID = [currentTrial.taskType.session.sessionID intValue];
        
        self.numTrials = [currentTrial.taskType.trials count];
        
        self.newStartTime = CMTimeMakeWithSeconds([currentTrial.fineStartTime floatValue], 600);
        self.newStopTime = CMTimeMakeWithSeconds([currentTrial.fineStopTime floatValue], 600);
        
        self.startSliderTime =  self.newStartTime;
        self.endSliderTime =  self.newStopTime;
                       
        
        [self.player seekToTime:self.startSliderTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        
        
        self.movieURL = [NSURL URLWithString:currentTrial.taskType.movieURLString];
        [self loadMovieWithURL:self.movieURL];

        
        //    NSLog(@"updating to time %f for trialnumber %i", CMTimeGetSeconds(self.startSliderTime),self.trialCounter);
        
        self.title = [NSString stringWithFormat:@"Session %i: Trial %i of %i", [currentTrial.taskType.session.studySessionID intValue], self.trialCounter, [currentTrial.taskType.numTrials intValue]];
        [self makeCustomToolBarTitleWithString:self.title];
        
        
        
        
        NSString * filteredNotesMessage;
        
        self.doShowComment = YES;

        
        if ([currentTrial.tagAnnotation isEqualToString:@"Type notes here"]) {
            filteredNotesMessage = @"No notes added";
        }
        else{
            filteredNotesMessage = currentTrial.tagAnnotation;
        }
        self.commentDisplay.text = filteredNotesMessage;
        
        if (![self.showFullTrialButton.titleLabel.text isEqualToString:@"Show full reach"]) {
            [self.showFullTrialButton setTitle:@"Show full reach" forState:UIControlStateNormal];
        }


    }
   
    if (self.rowIndexComingFromShareProg == [[self.bookmarkedTrials objectAtIndex:self.sectionIndexComingFromShareProg] count]) {
        
        NSArray *viewControllers = self.navigationController.viewControllers;
        //
        //         [[NSNotificationCenter defaultCenter] postNotificationName:@"coneSegmentingDone" object:[NSNumber numberWithBool:YES]];
        //
        [self.navigationController popToViewController: [viewControllers objectAtIndex:2] animated: YES];
        
        
    }
    
    
//     NSLog(@"currentTrial descriptor, trial, comment -  %@, %i, %@", currentTrial.taskType.descriptor, [currentTrial.index intValue], currentTrial.tagAnnotation);

    
    
//    self.playerLayerView.hidden = NO;
    
}
- (IBAction)goBackABookMarkedTrial:(id)sender {
    
//    self.playerLayerView.hidden = YES;
    
    NSLog(@"self.indexComingFromShareProg - %i", self.rowIndexComingFromShareProg);
    
    self.rowIndexComingFromShareProg--;
    
    if (self.rowIndexComingFromShareProg==0) {
        self.backButton.hidden = YES;
    }
    
    
    Trial * currentTrial;
    if (self.rowIndexComingFromShareProg >= 0) {
        currentTrial = [[self.bookmarkedTrials objectAtIndex:self.sectionIndexComingFromShareProg] objectAtIndex:self.rowIndexComingFromShareProg];
        
        
        self.trialCounter = [currentTrial.index intValue];
        self.taskDescriptor = currentTrial.taskType.descriptor;
        
        self.movieURL = [NSURL URLWithString:currentTrial.taskType.movieURLString];
        [self loadMovieWithURL:self.movieURL];
        
        
        self.subjectID = [currentTrial.taskType.session.subject.subjectID intValue];
        self.sessionID = [currentTrial.taskType.session.sessionID intValue];
        
        self.numTrials = [currentTrial.taskType.trials count];
        
        self.newStartTime = CMTimeMakeWithSeconds([currentTrial.fineStartTime floatValue], 600);
        self.newStopTime = CMTimeMakeWithSeconds([currentTrial.fineStopTime floatValue], 600);
        
        self.startSliderTime =  self.newStartTime;
        self.endSliderTime =  self.newStopTime;
        
        self.doShowComment = YES;
        
        
        NSString * filteredNotesMessage;
        if ([currentTrial.tagAnnotation isEqualToString:@"Type notes here"]) {
            filteredNotesMessage = @"No notes added";
        }
        else{
            filteredNotesMessage = currentTrial.tagAnnotation;
        }
        

        self.commentString = filteredNotesMessage;
        
        
        [self.player seekToTime:self.startSliderTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        
        //    NSLog(@"updating to time %f for trialnumber %i", CMTimeGetSeconds(self.startSliderTime),self.trialCounter);
        
        self.title = [NSString stringWithFormat:@"Session %i: Trial %i of %i", [currentTrial.taskType.session.studySessionID intValue], self.trialCounter, [currentTrial.taskType.numTrials intValue]];
        [self makeCustomToolBarTitleWithString:self.title];
        
        if (![self.showFullTrialButton.titleLabel.text isEqualToString:@"Show full reach"]) {
            [self.showFullTrialButton setTitle:@"Show full reach" forState:UIControlStateNormal];
        }

        
        
    }
    
    if (self.rowIndexComingFromShareProg == -1) {
        
        NSArray *viewControllers = self.navigationController.viewControllers;
        //
        //         [[NSNotificationCenter defaultCenter] postNotificationName:@"coneSegmentingDone" object:[NSNumber numberWithBool:YES]];
        //
        [self.navigationController popToViewController: [viewControllers objectAtIndex:2] animated: YES];
        
        
    }
    
    
    //     NSLog(@"currentTrial descriptor, trial, comment -  %@, %i, %@", currentTrial.taskType.descriptor, [currentTrial.index intValue], currentTrial.tagAnnotation);
    
    
    
//    self.playerLayerView.hidden = NO;
    
}


- (IBAction)showFullTrial:(id)sender {

//    self.playerLayerView.hidden = YES;
    
    NSLog(@"self.indexComingFromShareProg - %i", self.rowIndexComingFromShareProg);
    
    Trial * currentTrial;
    
    if (self.rowIndexComingFromShareProg<[[self.bookmarkedTrials objectAtIndex:self.sectionIndexComingFromShareProg] count]) {
        
        currentTrial = [[self.bookmarkedTrials objectAtIndex:self.sectionIndexComingFromShareProg] objectAtIndex:self.rowIndexComingFromShareProg];
        
        
        if ([self.showFullTrialButton.titleLabel.text isEqualToString:@"Show full reach"]) {
            [self.showFullTrialButton setTitle:@"Back to trimmed" forState:UIControlStateNormal];
            self.newStartTime = CMTimeMakeWithSeconds([currentTrial.coarseStartTime floatValue], 600);
            self.newStopTime = CMTimeMakeWithSeconds([currentTrial.coarseStopTime floatValue], 600);
            self.title = [NSString stringWithFormat:@"Session %i: Showing Full Trial %i of %i", [currentTrial.taskType.session.studySessionID intValue], self.trialCounter, [currentTrial.taskType.numTrials intValue]];

            

        }
        else{
            [self.showFullTrialButton setTitle:@"Show full reach" forState:UIControlStateNormal];
            self.newStartTime = CMTimeMakeWithSeconds([currentTrial.fineStartTime floatValue], 600);
            self.newStopTime = CMTimeMakeWithSeconds([currentTrial.fineStopTime floatValue], 600);
            self.title = [NSString stringWithFormat:@"Session %i: Trial %i of %i", [currentTrial.taskType.session.studySessionID intValue], self.trialCounter, [currentTrial.taskType.numTrials intValue]];

        }

        
        self.trialCounter = [currentTrial.index intValue];
        self.taskDescriptor = currentTrial.taskType.descriptor;
        
        self.movieURL = [NSURL URLWithString:currentTrial.taskType.movieURLString];
        [self loadMovieWithURL:self.movieURL];
        
        
        self.subjectID = [currentTrial.taskType.session.subject.subjectID intValue];
        self.sessionID = [currentTrial.taskType.session.sessionID intValue];
        
        self.numTrials = [currentTrial.taskType.trials count];
        
               
        self.startSliderTime =  self.newStartTime;
        self.endSliderTime =  self.newStopTime;
        
        self.doShowComment = YES;
        
        
        NSString * filteredNotesMessage;
        if ([currentTrial.tagAnnotation isEqualToString:@"Type notes here"]) {
            filteredNotesMessage = @"No notes added";
        }
        else{
            filteredNotesMessage = currentTrial.tagAnnotation;
        }
        
//        filteredNotesMessage = currentTrial.tagAnnotation;

        self.commentString = filteredNotesMessage;
        
        
        [self.player seekToTime:self.startSliderTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        
        //    NSLog(@"updating to time %f for trialnumber %i", CMTimeGetSeconds(self.startSliderTime),self.trialCounter);
        
        [self makeCustomToolBarTitleWithString:self.title];
        

        self.commentDisplay.text  = filteredNotesMessage;

        
        
    }
    
    
    
    //     NSLog(@"currentTrial descriptor, trial, comment -  %@, %i, %@", currentTrial.taskType.descriptor, [currentTrial.index intValue], currentTrial.tagAnnotation);
    
    
    
//    self.playerLayerView.hidden = NO;
    
}


- (void) updateToTrialWithinSetSize:(int)setSize
{
//    self.currentTrialNumber.text = [NSString stringWithFormat:@"%i", self.trialCounter];
    
    Trial * trial = [self.dataController fetchTrialWithIndex:self.trialCounter
                                                 forTaskType:self.taskDescriptor
                                                  forSubject:self.subjectID
                                                 fromSession:self.sessionID];
    
    //if you have already saved a value (you over-wrote initial val of -1)

    if ([trial.fineStartTime floatValue] != -1 && [trial.fineStopTime floatValue] != -1){
        self.newStartTime = CMTimeMakeWithSeconds([trial.fineStartTime floatValue], 600);
        self.newStopTime = CMTimeMakeWithSeconds([trial.fineStopTime floatValue], 600);

    }
    else{ //if you have not, then use the coarse time stamps
        self.newStartTime = CMTimeMakeWithSeconds([trial.coarseStartTime floatValue], 600);
        self.newStopTime = CMTimeMakeWithSeconds([trial.coarseStopTime floatValue], 600);

    }

    //either way must do these updates
    self.startSliderTime =  self.newStartTime;
    self.endSliderTime =  self.newStopTime;
    
    [self.trimLeftSlider setValue:[trial.fineSliderStartTime floatValue]]; //default is 0
    [self.trimRightSlider setValue:[trial.fineSliderEndTime floatValue]]; //default is 1
    
    [self calcTimeDurationFromStart:self.startSliderTime ToEnd:self.endSliderTime];
    
    [self.player seekToTime:self.startSliderTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
//    NSLog(@"updating to time %f for trialnumber %i", CMTimeGetSeconds(self.startSliderTime),self.trialCounter);
    
    self.timeDurationDisplay.text = [NSString stringWithFormat:@"%.1f",[self calcTimeDurationFromStart:self.startSliderTime ToEnd:self.endSliderTime]];
}

- (void)saveEdits
{
    Trial * trial = [self.dataController fetchTrialWithIndex:self.trialCounter forTaskType:self.taskDescriptor forSubject:self.subjectID fromSession:self.sessionID];
    
    trial.fineStartTime = [NSNumber numberWithFloat:CMTimeGetSeconds(self.startSliderTime)];
    trial.fineStopTime = [NSNumber numberWithFloat:CMTimeGetSeconds(self.endSliderTime)];
    
    trial.fineSliderStartTime = [NSNumber numberWithFloat:self.trimLeftSlider.value];
    trial.fineSliderEndTime = [NSNumber numberWithFloat:self.trimRightSlider.value];
    
    NSError *error = nil;
    
    if ( !  [self.dataController.managedObjectContext save:&error] ) {
        NSLog(@"An error! %@",error);
    }
    
    if (self.trialCounter == self.numTrials-1) {
//        [self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
    }
    
    NSLog(@"current trial number is %i", [trial.index intValue]);
    NSLog(@"new start time is %f",  [trial.fineStartTime floatValue]);
    NSLog(@"new end time is %f",  [trial.fineStopTime floatValue]);
    
}



///////////////////////



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    NSLog(@"touchesBegan:withEvent:");
    
    /*--
     * Override UIResponder touchesBegan:withEvent: to resign the textView when the user taps the background
     * Use fast enumeration to go through the subview property of UIView
     * Any object that is the current first repsonder will resign that status
     * Make a call to super to take care of any unknown behavior that touchesBegan:withEvent: needs to do behind the scenes
     --*/
    
    for (UITextView *textView in self.view.subviews) {
        if ([textView isFirstResponder]) {
            [textView resignFirstResponder];
            
            
        }
    }
    [super touchesBegan:touches withEvent:event];
}





- (void)textViewDidChange:(UITextView *)textView
{
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    Trial * trial = [self.dataController fetchTrialWithIndex:self.trialCounter
                                                 forTaskType:self.taskDescriptor
                                                  forSubject:self.subjectID
                                                 fromSession:self.sessionID];
    trial.tagAnnotation = textView.text;
    
    NSError *error = nil;
    
    if ( !  [self.dataController.managedObjectContext save:&error] ) {
        NSLog(@"An error! %@",error);
    }
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Type notes here"]) {
        textView.text = @"";
    }
}

- (IBAction)showTextView:(id)sender {
    if (self.textView.hidden) {
        [self showAnnotationView];
        
       
        [self.addNotesButton setTitle:@"Hide notes" forState:UIControlStateNormal];
    }
    else{
        [self hideAnnotationView];
        
        [self.addNotesButton setTitle:@"Add notes" forState:UIControlStateNormal];
    }
}

-(void)showAnnotationView
{

    self.textView.hidden = NO;
    

    CGRect frame;
        
    frame = CGRectMake( self.view.frame.size.width/2-self.textView.frame.size.width/2, 30, self.textView.frame.size.width, 124.0f);
        
    self.textView.frame = frame;
    
}
-(void)hideAnnotationView
{
//    [self.plusMinusButton setBackgroundImage:[UIImage imageNamed:@"cross.png"] forState:UIControlStateNormal];
    self.textView.hidden = YES;
}

-(IBAction)deselectTag:(id)sender
{
    [self.bookmarkTag setSelectedSegmentIndex:UISegmentedControlNoSegment];

    Trial * trial = [self.dataController fetchTrialWithIndex:self.trialCounter
                                                 forTaskType:self.taskDescriptor
                                                  forSubject:self.subjectID
                                                 fromSession:self.sessionID];
    trial.tag = [NSNumber numberWithInt:-1];
    
    NSError *error = nil;
    
    if ( !  [self.dataController.managedObjectContext save:&error] ) {
        NSLog(@"An error! %@",error);
    }

}

-(void)updateInterface
{
    Trial * trial = [self.dataController fetchTrialWithIndex:self.trialCounter
                                                 forTaskType:self.taskDescriptor
                                                  forSubject:self.subjectID
                                                 fromSession:self.sessionID];
    if (trial.tag > 0) {
        [self.bookmarkTag setSelectedSegmentIndex:[trial.tag intValue]];
    }
    else {
        [self.bookmarkTag setSelectedSegmentIndex:UISegmentedControlNoSegment];
    }
    
    NSString * filteredNotesMessage;
//    if ([trial.tagAnnotation isEqualToString:@"Type notes here"]) {
//        filteredNotesMessage =@"Type notes here";
//    }
//    else{
//        filteredNotesMessage = trial.tagAnnotation;
//    }
    
    filteredNotesMessage = trial.tagAnnotation;

    self.textView.text = filteredNotesMessage;
    
    TaskType * taskType = [self.dataController fetchTaskWithDescriptor:self.taskDescriptor forSubject:self.subjectID fromSession:self.sessionID];
    
    self.title = [NSString stringWithFormat:@"Session %i: Trial %i of %i", [trial.taskType.session.studySessionID intValue], self.trialCounter, [taskType.numTrials intValue]];
    [self makeCustomToolBarTitleWithString:self.title];
    
       
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



- (IBAction)showAlertView:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Redo this trial"
                                                    message:@"Are you sure you want to redo this trial? All edits will be lost (including book mark and notes)."
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
            [self performSegueWithIdentifier:@"RedoCoarse" sender:self];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
     [[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeFine" object:self.taskDescriptor];
    

    [self handleCoarseSegue:segue WithSegueDescriptor:@"RedoCoarse" forTask:self.taskDescriptor];
}


-(void) handleCoarseSegue:(UIStoryboardSegue *)segue WithSegueDescriptor:(NSString*)segueDescriptor forTask:(NSString *)taskDescriptor
{
    if ([[segue identifier] isEqualToString:segueDescriptor]) {
        
        
        //reset all values for trial
        [self.dataController resetSegmentingTimesForTrial:self.trialCounter forTaskType:taskDescriptor forSession:self.sessionID forSubject:self.subjectID];
        
        //reset coarse values for all trial so you can freely place new markers
//        [self.dataController resetOnlyCoarseSegmentingTimesFor:self.subjectID forTaskType:taskDescriptor inSession:self.sessionID];
        


        
        CoarseSegmentViewController * coarseSegmentVC = segue.destinationViewController;
        
        coarseSegmentVC.tabBarController.navigationItem.hidesBackButton = YES;
        
        coarseSegmentVC.allowFreePlacement = YES;
        
        coarseSegmentVC.taskDescriptor = taskDescriptor;

        TaskType * taskType = [self.dataController fetchTaskWithDescriptor:coarseSegmentVC.taskDescriptor forSubject:self.subjectID fromSession:self.sessionID];
        
        coarseSegmentVC.movieURL = [NSURL URLWithString:taskType.movieURLString];
        
        coarseSegmentVC.subjectID = self.subjectID;
        coarseSegmentVC.sessionID = self.sessionID;
        
        coarseSegmentVC.markerCounter = self.trialCounter-1;
        coarseSegmentVC.numTrials = self.trialCounter+1;
        
        coarseSegmentVC.title = [NSString stringWithFormat:@"Trial %i",self.trialCounter];
                
        [coarseSegmentVC.navigationItem setHidesBackButton:YES];
    }
    
    
    if ([[segue identifier] isEqualToString:@"ShowFull"]) {
        
        FineSegmentViewController * fineSegmentVC = segue.destinationViewController;
        
        Trial * currentTrial = [self.dataController fetchTrialWithIndex:self.trialCounter forTaskType:self.taskDescriptor forSubject:self.subjectID fromSession:self.sessionID];

        
        fineSegmentVC.trialCounter = [currentTrial.index intValue];
        fineSegmentVC.taskDescriptor = currentTrial.taskType.descriptor;
        
        fineSegmentVC.subjectID = [currentTrial.taskType.session.subject.subjectID intValue];
        fineSegmentVC.sessionID = [currentTrial.taskType.session.sessionID intValue];
        
        TaskType * taskTypeOfTrial = [self.dataController fetchTaskWithDescriptor:currentTrial.taskType.descriptor
                                                                       forSubject:fineSegmentVC.subjectID
                                                                      fromSession:fineSegmentVC.sessionID];
        
        fineSegmentVC.movieURL = [NSURL URLWithString:taskTypeOfTrial.movieURLString];
        fineSegmentVC.numTrials = [taskTypeOfTrial.trials count];
        
        //        fineSegmentVC.newStartTime = CMTimeMakeWithSeconds([self.currentTrial.fineStartTime floatValue], 600);
        //        fineSegmentVC.newStopTime = CMTimeMakeWithSeconds([self.currentTrial.fineStopTime floatValue], 600);
        
        fineSegmentVC.newStartTime = CMTimeMakeWithSeconds([currentTrial.coarseStartTime floatValue], 600);
        fineSegmentVC.newStopTime = CMTimeMakeWithSeconds([currentTrial.coarseStopTime floatValue], 600);
        
        
        fineSegmentVC.startSliderTime =  fineSegmentVC.newStartTime;
        fineSegmentVC.endSliderTime =  fineSegmentVC.newStopTime;
        
        fineSegmentVC.doShowComment = YES;
        
        
        
        NSString * filteredNotesMessage;
//        if ([currentTrial.tagAnnotation isEqualToString:@"Type notes here"]) {
//            filteredNotesMessage = @"Type notes here";
//        }
//        else{
//            filteredNotesMessage = currentTrial.tagAnnotation;
//        }

        filteredNotesMessage = currentTrial.tagAnnotation;

        self.commentString = filteredNotesMessage;
        
    }
    
    
}

- (IBAction)showFull:(id)sender {
    
    
    Trial * trial = [self.dataController fetchTrialWithIndex:self.trialCounter
                                                 forTaskType:self.taskDescriptor
                                                  forSubject:self.subjectID
                                                 fromSession:self.sessionID];
    
    self.newStartTime = CMTimeMakeWithSeconds([trial.coarseStartTime floatValue], 600);
//    self.initialLeftSliderVal = 0;
    
    self.newStopTime = CMTimeMakeWithSeconds([trial.coarseStopTime floatValue], 600);
//    self.initialRightSliderVal = 1.0;
    
    
//    self.startSliderTime =  self.newStartTime;
//    self.endSliderTime =  self.newStopTime;
    
  
    
}


- (void)syncPlayPauseButtons
{
	if ([self isPlaying]){
        self.bigPlayButton.alpha = .5;
        self.bigPlayButton.enabled = NO;
	}
	else{
        self.bigPlayButton.alpha = 1;
        self.bigPlayButton.enabled = YES;

	}
    
    [super syncPlayPauseButtons];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeFine" object:self.taskDescriptor];

    
//    [self saveEdits];
    
    [super viewWillDisappear:YES];
    
}



- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


@end

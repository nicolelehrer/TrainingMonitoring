//
//  CoarseSegmentViewController.m
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/13/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import "CoarseSegmentViewController.h"
#import "DataController.h"
#import "Trial.h"
#import "AppDelegate.h"
#import "FineSegmentViewController.h"
#import "SegmentTableViewController.h"

@interface CoarseSegmentViewController ()
@property (retain, nonatomic) DataController * dataController;
@property (weak, nonatomic) IBOutlet UIButton *addMarkerButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteLastMarkerButton;
@property (weak, nonatomic) IBOutlet UIButton *startFineTuningButton;


@end

@implementation CoarseSegmentViewController
@synthesize sessionID = _sessionID;
@synthesize subjectID = _subjectID;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize dataController = _dataController;
@synthesize markerCounter = _markerCounter;
@synthesize numTrials = _numTrials;
@synthesize taskDescriptor = _taskDescriptor;
@synthesize allowFreePlacement = _allowFreePlacement;

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
    [self.startFineTuningButton setHidden:YES];
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

-(void)viewWillLayoutSubviews
{
//    [self checkIfMarkersExist];
}

- (IBAction)addTimeMarker:(id)sender {
    
    if (self.markerCounter<self.numTrials) {
        
        self.markerCounter++;

        if (self.markerCounter == 1) {
            [self markerPlacementMethods];
        }
        
        if (self.markerCounter > 1) {
            
            //check to see if previous time is less than new time
            Trial * trialPrevious = [self.dataController fetchTrialWithIndex:self.markerCounter-1
                                                                 forTaskType:self.taskDescriptor
                                                                  forSubject:self.subjectID
                                                                 fromSession:self.sessionID];
            
            float previousTime = [trialPrevious.coarseStartTime floatValue];
            float newTime = CMTimeGetSeconds([self.player currentTime]);
            CMTime newTimeCMTime = [self.player currentTime];
                            
            //can't be equal to end of movie since we subtract from that
            if (CMTIME_COMPARE_INLINE(newTimeCMTime, <, [self.playerItem duration])) {
                
                //check of the new marker is placed after the previous
               
                if (newTime>previousTime) {
                    NSLog(@"Valid placement");
                    [self markerPlacementMethods];
                }
                //if you are redoing this trial the above is ok for first marker
                else{
                    
                    //redoing this trial
                    if (self.allowFreePlacement) {
                
                        //but now need to check if second marker if not before previous
                        if (self.markerCounter<self.numTrials) {
                            NSLog(@"Valid placement - ok becuase it's first marker in freeplacement mode");
                            [self markerPlacementMethods];
                        }
                        else{
                            self.markerCounter--;
                            NSLog(@"NOT valid placement - second marker can't be before first");
                        }
                    }
                    
                    //to catch error in normal editing mode
                    else{
                        self.markerCounter--;
                        NSLog(@"NOT valid placement - second marker can't be before first");
                    }
                }
            }
            else{
                self.markerCounter--;
                NSLog(@"NOT valid placement - can't be equal to end of movie");
            }
        }
    }
    else{
        NSLog(@"markCounter is too big");
    }
}

-(void)markerPlacementMethods
{
    if (!self.allowFreePlacement) {
        
        Trial * trial = [self.dataController fetchTrialWithIndex:self.markerCounter
                                                     forTaskType:self.taskDescriptor
                                                      forSubject:self.subjectID
                                                     fromSession:self.sessionID];
        
        trial.coarseStartTime = [NSNumber numberWithFloat:CMTimeGetSeconds([self.player currentTime])];
        
        trial.coarseSliderStartTime = [NSNumber numberWithFloat:self.movieTimeControl.value];

        if (self.markerCounter > 1 && self.markerCounter <= self.numTrials) {
            Trial * previousTrial = [self.dataController fetchTrialWithIndex:self.markerCounter-1
                                                         forTaskType:self.taskDescriptor
                                                          forSubject:self.subjectID
                                                         fromSession:self.sessionID];
            
            previousTrial.coarseStopTime = trial.coarseStartTime;

        }
        
        if (self.markerCounter == self.numTrials) {
            trial.coarseStopTime = [NSNumber numberWithFloat:CMTimeGetSeconds([self.playerItem duration])];
        }

        
        NSError *error = nil;
        
        if ( !  [self.managedObjectContext save:&error] ) {
            NSLog(@"An error! %@",error);
        }
        
        NSLog(@"coarseTimeLogged for trial number %i is %f", [trial.index intValue], [trial.coarseStartTime floatValue]);
    }
    else{
        if (self.markerCounter<self.numTrials) {
            Trial * trial = [self.dataController fetchTrialWithIndex:self.markerCounter
                                                         forTaskType:self.taskDescriptor
                                                          forSubject:self.subjectID
                                                         fromSession:self.sessionID];
            trial.coarseStartTime = [NSNumber numberWithFloat:CMTimeGetSeconds([self.player currentTime])];
            
            trial.coarseSliderStartTime = [NSNumber numberWithFloat:self.movieTimeControl.value];

        }
        if (self.markerCounter==self.numTrials) {
            Trial * trial = [self.dataController fetchTrialWithIndex:self.markerCounter-1
                                                         forTaskType:self.taskDescriptor
                                                          forSubject:self.subjectID
                                                         fromSession:self.sessionID];
            
            trial.coarseStopTime = [NSNumber numberWithFloat:CMTimeGetSeconds([self.player currentTime])];
        }
        
        
        NSError *error = nil;
        
        if ( !  [self.managedObjectContext save:&error] ) {
            NSLog(@"An error! %@",error);
        }
        
//        NSLog(@"coarseTimeLogged for trial number %i is %f", [trial.index intValue], [trial.coarseStartTime floatValue]);
    
    }
    [self revealMarkerButtons];
    
    if (self.markerCounter == self.numTrials) {
        [self shouldEnableButton:self.addMarkerButton ifFlagIsYes:NO];
        [self.startFineTuningButton setHidden:NO];
    }
}

-(void)checkIfMarkersExist
{
    int i;
    for (i=0; i<5; i++) {
        
        Trial * trial = [self.dataController fetchTrialWithIndex:i+1
                                                     forTaskType:self.taskDescriptor
                                                      forSubject:self.subjectID
                                                     fromSession:self.sessionID];
        
        //if you have already saved a value (you over-wrote initial val of -1)
        
        if ([trial.coarseStartTime floatValue] > 0){
            
//            self.markerCounter++;

//            [self.player seekToTime:CMTimeMakeWithSeconds([trial.coarseStartTime floatValue], 600)
//                    toleranceBefore:kCMTimeZero
//                     toleranceAfter:kCMTimeZero];
            
            [self.movieTimeControl setValue:[trial.coarseSliderStartTime floatValue]];
            
            [self revealMarkerButtons];
            
            if (self.markerCounter == self.numTrials) {
                [self shouldEnableButton:self.addMarkerButton ifFlagIsYes:NO];
                [self.startFineTuningButton setHidden:NO];
                
                [self shouldEnableButton:self.deleteLastMarkerButton ifFlagIsYes:NO];
                [self.startFineTuningButton setHidden:NO];
                
            }
        
        }
    }
    

}


-(void)revealMarkerButtons
{
    if (self.markerCounter <= self.numTrials) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        button.tag = self.markerCounter;
        
        [button setTitle:[NSString stringWithFormat:@"%i", self.markerCounter] forState:UIControlStateNormal];
        
        float buttonSizeX= 75;
        float buttonSizeY= 75;
        
        button.frame = CGRectMake([self xPositionFromSliderValue:self.movieTimeControl]-buttonSizeX/2.0, self.view.frame.size.height/2+70, buttonSizeX, buttonSizeY);
        
        [button setBackgroundImage:[UIImage imageNamed:@"marker.png"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(30.0, 0.0, 0.0, 0.0)];
        
        [button addTarget:self
                   action:@selector(jumpToTimeMarker:basedOnSelector:)
         forControlEvents:UIControlEventTouchDown];
        
        [self.view addSubview:button];
        
        if (self.markerCounter == 1) {
            [self shouldEnableButton:self.deleteLastMarkerButton ifFlagIsYes:YES];
        }
    }
}


-(void)jumpToTimeMarker:(CMTime)timeMarker basedOnSelector:(UIButton*)button
{

    Trial * trial = [self.dataController fetchTrialWithIndex:button.tag forTaskType:self.taskDescriptor forSubject:self.subjectID fromSession:self.sessionID];
    
    
    [self.player seekToTime:CMTimeMakeWithSeconds([trial.coarseStartTime floatValue], 600)
            toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimeZero];
}

- (IBAction)deleteLastMarker:(id)sender {
    
    if (self.markerCounter>0) {
        
        [[self.view viewWithTag:self.markerCounter] removeFromSuperview];
        self.markerCounter--;
        [self.player pause];
        
        if (self.markerCounter >= 1){

            Trial * trial = [self.dataController fetchTrialWithIndex:self.markerCounter forTaskType:self.taskDescriptor forSubject:self.subjectID fromSession:self.sessionID];
            
            [self.player seekToTime:CMTimeMakeWithSeconds([trial.coarseStartTime floatValue], 600)
                    toleranceBefore:kCMTimeZero
                     toleranceAfter:kCMTimeZero];
            
            if (self.markerCounter == self.numTrials-1) {
                [self shouldEnableButton:self.addMarkerButton ifFlagIsYes:YES];
                [self.startFineTuningButton setHidden:YES];
            }
        }
        else {
            [self.player seekToTime:self.newStartTime];
            [self shouldEnableButton:self.deleteLastMarkerButton ifFlagIsYes:NO];
        }
    }
}


- (float)xPositionFromSliderValue:(UISlider *)aSlider;
{
    float sliderRange = aSlider.frame.size.width - aSlider.currentThumbImage.size.width;
    float sliderOrigin = aSlider.frame.origin.x + (aSlider.currentThumbImage.size.width / 2.0);
    float sliderValueToPixels = ((aSlider.value-aSlider.minimumValue)/(aSlider.maximumValue-aSlider.minimumValue)) * sliderRange + sliderOrigin;
    return sliderValueToPixels;
}

-(void)shouldEnableButton:(UIButton *)button ifFlagIsYes:(BOOL)shouldEnable
{
    if (shouldEnable) {
        [button setAlpha:1.0];
        button.userInteractionEnabled = YES;
    }
    else {
        [button setAlpha:0.3];
        button.userInteractionEnabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didFinishCoarseSegment:(id)sender {
    
    Trial * trial = [self.dataController fetchTrialWithIndex:1
                                                 forTaskType:self.taskDescriptor
                                                  forSubject:self.subjectID
                                                 fromSession:self.sessionID];

    
    NSLog(@"from coarseVC %@", trial.taskType.descriptor);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishCoarseSegment" object:trial.taskType.descriptor];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    [self.navigationController popToViewController: [viewControllers objectAtIndex:2] animated: YES];
    

}




- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}





@end

//
//  SurveyViewController.m
//  ClinicianAssist
//
//  Created by Nicole Lehrer on 2/19/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import "SurveyViewController.h"
#import "SurveyAnswer.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "DataController.h"


@interface SurveyViewController ()
@property(nonatomic, retain) DataController * dataController;
@property(retain) NSDictionary * surveyQuestions;
@property (strong, nonatomic) UILabel *followUpLabel;

@property (weak, nonatomic) IBOutlet UILabel *questionDisplay;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;


@property (retain) NSString * annotationText;
@property (nonatomic, retain) UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *questionNumberLabel;
 
@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@property (retain) NSMutableArray * labelArray;
@property (assign) int currentQuestionNumber;
@property (assign) int currentAnswer;
@property (assign) BOOL triggerAnnotation;


@property (weak, nonatomic) IBOutlet UIProgressView *progressSteps;

@property (weak, nonatomic) IBOutlet UIButton *plusMinusButton;

@end

@implementation SurveyViewController
@synthesize surveyQuestions = _surveyQuestions;
@synthesize questionDisplay = _questionDisplay;
@synthesize currentQuestionNumber = _currentQuestionNumber;
@synthesize labelArray = _labelArray;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize currentAnswer = _currentAnswer;
@synthesize triggerAnnotation = _triggerAnnotation;
@synthesize segmentedControl = _segmentedControl;
@synthesize annotationText = _annotationText;
@synthesize textView = _textView;
@synthesize plusMinusButton = _plusMinusButton;
@synthesize followUpLabel = _followUpLabel;
@synthesize questionNumberLabel = _questionNumberLabel;
@synthesize subjectID = _subjectID;
@synthesize sessionID = _sessionID;
@synthesize dataController = _dataController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#define kSegmentedControlHeight 100.0
#define kRightMargin			20.0
#define kTextFieldHeight		30.0

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.dataController = [[DataController alloc] init];
    self.dataController.managedObjectContext = self.managedObjectContext;
    
    [self loadSurveyPlistIntoArray];
    
    self.currentQuestionNumber = 1;
    [self updateDisplayToQuestionNumber:self.currentQuestionNumber];

    [self.backButton setEnabled:NO];
    [self.backButton setAlpha:0];
    
    self.questionDisplay.font = [UIFont fontWithName:@"Arial" size:30];
    self.questionDisplay.numberOfLines = 0;
//    [self.questionDisplay sizeToFit];
    
    self.questionDisplay.lineBreakMode =  NSLineBreakByWordWrapping;
    
    
    [self createControls];
    
    self.triggerAnnotation = NO;
    
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
    
    self.progressSteps.progress = 0.0;
    [self performSelectorOnMainThread:@selector(updateProgressBar) withObject:nil waitUntilDone:NO];
    
    [self updateInterface];
    
    
    //followup
    self.followUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(kRightMargin,
                                                                   self.view.frame.size.height/2 - 60,
                                                                   self.view.frame.size.width - 20,
                                                                   kSegmentedControlHeight)];
    
    self.followUpLabel.font = [UIFont fontWithName:@"Arial" size:20];
    
    self.followUpLabel.backgroundColor = [UIColor clearColor];
    
    self.followUpLabel.lineBreakMode = NSLineBreakByWordWrapping;    
    self.followUpLabel.numberOfLines = 0;
    
    self.followUpLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview: self.followUpLabel];
    
    //customize
    

    

}




- (void)updateProgressBar {
    
    float actual = [self.progressSteps progress];
    if (actual <= 1) {
        float count = [self.surveyQuestions count];
        self.progressSteps.progress = (self.currentQuestionNumber/count);
        [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:NO];
    }
    else{
        NSLog(@"YOURE DONE");
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadSurveyPlistIntoArray
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"SurveyQuestions.plist"];
    self.surveyQuestions = [NSDictionary dictionaryWithContentsOfFile:finalPath];
        
	if (self.surveyQuestions == nil) {
		NSLog( @"surveyQuestions is nil");
    }
    else {
    	NSLog( @"loaded %i components from instructionsDictionary", [self.surveyQuestions count]);
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

-(void)updateDisplayToQuestionNumber:(int)questionNumber
{
    self.title = [NSString stringWithFormat:@"Question %i of %i", self.currentQuestionNumber, [self.surveyQuestions count]];
    
    [self makeCustomToolBarTitleWithString:self.title];
    
    //convert number to key
    [NSString stringWithFormat:@"%i", questionNumber];
    
    NSString * keyString = [@"question" stringByAppendingString:[NSString stringWithFormat:@"%i", questionNumber]];

    NSArray * questionAndAnswers = [self.surveyQuestions objectForKey:keyString];
    
    self.questionDisplay.text = [questionAndAnswers objectAtIndex:0];
    
    //1 question plus 5 answers + 1 follow up
    if ([questionAndAnswers count] > 6) {
        self.triggerAnnotation = YES;
    }
    else{
        self.triggerAnnotation = NO;
    }
    
    int i;
    

        for (i=0; i<5; i++) {

            UILabel * tempLabel = [self.labelArray objectAtIndex:i];

            if (questionNumber < [self.surveyQuestions count]) {
                tempLabel.text = [self updateDisplayToAnswerIndex:i+1 FromQuestionNumber:questionNumber];
            }
            else{
                tempLabel.text = @"";
            }
        }
    
//    self.questionNumberLabel.text = [NSString stringWithFormat:@"%i", self.currentQuestionNumber];

}

-(NSString*)updateDisplayToAnswerIndex:(int)answerIndex FromQuestionNumber:(int)questionNumber
{
    //convert number to key
    [NSString stringWithFormat:@"%i", questionNumber];
    
    NSString * keyString = [@"question" stringByAppendingString:[NSString stringWithFormat:@"%i", questionNumber]];
    
    NSArray * questionAndAnswers = [self.surveyQuestions objectForKey:keyString];
    
    return [questionAndAnswers objectAtIndex:answerIndex];
    
}




-(void)updateInterface
{
    self.followUpLabel.text =@" ";
    
    [self updateDisplayToQuestionNumber:self.currentQuestionNumber];
    [self updateDisplayFromSavedSurveyAnswersForQuestion:self.currentQuestionNumber];
    
    if (self.currentAnswer == -1) {
        [self.segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    }
    else{
        [self.segmentedControl setSelectedSegmentIndex:self.currentAnswer];
    }
    self.textView.text = self.annotationText;
    
    if (self.currentQuestionNumber == [self.surveyQuestions count]) {
        self.segmentedControl.hidden = YES;
    }
    else{
        self.segmentedControl.hidden = NO;
    }   
}

- (IBAction)goToPreviousQuestion:(id)sender {
    [self saveAnswerForQuestion:self.currentQuestionNumber];
    
    if (self.currentQuestionNumber>1) {
        
        self.currentQuestionNumber--;
        
        [self updateInterface];
        
        [self.nextButton setEnabled:YES];
        [self.nextButton setAlpha:1.0];
    }
    else  {
        [self.backButton setEnabled:NO];
        [self.backButton setAlpha:.5];
    }
    if (!self.textView.hidden) {
        [self hideAnnotationView];
    }
}

- (IBAction)goToNextQuestion:(id)sender {
    
    [self saveAnswerForQuestion:self.currentQuestionNumber];
    self.currentQuestionNumber++;

    if (self.currentQuestionNumber <= [self.surveyQuestions count]) {
        
        [self updateInterface];
        
        [self.backButton setEnabled:YES];
        [self.backButton setAlpha:1.0];
        
        if (self.currentQuestionNumber == [self.surveyQuestions count]) {
//            [self.nextButton setTitle:@"Done with survey" forState:UIControlStateNormal];
        }
        
    }
    
    if (!self.textView.hidden && self.currentQuestionNumber < [self.surveyQuestions count]-1) {
        [self hideAnnotationView];
    }
    else{
        [self showAnnotationView];
    }

    
    
    
    if (self.currentQuestionNumber == [self.surveyQuestions count]+1) {
        [self finished];
    }
    
}


-(void)viewWillLayoutSubviews{
    
    CGRect frame = CGRectMake(self.view.bounds.size.width/2 - self.segmentedControl.frame.size.width/2,
                              self.view.bounds.size.height/3 - self.segmentedControl.frame.size.height/2,
                              self.segmentedControl.frame.size.width,
                               self.segmentedControl.frame.size.height);
    
    self.segmentedControl.frame = frame;
    
    
    float oneCellWidth = self.segmentedControl.frame.size.width/5;
     
    
    int i;
    for (i=0; i<5; i++) {
        
        UILabel * label = [self.labelArray objectAtIndex:i];
        
        frame = CGRectMake(self.segmentedControl.frame.origin.x+i*oneCellWidth,
                                  self.segmentedControl.frame.origin.y,
                                  label.frame.size.width,
                                  label.frame.size.height);
        
        label.frame = frame;
        
    }

    frame = CGRectMake( self.segmentedControl.frame.origin.x,
                        self.segmentedControl.frame.origin.y + self.segmentedControl.frame.size.height,
                        self.followUpLabel.frame.size.width,
                        self.followUpLabel.frame.size.height);
    
    self.followUpLabel.frame = frame;
    
    if (self.currentQuestionNumber < [self.surveyQuestions count]) {
        
        frame = CGRectMake( self.followUpLabel.frame.origin.x,
                           self.followUpLabel.frame.origin.y + self.followUpLabel.frame.size.height,
                           self.textView.frame.size.width,
                           124.0f);
    
    }
    else{
        frame = CGRectMake( self.questionDisplay.frame.origin.x,
                           self.questionDisplay.frame.origin.y + self.questionDisplay.frame.size.height,
                           self.textView.frame.size.width,
                           250.0f);
    
    }
    
   
    
    self.textView.frame = frame;
    
    
    
    
}


- (void)createControls
{
	self.segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:@"",@"",@"",@"",@"",nil]];
                                                 
    CGRect frame = CGRectMake(kRightMargin,
                       self.view.frame.size.height/3,
                       self.view.bounds.size.width - (kRightMargin * 2.0),
                       kSegmentedControlHeight);
	self.segmentedControl.frame = frame;
    

	[self.segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
	self.segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
    
    [self.segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
	[self.view addSubview:self.segmentedControl];
    
    
    float oneCellWidth = (self.view.bounds.size.width - (kRightMargin * 2.0))/5;
    
    self.labelArray = [[NSMutableArray alloc] initWithCapacity:5];
    int i;
    for (i=0; i<5; i++) {
        
        
        UILabel * answer1 = [[UILabel alloc] initWithFrame:CGRectMake(oneCellWidth*i,
                                                                      0,
                                                                      oneCellWidth,
                                                                      kSegmentedControlHeight)];
        
        answer1.text =[self updateDisplayToAnswerIndex:i+1 FromQuestionNumber:self.currentQuestionNumber];
        answer1.font = [UIFont fontWithName:@"Arial" size:20];
    
        answer1.backgroundColor = [UIColor clearColor];
        answer1.numberOfLines = 0;
//        [answer1 sizeToFit];
        answer1.textAlignment = NSTextAlignmentCenter;
        
        [self.labelArray addObject:answer1];
        [self.view addSubview:[self.labelArray objectAtIndex:i]];
        
    }
}

- (void)segmentAction:(id)sender
{
//	NSLog(@"segmentAction: selected segment = %d", [sender selectedSegmentIndex]);
    self.currentAnswer = [sender selectedSegmentIndex];

    if ((self.currentAnswer== 0 || self.currentAnswer == 1) && self.triggerAnnotation) {
        self.followUpLabel.text =[self updateDisplayToAnswerIndex:6 FromQuestionNumber:self.currentQuestionNumber];
        
        [self showAnnotationView];
        
    }
    else {
        [self hideAnnotationView];
        self.followUpLabel.text =@" ";
    }
}

-(void) saveAnswerForQuestion:(int)questionIndex
{
    SurveyAnswer * surveyAnswer = [self.dataController fetchSurveyAnswerWithIndex:questionIndex forSubject:self.subjectID fromSession:self.sessionID];
    surveyAnswer.answerValue = [NSNumber numberWithInt:self.currentAnswer];
    surveyAnswer.followUp = self.annotationText;
    
    NSError *error = nil;

    if ( ![self.dataController.managedObjectContext save:&error] ) {
        NSLog(@"An error! %@",error);
    }
}

-(void)updateDisplayFromSavedSurveyAnswersForQuestion:(int)questionIndex
{
    SurveyAnswer * surveyAnswer = [self.dataController fetchSurveyAnswerWithIndex:questionIndex forSubject:self.subjectID fromSession:self.sessionID];
    self.currentAnswer = [surveyAnswer.answerValue intValue];
    self.annotationText = surveyAnswer.followUp;
//    NSLog(@"follow up fpr %i is %@", questionIndex, surveyAnswer.followUp);
//    NSLog(@"annotationText fpr %i is %@", questionIndex, self.annotationText);

}


- (void)textViewDidChange:(UITextView *)textView
{
}

- (void)textViewDidEndEditing:(UITextView *)textView
{    
    self.annotationText = textView.text;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Type annotation text here"]) {
        textView.text = @"";        
    }    
}

- (IBAction)showAnnotation:(id)sender {
    if (self.textView.hidden) {
        [self showAnnotationView];
    }
    else{
        [self hideAnnotationView];
    }
}

-(void)showAnnotationView
{
    [self.plusMinusButton setBackgroundImage:[UIImage imageNamed:@"minus.png"] forState:UIControlStateNormal];
    self.textView.hidden = NO;
        
//    if (self.currentQuestionNumber == [self.surveyQuestions count]) {
//        self.textView.frame =  CGRectMake(20, self.view.frame.size.height/2, self.view.frame.size.width-40.0f, 500.0f);
//        [UITextView beginAnimations:nil context:NULL];
//        [UITextView setAnimationDuration:0.5];
//        self.textView.transform = CGAffineTransformMakeTranslation(0, -100);
//        [UITextView commitAnimations];
//
//    }
//    else{
    
    CGRect frame;
    if (self.currentQuestionNumber < [self.surveyQuestions count]) {
        
        frame = CGRectMake( self.followUpLabel.frame.origin.x,
                           self.followUpLabel.frame.origin.y + self.followUpLabel.frame.size.height,
                           self.textView.frame.size.width,
                          124.0f);
        
    }
    else{
        frame = CGRectMake( self.questionDisplay.frame.origin.x,
                           self.questionDisplay.frame.origin.y + self.questionDisplay.frame.size.height,
                           self.textView.frame.size.width,
                          250.0f);
        
    }
    
    self.textView.frame = frame;
    
}
-(void)hideAnnotationView
{
    [self.plusMinusButton setBackgroundImage:[UIImage imageNamed:@"cross.png"] forState:UIControlStateNormal];
    self.textView.hidden = YES;
}

-(void)finished
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"surveyDone" object:[NSNumber numberWithBool:YES]];
    
    [self dismissViewControllerAnimated:YES completion:NULL];    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}



#pragma mark -
#pragma mark UIResponder Override
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





@end

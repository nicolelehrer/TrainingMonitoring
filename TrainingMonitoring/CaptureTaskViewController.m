//
//  CaptureTaskViewController.m
//  ClinicianAssistant
//
//  Created by Nicole Lehrer on 12/26/12.
//  Copyright (c) 2012 Nicole Lehrer. All rights reserved.
//

#import "CaptureTaskViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#import "CustomPopoverViewController.h"

#import "DataController.h"
#import "AppDelegate.h"



@interface CaptureTaskViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPopoverControllerDelegate>

@property UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UILabel *currentTaskLabel;
@property (weak, nonatomic) IBOutlet UILabel *notifyDoneRecordingLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextTaskButton;
@property (weak, nonatomic) IBOutlet UILabel *taskSetupInstruction;
@property (nonatomic, strong) DataController * dataController;
@property (weak, nonatomic) IBOutlet UIImageView *thubNailPreview;

@property (assign, nonatomic) BOOL inLibraryPickerMode;

@end

@implementation CaptureTaskViewController
@synthesize notifyDoneRecordingLabel = _notifyDoneRecordingLabel;
@synthesize nextTaskButton = _nextTaskButton;

//@synthesize gTaskController = _gTaskController;
@synthesize taskSetupInstruction = _taskSetupInstruction;
@synthesize currentTaskType = _currentTaskType;
@synthesize currentTaskLabel = _currentTaskLabel;
@synthesize stringForTitle = _stringForTitle;
@synthesize stringForInstruction = _stringForInstruction;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize graspCone = _graspCone;
@synthesize elevatedTouch = _elevatedTouch;
@synthesize transport1 = _transport1;
@synthesize transport2 = _transport2;

@synthesize subjectID = _subjectID;
@synthesize sessionID = _sessionID;
@synthesize firstTaskDescriptor = _firstTaskDescriptor;
@synthesize dataController = _dataController;

@synthesize thubNailPreview = _thubNailPreview;


@synthesize inLibraryPickerMode = _inLibraryPickerMode;
@synthesize popover = _popover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        

    }
    return self;
}

- (void)viewDidLoad
{
    
    
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

    self.dataController = [[DataController alloc] init];
    self.dataController.managedObjectContext = self.managedObjectContext;
    
    
    TaskType * task = [self.dataController fetchTaskWithOrder:self.currentTaskType forSubject:self.subjectID fromSession:self.sessionID];
    
    if (task.movieURLString) {
        [self thumbnailFromVideoAtURL:[NSURL URLWithString:task.movieURLString]];
    }
    
 
//    NSLog(@"this task order: %i", [task.order intValue]);
//    NSLog(@"this task name: %@", task.descriptor);
    
//    self.currentTaskLabel.text =  task.descriptor;


    if ([task.descriptor isEqualToString:@"graspCone"]) {
        self.title = [NSString stringWithFormat:@"Task %i: Grasp Cone", self.currentTaskType];
    }
    if ([task.descriptor isEqualToString:@"elevatedTouch"]) {
        self.title = [NSString stringWithFormat:@"Task %i: Elevated Touch", self.currentTaskType];
    }
    if ([task.descriptor isEqualToString:@"transport"]) {
        self.title = [NSString stringWithFormat:@"Task %i: Transport", self.currentTaskType];
    }

    //customize 
    [self makeCustomToolBarTitleWithString:self.title];

    
    
    self.taskSetupInstruction.text = self.stringForInstruction;
    self.notifyDoneRecordingLabel.hidden = YES;
    
    [self.nextTaskButton setHidden:NO];
    

    self.inLibraryPickerMode = NO;
    
    
    [super viewDidLoad];

}


-(void)viewWillLayoutSubviews{

    if (self.interfaceOrientation != UIInterfaceOrientationLandscapeRight)
    {
        [self showAlertView];
    }
}

- (void)showAlertView
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"IPad orientation"
                                                    message:@"Please make sure the iPad is oriented horizontally, with the button on the right hand side."
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)goToVideoCamera:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray * mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        
        if ([mediaTypes containsObject:(NSString*)kUTTypeMovie]) {
            
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
            picker.allowsEditing = NO;
            
            [self presentViewController:picker animated:YES completion:NULL];
            
            
            UIImage * tableOverlay = [UIImage imageNamed:@"overlay.png"];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:tableOverlay];
            
            float positionX = 0;
            float positionY = 0;
            
            float newImageWidth = self.view.frame.size.width;
            float newImageHeight = self.view.frame.size.height;
            
            imageView.frame = CGRectMake(positionX, positionY, newImageWidth, newImageHeight);

            
            picker.cameraOverlayView = imageView;
            
        }
        else {
            NSLog(@"media type not available");
            
        }
    }
}

- (void)prepareSequeObjectWithSegue:(UIStoryboardSegue *)segue withCurrentTaskType:(int)taskType
{
    CaptureTaskViewController * captureTaskViewController = segue.destinationViewController;
    
    captureTaskViewController.currentTaskType = taskType;
    captureTaskViewController.managedObjectContext = self.managedObjectContext;
    
    captureTaskViewController.subjectID = self.subjectID;
    captureTaskViewController.sessionID = self.sessionID;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Task2"]) {
        
        [self prepareSequeObjectWithSegue:segue withCurrentTaskType:2];
    }
    if ([[segue identifier] isEqualToString:@"Task3"]) {
        
        [self prepareSequeObjectWithSegue:segue withCurrentTaskType:3];
    }
    
    
    if ([[segue identifier] isEqualToString:@"Instruction"]) {
        
        CustomPopoverViewController * customPopVC = segue.destinationViewController;
        customPopVC.popUpType = @"Instruction";
        customPopVC.sessionID = self.sessionID;
        
        if ([self.title rangeOfString:@"cone" options:NSCaseInsensitiveSearch].location != NSNotFound) {
             customPopVC.currentTaskType = @"cone";
        }
        if ([self.title rangeOfString:@"transport" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            customPopVC.currentTaskType = @"transport";
        }
        if ([self.title rangeOfString:@"touch" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            customPopVC.currentTaskType = @"touch";
        }
    }
    
    if ([[segue identifier] isEqualToString:@"Setup"]) {
        
        CustomPopoverViewController * customPopVC = segue.destinationViewController;
        customPopVC.popUpType = @"Setup";
        customPopVC.sessionID = self.sessionID;

        if ([self.title rangeOfString:@"cone" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            customPopVC.currentTaskType = @"cone";
        }
        if ([self.title rangeOfString:@"transport" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            customPopVC.currentTaskType = @"transport";
        }
        if ([self.title rangeOfString:@"touch" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            customPopVC.currentTaskType = @"touch";
        }
    }
    
}




- (IBAction)finished:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
//    [self.navigationController popToRootViewControllerAnimated:YES];//root is subjecttablecontroller
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    
    TaskType * task1 = [self.dataController fetchTaskWithOrder:1 forSubject:self.subjectID fromSession:self.sessionID];
    TaskType * task2 = [self.dataController fetchTaskWithOrder:2 forSubject:self.subjectID fromSession:self.sessionID];
    TaskType * task3 = [self.dataController fetchTaskWithOrder:3 forSubject:self.subjectID fromSession:self.sessionID];
    
    if (task1.movieURLString && task2.movieURLString && task3.movieURLString) {
        
        //send finished notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"taskMonitoringDone" object:[NSNumber numberWithBool:YES]];   
    }
    
    
}


-(void)dismissVideoRecorderModalView
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


//from AVCam demo from apples site
- (void) copyFileToDocuments:(NSURL *)fileURL
{
    //prepare file name
        TaskType * task = [self.dataController fetchTaskWithOrder:self.currentTaskType forSubject:self.subjectID fromSession:self.sessionID];

    NSLog(@"task.descriptor: %@", task.descriptor);
    
     NSString * fileName = [[NSString stringWithFormat:@"Subject%iSession%i", self.subjectID, self.sessionID] stringByAppendingString:task.descriptor];
    
    NSLog(@"fileName: %@", fileName);

    
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
	NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"/%@_%@.mov", fileName, [dateFormatter stringFromDate:[NSDate date]]];
    //	[dateFormatter release];
	NSError	*error;
	if (![[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:[NSURL fileURLWithPath:destinationPath] error:&error]) {
        //		if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
        //			[[self delegate] captureManager:self didFailWithError:error];
        //		}
        
        NSLog(@"error wuz here");
	}
    else{
        //you saved a video - this needs to be moved to error checking block below
        self.notifyDoneRecordingLabel.text = @"Saved video";
        
        
        [self.nextTaskButton setHidden:NO];
        [self.notifyDoneRecordingLabel setHidden:NO];

    }

    
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:fileURL
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    
                                    NULL;
                                    //                                    if (error) {
                                    //                                        if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                                    //                                            [[self delegate] captureManager:self didFailWithError:error];
                                    //                                        }
                                    //                                    }
                                    //
                                    //                                    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
                                    //                                        [[UIApplication sharedApplication] endBackgroundTask:[self backgroundRecordingID]];
                                    //                                    }
                                    //
                                    //                                    if ([[self delegate] respondsToSelector:@selector(captureManagerRecordingFinished:)]) {
                                    //                                        [[self delegate] captureManagerRecordingFinished:self];
                                    //                                    }
                                }];
    //    [library release];
    
    
}

#pragma mark UIImagePickerControllerDelegate Methods

-(void)assignURLToTaskWithURL:(NSURL *) URLvideo
{
    TaskType * task = [self.dataController fetchTaskWithOrder:self.currentTaskType forSubject:self.subjectID fromSession:self.sessionID];
    task.movieURLString = [URLvideo absoluteString];
    
    NSError *error = nil;
    
    if ( !  [self.dataController.managedObjectContext save:&error] ) {
                NSLog(@"An error! %@",error);
    }
}

- (void)thumbnailFromVideoAtURL:(NSURL *)videoURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);

//    self.thubNailPreview = [[UIImageView alloc] initWithImage:thumb];
    
//    float newImageWidth = thumb.size.width/2.0;
//    float newImageHeight = thumb.size.height/2.0;

//    float positionX = self.view.frame.size.width/2.0 - newImageWidth;
//    float positionY = self.view.frame.size.height*(2.0/3.0) - newImageHeight;
    
//    imageView.frame = CGRectMake(positionX, positionY, newImageWidth, newImageHeight);
    
    self.thubNailPreview.image = thumb;
//    [self.view addSubview:self.thubNailPreview];
    
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if (!self.inLibraryPickerMode) {
        //handles saving the just recorded video
        NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
        if ([type isEqualToString:(NSString *)kUTTypeMovie]) {
            
            NSURL *urlvideo = [info objectForKey:UIImagePickerControllerMediaURL];
            
            
            if (urlvideo) {
                NSLog(@"urlFound");
                [self copyFileToDocuments:urlvideo];
                [self assignURLToTaskWithURL:urlvideo];
                [self thumbnailFromVideoAtURL:urlvideo];
            }
            else{
                NSLog(@"NO URL FOUND");
            }
        }
        
        [self dismissVideoRecorderModalView];
    }
    else{
    
        
        NSURL *urlvideo = info[UIImagePickerControllerReferenceURL];
        
        if (urlvideo) {
            [self assignURLToTaskWithURL:urlvideo];
            [self thumbnailFromVideoAtURL:urlvideo];
        }
        
        [self.popover dismissPopoverAnimated:YES];
        
        self.inLibraryPickerMode = NO;
    }
   
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.inLibraryPickerMode) {
        [self dismissViewControllerAnimated:YES completion:NULL];
        self.inLibraryPickerMode = NO;
    }
    else{
        [self dismissVideoRecorderModalView];
    }
}

- (IBAction)showLibrary:(id)sender {

    self.inLibraryPickerMode = YES;
    
    if ([self.popover isPopoverVisible]) {
        [self.popover dismissPopoverAnimated:YES];
    }
    
    //Initialize UIImagePickerController to select a movie from the camera roll.
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.delegate = self;
    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    videoPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie];
    

    self.popover = [[UIPopoverController alloc] initWithContentViewController:videoPicker];
    self.popover.delegate = self;
    
    [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
//        [self.popover presentPopoverFromRect:[sender bounds]
//                                      inView:sender
//                    permittedArrowDirections:UIPopoverArrowDirectionUp
//                                    animated:YES];
}





# pragma mark Popover Controller Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.inLibraryPickerMode = NO;
}


-(void)viewWillDisappear:(BOOL)animated
{

    [self.popover dismissPopoverAnimated:YES];
    [super viewWillDisappear:YES];

}


- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}

@end

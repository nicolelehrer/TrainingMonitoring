//
//  CaptureSummaryViewController.m
//  ClinicianAssist
//
//  Created by Nicole Lehrer on 3/16/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import "CaptureSummaryViewController.h"
#import "VideoPlayerViewController.h"


@interface CaptureSummaryViewController ()

@property(nonatomic, retain) VideoPlayerViewController *player;
@property(nonatomic, retain) VideoPlayerViewController *player2;
@property(nonatomic, retain) VideoPlayerViewController *player3;
@property(nonatomic, retain) VideoPlayerViewController *player4;

@end

@implementation CaptureSummaryViewController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize player = _player;
@synthesize player2 = _player2;
@synthesize player3 = _player3;
@synthesize player4 = _player4;

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
    float spacer = 40;
    float width = self.view.frame.size.width/3;
    float height = self.view.frame.size.height/3;

    
//    self.movieURL = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mov"];
    
    [super viewDidLoad];
    
   self.player = [[VideoPlayerViewController alloc] init];
     self.player.URL = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mov"];
     self.player.view.frame = CGRectMake(spacer, spacer, width, height);
    [self.view addSubview: self.player.view];
    //    self.myPlayerViewController = player;
    //    [player release];
    
    
    self.player2 = [[VideoPlayerViewController alloc] init];
     self.player2.URL = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mov"];
     self.player2.view.frame = CGRectMake(spacer*2+width, spacer+height, width, height);
    [self.view addSubview: self.player2.view];
    
    
    self.player3 = [[VideoPlayerViewController alloc] init];
     self.player3.URL = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mov"];
    self.player3.view.frame = CGRectMake(spacer, spacer+height, width, height);
    [self.view addSubview: self.player3.view];
    
    
    self.player4 = [[VideoPlayerViewController alloc] init];
     self.player4.URL = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"mov"];
     self.player4.view.frame = CGRectMake(spacer*2+width, spacer, width, height);
    [self.view addSubview: self.player4.view];
    
}


- (IBAction)playMovies:(id)sender {
    
    [ self.player.player play];
    [ self.player2.player play];
    [ self.player3.player play];
    [ self.player4.player play];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

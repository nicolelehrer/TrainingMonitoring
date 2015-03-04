//
//  TwoMovieViewController.m
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/18/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import "TwoMovieViewController.h"

@interface TwoMovieViewController ()

@end

@implementation TwoMovieViewController
@synthesize fineVC = _fineVC;
@synthesize movieURL = _movieURL;

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
	// Do any additional setup after loading the view.

    self.fineVC = [[FineSegmentViewController alloc] init];
    self.fineVC.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.fineVC.playerLayerView];
    
    [super viewDidLoad];


}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

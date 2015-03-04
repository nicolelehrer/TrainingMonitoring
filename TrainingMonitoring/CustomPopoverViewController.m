//
//  CustomPopoverViewController.m
//  ClinicianAssist
//
//  Created by Nicole Lehrer on 3/5/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import "CustomPopoverViewController.h"

@interface CustomPopoverViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@end

@implementation CustomPopoverViewController
@synthesize imageView;
@synthesize scrollView;
@synthesize popUpType = _popUpType;
@synthesize currentTaskType = _currentTaskType;
@synthesize sessionID = _sessionID;

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

    
    NSString * imageName;
    
    
    if ([self.popUpType isEqualToString:@"Instruction"]) {
    
        imageName = [self.currentTaskType stringByAppendingString:@"Instruct"];
    }
    else{
        imageName = [self.currentTaskType stringByAppendingString:@"Setup"];

    }
    
    if (self.sessionID == 1 && [self.currentTaskType isEqualToString:@"transport"]) {
        imageName = [imageName stringByAppendingString:@"Session1"];
    }
    
    UIImage *image = [UIImage imageNamed:imageName];

    
    
    self.scrollView.delegate = self;
	self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    self.imageView.image = image;

    CGFloat kScrollObjHeight = imageView.image.size.height;
    
	[self.scrollView setContentSize:CGSizeMake([self.scrollView bounds].size.width, kScrollObjHeight)];
    
    self.imageView.frame = CGRectMake(0,0,self.imageView.image.size.width, self.imageView.image.size.height);
    
    self.scrollView.minimumZoomScale = .75;
    self.scrollView.maximumZoomScale = 1.0;
    
    
    }

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

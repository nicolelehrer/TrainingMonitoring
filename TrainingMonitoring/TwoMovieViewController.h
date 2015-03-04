//
//  TwoMovieViewController.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/18/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FineSegmentViewController.h"

@interface TwoMovieViewController : UIViewController
@property (nonatomic, retain) FineSegmentViewController * fineVC;
@property (nonatomic, copy) NSURL * movieURL;

@end

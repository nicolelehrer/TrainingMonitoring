//
//  CustomPopoverViewController.h
//  ClinicianAssist
//
//  Created by Nicole Lehrer on 3/5/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPopoverViewController : UIViewController
@property (nonatomic, retain) NSString * popUpType;
@property (nonatomic, retain) NSString * currentTaskType;
@property (nonatomic, assign) int sessionID;

@end

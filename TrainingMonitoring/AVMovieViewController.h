//
//  AVMovieViewController.h
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/4/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "MyPlayerLayerView.h"

@class AVPlayer;
@class AVPlayerItem;
@class MyPlayerLayerView;

static void *MyStreamingMovieViewControllerRateObservationContext = &MyStreamingMovieViewControllerRateObservationContext;
static void *MyStreamingMovieViewControllerCurrentItemObservationContext = &MyStreamingMovieViewControllerCurrentItemObservationContext;
static void *MyStreamingMovieViewControllerPlayerItemStatusObserverContext = &MyStreamingMovieViewControllerPlayerItemStatusObserverContext;

//NSString * const kTracksKey2		= @"tracks";
//NSString * const kStatusKey2		= @"status";
//NSString * const kRateKey2			= @"rate";
//NSString * const kPlayableKey2		= @"playable";
//NSString * const kCurrentItemKey2	= @"currentItem";

@interface AVMovieViewController : UIViewController

@property(retain) MyPlayerLayerView *playerLayerView;
@property (retain) AVPlayer *player;
@property (retain) AVPlayerItem *playerItem;

@property (nonatomic, copy) NSURL * movieURL;

@property(assign) BOOL isSeeking;
@property(assign) BOOL seekToZeroBeforePlay;
@property(assign) float restoreAfterScrubbingRate;

@property(assign) id timeObserver;

@property (retain) IBOutlet UIToolbar *toolBar;
@property (retain) IBOutlet UIBarButtonItem *playButton;
@property (retain) IBOutlet UIBarButtonItem *stopButton;
@property (retain) IBOutlet UISlider *movieTimeControl;


- (IBAction)beginScrubbing:(id)sender;
- (IBAction)scrub:(id)sender;
- (IBAction)endScrubbing:(id)sender;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;

- (void)syncPlayPauseButtons;

- (void)loadMovieWithURL:(NSURL *)gMovieURL;
- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)assetFailedToPrepareForPlayback:(NSError *)error;
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;

-(void) removePlayerTimeObserver;
-(void) syncScrubber;
-(void) disableScrubber;
-(void) disablePlayerButtons;
-(void) initScrubberTimer;
-(void) enableScrubber;
-(void) enablePlayerButtons;
-(void) showStopButton;

-(void)preventScrubbing:(id)sender;


@property (assign) CMTime newStartTime;
@property (assign) CMTime newStopTime;

@property (assign) CMTime startSliderTime;
@property (assign) CMTime endSliderTime;

@end
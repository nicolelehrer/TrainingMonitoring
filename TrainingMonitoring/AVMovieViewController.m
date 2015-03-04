//
//  AVMovieViewController.m
//  TrainingMonitoring
//
//  Created by Nicole Lehrer on 4/4/13.
//  Copyright (c) 2013 Nicole Lehrer. All rights reserved.
//

#import "AVMovieViewController.h"

@interface AVMovieViewController ()
@end

NSString * const kTracksKey3		= @"tracks";
NSString * const kStatusKey3		= @"status";
NSString * const kRateKey3			= @"rate";
NSString * const kPlayableKey3		= @"playable";
NSString * const kCurrentItemKey3	= @"currentItem";


@implementation AVMovieViewController
@synthesize movieTimeControl = _movieTimeControl;
@synthesize playerLayerView = _playerLayerView;
@synthesize player = _player;
@synthesize playerItem = _playerItem;
@synthesize toolBar = _toolbar;
@synthesize playButton = _playButton;
@synthesize stopButton = _stopButton;
@synthesize timeObserver = _timeObserver;
@synthesize isSeeking = _isSeeking;
@synthesize seekToZeroBeforePlay = _seekToZeroBeforePlay;
@synthesize restoreAfterScrubbingRate = _restoreAfterScrubbingRate;
@synthesize movieURL = _movieURL;
@synthesize newStartTime = _newStartTime;
@synthesize newStopTime = _newStopTime;
@synthesize startSliderTime = _startSliderTime;
@synthesize endSliderTime = _endSliderTime;

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
    [self createInterfaceObjects];
    
    
    [self loadMovieWithURL:self.movieURL];
    
    
    [super viewDidLoad];
    
    
    
}






-(void)createInterfaceObjects
{
    self.playerLayerView = [[MyPlayerLayerView alloc] init];
    self.playerLayerView.frame =  CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2);
    [self.view addSubview:self.playerLayerView];
    
    //
    //    UIImage * trackImage = [UIImage imageNamed:@"Checkmark.png"];
    //
    //    [self.movieTimeControl setMinimumTrackImage:trackImage forState:UIControlStateNormal];
    //    [self.movieTimeControl setMaximumTrackImage:trackImage forState:UIControlStateNormal];
    //
    
    
    
    UIBarButtonItem *scrubberItem = [[UIBarButtonItem alloc] initWithCustomView: self.movieTimeControl];
    
    
    
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    
    
    
    self.toolBar.items = [NSArray arrayWithObjects: self.playButton, flexItem, scrubberItem, nil];
    
}


- (void)loadMovieWithURL:(NSURL *)gMovieURL
{
	if (gMovieURL)
	{
		if ([gMovieURL scheme])
		{
			/*
			 Create an asset for inspection of a resource referenced by a given URL.
			 Load the values for the asset keys "tracks", "playable".
			 */
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:gMovieURL options:nil];
            
			NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey3, kPlayableKey3, nil];
			
			/* Tells the asset to load the values of any of the specified keys that are not already loaded. */
			[asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
			 ^{
				 dispatch_async( dispatch_get_main_queue(),
								^{
									/* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
									[self prepareToPlayAsset:asset withKeys:requestedKeys];
								});
			 }];
		}
	}
    else{
        
        NSLog(@"movieURL not found in movieReviewController");
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    
    NSLog(@"called to be paused");
    
    [self.player pause];
    self.movieURL = nil;
    

        [self.playerLayerView removeFromSuperview];
        self.playerLayerView = nil;
    
    
    [super viewWillDisappear:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Play, Stop Buttons
-(void)showStopButton
{
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[self.toolBar items]];
    [toolbarItems replaceObjectAtIndex:0 withObject:self.stopButton];
    self.toolBar.items = toolbarItems;
}

-(void)showPlayButton
{
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[ self.toolBar items]];
    [toolbarItems replaceObjectAtIndex:0 withObject:self.playButton];
    self.toolBar.items = toolbarItems;
}


-(void)pauseAtTime
{
    if (CMTIME_COMPARE_INLINE([self.player currentTime],>=, self.newStopTime)) {
        //        NSLog(@"time is EQUAL");
        [self.player pause];
        self.seekToZeroBeforePlay = YES;
    }
}


- (void)syncPlayPauseButtons
{
	if ([self isPlaying]){
        [self showStopButton];
	}
	else{
        [self showPlayButton];
	}
}

-(void)enablePlayerButtons
{
    self.playButton.enabled = YES;
    self.stopButton.enabled = YES;
}

-(void)disablePlayerButtons
{
    self.playButton.enabled = NO;
    self.stopButton.enabled = NO;
}

#pragma mark Scrubber control
- (void)syncScrubber
{
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration)) {
        self.movieTimeControl.minimumValue = 0.0;
		return;
	}
	
	double duration = CMTimeGetSeconds(playerDuration);
    
	if (isfinite(duration) && (duration > 0)) {
        
		float minValue = [self.movieTimeControl minimumValue];
		float maxValue = [self.movieTimeControl maximumValue];
		double time = CMTimeGetSeconds([self.player currentTime]);
        
		[self.movieTimeControl setValue:(maxValue - minValue) * (time-CMTimeGetSeconds(self.newStartTime)) / duration + minValue];
    }
}




//Requests invocation of a given block during media playback to update the movie scrubber control.
-(void)initScrubberTimer
{
	double interval = .1f;
	
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration))
	{
		return;
	}
	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration))
	{
		CGFloat width = CGRectGetWidth([ self.movieTimeControl bounds]);
		interval = 0.5f * duration / width;
	}
    
    __weak AVMovieViewController *weakSelf = self; //to prevent a looped retain cycle
    
	self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                  queue:NULL
                                                             usingBlock:
                         ^(CMTime time)
                         {
                             [weakSelf syncScrubber];
                             [weakSelf pauseAtTime];
                             
                         }];
}

//Cancels the previously registered time observer.
-(void)removePlayerTimeObserver
{
	if (self.timeObserver)
	{
		[self.player removeTimeObserver:self.timeObserver];
		self.timeObserver = nil;
	}
}

-(IBAction)scrub:(id)sender {
    if ([sender isKindOfClass:[UISlider class]])
	{
		UISlider* slider = sender;
        
        CMTime playerDuration = [self playerItemDuration];
        
        
        if (CMTIME_IS_INVALID(playerDuration)) {
			return;
		}
		
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration))
		{
			float minValue = [slider minimumValue];
			float maxValue = [slider maximumValue];
			Float64 value = [slider value];
            
  			double time = CMTimeGetSeconds(self.newStartTime) + duration * (value - minValue) / (maxValue - minValue);
            
            [self.player seekToTime:CMTimeMakeWithSeconds(time,600)
                    toleranceBefore:kCMTimeZero
                     toleranceAfter:kCMTimeZero];
            
        }
        
        [self preventScrubbing:sender];
        
        
    }
}

-(void)preventScrubbing:(id)sender
{
}

-(IBAction)endScrubbing:(id)sender {
    if (!self.timeObserver)
	{
		CMTime playerDuration = [self playerItemDuration];
		if (CMTIME_IS_INVALID(playerDuration)){
			return;
		}
		
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration)){
			CGFloat width = CGRectGetWidth([ self.movieTimeControl bounds]);
			double tolerance = 0.5f * duration / width;
            
		    __weak AVMovieViewController *weakSelf = self; //to prevent a looped retain cycle
            
            self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:
                                 ^(CMTime time)
                                 {
                                     [weakSelf syncScrubber];
                                     [weakSelf pauseAtTime];
                                 }];
        }
        
        [self resetTimes:sender];
        
    }
    
	if (self.restoreAfterScrubbingRate){
		[self.player setRate:self.restoreAfterScrubbingRate];
		self.restoreAfterScrubbingRate = 0.f;
	}
    
}

-(void)resetTimes:(id)sender
{
    
    
}

- (BOOL)isScrubbing
{
	return self.restoreAfterScrubbingRate != 0.f;
}

-(void)enableScrubber
{
    self.movieTimeControl.enabled = YES;
}

-(void)disableScrubber
{
    self.movieTimeControl.enabled = NO;
}


-(IBAction)beginScrubbing:(id)sender {
	self.restoreAfterScrubbingRate = [self.player rate];
	[self.player setRate:0.f];
	
	/* Remove previous timer. */
	[self removePlayerTimeObserver];
}

-(IBAction)pause:(id)sender {
    
	[self.player pause];
    [self showPlayButton];
    
}

-(IBAction)play:(id)sender {
    /* If we are at the end of the movie, we must seek to the beginning first
     before starting playback. */
	if (self.seekToZeroBeforePlay)
	{
		self.seekToZeroBeforePlay = NO;
		
        
        [self.player seekToTime:self.newStartTime
                toleranceBefore:kCMTimeZero
                 toleranceAfter:kCMTimeZero];
	
        [self updateVideoWithNewTimes];

    }
    
	[self.player play];
    [self showStopButton];
}

-(void)updateVideoWithNewTimes
{
    //    self.newStartTime = self.startSliderTime;
    //    self.newStopTime = self.endSliderTime;
    //
}


//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    /* Supports all orientations. */
//    return NO;
//}





/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */


- (CMTime)playerItemDuration
{
	AVPlayerItem *thePlayerItem = [self.player currentItem];
	if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay)
	{
        //		return([self.playerItem duration]);
        return CMTimeSubtract(self.newStopTime, self.newStartTime);
	}
    
	return(kCMTimeInvalid);
}


- (BOOL)isPlaying
{
	return self.restoreAfterScrubbingRate != 0.f || [self.player rate] != 0.f;
}

#pragma mark Player Notifications

/* Called when the player item has played to its end time. */
- (void) playerItemDidReachEnd:(NSNotification*) aNotification
{
    [self showPlayButton];
	self.seekToZeroBeforePlay = YES;
    
}





/* --------------------------------------------------------------
 **  Called when an asset fails to prepare for playback for any of
 **  the following reasons:
 **
 **  1) values of asset keys did not load successfully,
 **  2) the asset keys did load successfully, but the asset is not
 **     playable
 **  3) the item did not become ready to play.
 ** ----------------------------------------------------------- */

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self pauseAtTime];
    
    [self disableScrubber];
    [self disablePlayerButtons];
    
    /* Display the error. */
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
														message:[error localizedFailureReason]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

#pragma mark Prepare to play asset

/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    /* Make sure that the value of each key has loaded successfully. */
	for (NSString *thisKey in requestedKeys)
	{
		NSError *error = nil;
		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
		if (keyStatus == AVKeyValueStatusFailed)
		{
			[self assetFailedToPrepareForPlayback:error];
			return;
		}
		/* If you are also implementing the use of -[AVAsset cancelLoading], add your code here to bail
         out properly in the case of cancellation. */
	}
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
		NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
		NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   localizedDescription, NSLocalizedDescriptionKey,
								   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
								   nil];
		NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
	
	/* At this point we're ready to set up for playback of the asset. */
    
	[self initScrubberTimer];
	[self enableScrubber];
	[self enablePlayerButtons];
    
    
    
	
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.playerItem)
    {
        NSLog(@"Remove existing player item key value observers and notifications.");
        
        
        
        [self.playerItem removeObserver:self forKeyPath:kStatusKey3];
		
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
        
    }
	
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.playerItem addObserver:self
                      forKeyPath:kStatusKey3
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:MyStreamingMovieViewControllerPlayerItemStatusObserverContext];
	
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    self.seekToZeroBeforePlay = NO;
	
    /* Create new player, if we don't already have one. */
    if (![self player])
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
		
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [self.player addObserver:self
                      forKeyPath:kCurrentItemKey3
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:MyStreamingMovieViewControllerCurrentItemObservationContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self
                      forKeyPath:kRateKey3
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:MyStreamingMovieViewControllerRateObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.playerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur*/
        [[self player] replaceCurrentItemWithPlayerItem:self.playerItem];
        
        [self syncPlayPauseButtons];
    }
	
    [self.movieTimeControl setValue:0.0];
    
    [self updateVals];
    
    [self.player seekToTime:self.newStartTime
            toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimeZero];
    
}

-(void)updateVals
{
    self.newStartTime = kCMTimeZero;
    
    self.newStopTime = [self.playerItem duration];
}




#pragma mark -
#pragma mark Asset Key Value Observing
#pragma mark

#pragma mark Key Value Observer for player rate, currentItem, player item status

/* ---------------------------------------------------------
 **  Called when the value at the specified key path relative
 **  to the given object has changed.
 **  Adjust the movie play and pause button controls when the
 **  player item "status" value changes. Update the movie
 **  scrubber control when the player item is ready to play.
 **  Adjust the movie scrubber control when the player item
 **  "rate" value changes. For updates of the player
 **  "currentItem" property, set the AVPlayer for which the
 **  player layer displays visual output.
 **  NOTE: this method is invoked on the main queue.
 ** ------------------------------------------------------- */

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
	/* AVPlayerItem "status" property value observer. */
	if (context == MyStreamingMovieViewControllerPlayerItemStatusObserverContext)
	{
		[self syncPlayPauseButtons];
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                [self pauseAtTime];
                
                [self disableScrubber];
                [self disablePlayerButtons];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                self.playerLayerView.playerLayer.hidden = NO;
                
                [self.toolBar setHidden:NO];
                
                /* Show the movie slider control since the movie is now ready to play. */
                self.movieTimeControl.hidden = NO;
                
                [self enableScrubber];
                [self enablePlayerButtons];
                
                /* Set the AVPlayerLayer on the view to allow the AVPlayer object to display
                 its content. */
                [self.playerLayerView.playerLayer setPlayer:self.player];
                
                [self initScrubberTimer];
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *thePlayerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:thePlayerItem.error];
            }
                break;
        }
	}
	/* AVPlayer "rate" property value observer. */
	else if (context == MyStreamingMovieViewControllerRateObservationContext)
	{
        [self syncPlayPauseButtons];
	}
	/* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
	else if (context == MyStreamingMovieViewControllerCurrentItemObservationContext)
	{
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* New player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
            [self disablePlayerButtons];
            [self disableScrubber];
        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            [self.playerLayerView.playerLayer setPlayer:self.player];
            
            /* Specifies that the player should preserve the video’s aspect ratio and
             fit the video within the layer’s bounds. */
            [self.playerLayerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            [self syncPlayPauseButtons];
        }
	}
	else
	{
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
    
    return; 
}





- (void)dealloc
{
    [self.player removeObserver:self forKeyPath:kCurrentItemKey3];
    [self.player.currentItem removeObserver:self forKeyPath:kStatusKey3];
    [self.player removeObserver:self forKeyPath:kRateKey3];
    
    [self.player pause];
    
    self.movieURL = nil;
    self.player = nil;
    self.playerItem = nil;
    self.playerLayerView = nil;
}


@end
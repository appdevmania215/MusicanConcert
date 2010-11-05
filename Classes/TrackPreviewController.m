//
//  TrackPreviewController.m
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "TrackPreviewController.h"
#import "TrackPreviewProgress.h"
#import "AudioStreamer.h"

@implementation TrackPreviewController

@synthesize streamer;
@synthesize previewURL;
@synthesize activity;
@synthesize button;
@synthesize progressView;

-(id)initWithNibName:(NSString*)nibName bundle:(NSBundle*)bundleName
{
	if((self = [super initWithNibName:nibName bundle:bundleName]))
	{
		NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
		
		[center addObserver:self selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:nil];
		[center addObserver:self selector:@selector(streamerError:) name:ASPresentAlertWithTitleNotification object:nil];
		[center addObserver:self selector:@selector(startingPreviewPlayback) name:@"StartingPreviewPlayback" object:nil];
		[center addObserver:self selector:@selector(stopPlayback) name:@"StopPreviewPlayback" object:nil];
	}
	
	return self;
}

-(void)stopPlayback
{
	[progressUpdateTimer invalidate];
	progressUpdateTimer = nil;
	
	[streamer stop];
	[activity stopAnimating];
	self.streamer = nil;
	
	[button setImage:[UIImage imageNamed:@"TrackPreviewPlay.png"] forState:UIControlStateNormal];
	button.hidden = NO;
	
	[progressView setPosition: 0.0];
	[progressView setNeedsDisplay];
}

- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
		
		if (duration > 0 && duration > progress && [streamer isPlaying] == YES)
		{
			double position = (360.0 * (( 1.047 * progress) / duration)) - 3.0;
			
			if (position < 0.0)
			{
				position = 0.0;
			}
			else if(position > 359.0)
			{
				position = 359.0;
			}
			
			if(position < 36)
			{
				[streamer setVolume:(position / 36.0)];
			}
			else if(position > 324)
			{
				[streamer setVolume:(360.0 - position) / 36.0];
			}
			
			if(startFadeOut == YES)
			{
				button.hidden = YES;
				
				[activity startAnimating];
				
				[streamer setVolume:fadeOutStepVolume];
				fadeOutStepVolume -= 0.03;
				
				if(fadeOutStepVolume <= 0.0)
				{
					[self stopPlayback];
					startFadeOut = NO;
				}

				[progressView setPosition:0.0];
			}
			else
			{
				[progressView setPosition:position];
			}
		}
		else if([streamer isPlaying] == NO && duration > 0 && progress > 0)
		{
			[self stopPlayback];
		}
		
		[progressView setNeedsDisplay];
	}
}

- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if( [streamer isPlaying] == YES )
	{
		[activity stopAnimating];
		
		[button setImage:[UIImage imageNamed:@"TrackPreviewStop.png"] forState:UIControlStateNormal];
		button.hidden = NO;
	}
}

- (void)streamerError:(NSNotification *)aNotification
{
	if(firstTime == YES)
	{
		UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Can't play demo now!"
														 message:@"There was a problem connecting to the preview server. Please, try again later."
														delegate:self cancelButtonTitle:@"OK"
											   otherButtonTitles:nil] autorelease];
		[alert show];
		
		firstTime = NO;
		
		[self performSelectorOnMainThread:@selector(stopPlayback) withObject:nil waitUntilDone:NO];
	}
}

-(IBAction)previewTrack:(id)sender
{
	if (streamer == nil)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"StartingPreviewPlayback" object:nil];
		NSURL *url = [NSURL URLWithString:previewURL];
		self.streamer = [[AudioStreamer alloc] initWithURL:url];
		
		[streamer start];
		[streamer setVolume:0.0];
		
		progressUpdateTimer =
		[NSTimer
		 scheduledTimerWithTimeInterval:0.08
		 target:self
		 selector:@selector(updateProgress:)
		 userInfo:nil
		 repeats:YES];
		
		[activity startAnimating];
		
		button.hidden = YES;
	}
	else
	{
		startFadeOut = YES;
		fadeOutStepVolume = 1.0;
	}
	
	firstTime = YES;
}

-(void)startingPreviewPlayback
{
	if (streamer != nil)
	{
		[self stopPlayback];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (void)dealloc
{
    [super dealloc];
}


@end

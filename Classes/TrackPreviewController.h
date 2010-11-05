//
//  TrackPreviewController.h
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioStreamer;
@class TrackPreviewProgress;

@interface TrackPreviewController : UIViewController
{
	NSString* previewURL;
	
	AudioStreamer* streamer;
	
	UIActivityIndicatorView* activity;
	
	UIButton* button;
	
	NSTimer *progressUpdateTimer;
	
	TrackPreviewProgress* progressView;
	
	BOOL startFadeOut;
	BOOL firstTime;
	
	double fadeOutStepVolume;
}

@property (nonatomic, retain) NSString* previewURL;
@property (nonatomic, retain) AudioStreamer* streamer;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activity;
@property (nonatomic, retain) IBOutlet UIButton* button;
@property (nonatomic, retain) IBOutlet TrackPreviewProgress* progressView;

-(IBAction)previewTrack:(id)sender;

@end

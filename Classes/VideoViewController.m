//
//  PhotoViewController.m
//  Area520.com
//
//  Created by Eisen Montalvo on 9/12/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "VideoViewController.h"
#import "EGORefreshTableHeaderView.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation VideoViewController

@synthesize videos;
@synthesize activity;
@synthesize videosTable;
@synthesize moviePlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
        
    }
    return self;
}

-(void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateMovie:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDone) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
}

-(NSString*)getDocumentDirectory
{
	return [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
}

-(NSString*)getCacheFilename
{	
	return [NSString stringWithFormat:@"%@/videos.plist", [self getDocumentDirectory]];
}

-(NSString*)getCacheImageFilenameForVideo:(NSDictionary*)curAlbum
{	
	NSString* thumburl = [[curAlbum objectForKey:@"thumburl"] substringFromIndex:6];
	NSArray* pathComps = [thumburl pathComponents];
	
	return [NSString stringWithFormat:@"%@/thumbnails/%@", [self getDocumentDirectory], [pathComps objectAtIndex:[pathComps count] - 1]];
}

-(NSString*)getCacheImageFilenameForIndex:(int)index
{
	return [self getCacheImageFilenameForVideo:[videos objectAtIndex:index]];
}

-(void)getVideoCovers
{
	NSData* imageData;
	
	for (NSDictionary* video in self.videos)
	{
		NSURL* imageURL = [NSURL URLWithString:[video objectForKey:@"thumburl"]];
		imageData = [NSData dataWithContentsOfURL:imageURL];
		[imageData writeToFile:[self getCacheImageFilenameForVideo:video] atomically:YES];
	}
}

-(UIImage*)getVideoCoverForIndex:(int)index
{
	NSData* imageData;
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[self getCacheImageFilenameForIndex:index]] == YES)
	{
		imageData = [NSData dataWithContentsOfFile:[self getCacheImageFilenameForIndex:index]];
	}
	else
	{
		imageData = nil;
	}
	
	return [[UIImage imageWithData:imageData] thumbnailImage:88 transparentBorder:NO cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
}

-(void)getVideos:(NSString*)urlStr
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSURL *url = [NSURL URLWithString:urlStr];
	
	NSDictionary* data = [NSDictionary dictionaryWithContentsOfURL:url];
	
	self.videos = [data objectForKey:@"videos"];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[videos writeToFile:[self getCacheFilename] atomically:YES];
	
	[self getVideoCovers];
	
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

-(void)getCachedVideos
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	self.videos = [NSArray arrayWithContentsOfFile:[self getCacheFilename]];
	
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int result = [videos count];
	
	if (result == 0)
	{
		result = 1;
	}
	
	return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	int index = [indexPath row];
	
	if([videos count] > 0)
	{
		NSDictionary* data = [videos objectAtIndex:[indexPath row]];
		
		[[cell textLabel] setText:[data objectForKey:@"title"]];
		[[cell textLabel] setTextColor:[UIColor whiteColor]];
		
		[[cell detailTextLabel] setText:[data objectForKey:@"subtitle"]];
		[[cell detailTextLabel] setTextColor:[UIColor whiteColor]];
		
		UIImageView* imageView = [cell imageView];
		UIImage* videoCover = [self getVideoCoverForIndex:index];
		
		[imageView setImage:videoCover];
	}
	else
	{
		[[cell textLabel] setText:@"There are no videos..."];
		[[cell textLabel] setTextColor:[UIColor whiteColor]];
		
		[[cell detailTextLabel] setText:@""];
		[[cell detailTextLabel] setTextColor:[UIColor whiteColor]];
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	
	NSDictionary* selVideo = [videos objectAtIndex:row];
	
	NSURL* url = [NSURL URLWithString:[selVideo objectForKey:@"videourl"]];
	
	self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
	
	[[moviePlayer view] setFrame: [videosTable frame]];  // frame must match parent view
	
	UIImageView* imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]] autorelease];
	[imageView setContentMode:UIViewContentModeScaleAspectFit];
	//[imageView setFrame:[[UIScreen mainScreen] bounds]];
	//[imageView setFrame:[videosTable frame]];
	
	//[[moviePlayer backgroundView] setBackgroundColor:[UIColor clearColor]];
	//[[moviePlayer backgroundView] addSubview:imageView];
	//[[moviePlayer view] setBackgroundColor:[UIColor clearColor]];
	[[self.view superview] addSubview: [moviePlayer view]];
	
	[moviePlayer setFullscreen:YES animated:YES];
	[moviePlayer play];
}

-(void)movieDone
{	
	[[UIDevice currentDevice] setOrientation:UIInterfaceOrientationPortrait];
	[[moviePlayer view] removeFromSuperview];
}

- (void)reloadTableViewDataSource
{
	[self performSelectorInBackground:@selector(getVideos:) withObject:@"http://www.hyem3.com/jjapp/getvideos.php"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{		
	if (scrollView.isDragging)
	{
		float pos = scrollView.contentOffset.y;
		
		if(pos > -65.0 && pos < 0.0)
		{
			[refreshHeaderView setAlpha: pos / -65.0];
		}
		
		if (refreshHeaderView.state == EGOOPullRefreshPulling && pos > -65.0f && pos < 0.0f && !reloading)
		{
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		}
		else if (refreshHeaderView.state == EGOOPullRefreshNormal && pos < -65.0f && !reloading)
		{
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (scrollView.contentOffset.y <= - 65.0f && !reloading)
	{
		reloading = YES;
		[self reloadTableViewDataSource];
		[refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		[self.videosTable setContentInset:UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f)];
		[UIView commitAnimations];
	}
}

- (void)dataSourceDidFinishLoadingNewData
{	
	reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.videosTable setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView setState:EGOOPullRefreshNormal];
	[refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
}

-(void)reloadData
{
	[videosTable reloadData];
	
	[self dataSourceDidFinishLoadingNewData];
	
	[activity stopAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if(refreshHeaderView == nil)
	{
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.videosTable.bounds.size.height, 320.0f, self.videosTable.bounds.size.height)];
		[refreshHeaderView setBackgroundColor:[UIColor clearColor]];
		[self.videosTable addSubview:refreshHeaderView];
		self.videosTable.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[self getCacheFilename]] == YES)
	{
		[self performSelectorInBackground:@selector(getCachedVideos) withObject:nil];
	}
	else
	{
		[activity startAnimating];
		[self performSelectorInBackground:@selector(getVideos:) withObject:@"http://www.hyem3.com/jjapp/getvideos.php"];
	}
}

-(double)getRotationAngle
{
	double result = 0.0;
	switch([[UIDevice currentDevice] orientation])
	{
		case UIDeviceOrientationPortrait:
			break;
			
		case UIDeviceOrientationPortraitUpsideDown:
			result = -M_PI;
			break;
			
		case UIDeviceOrientationLandscapeLeft:
			result = M_PI / 2;
			break;
			
		case UIDeviceOrientationLandscapeRight:
			result = -M_PI / 2;
			break;
	}
	return result;
}

-(CGRect)rotateFrame:(CGRect)inFrame
{
	double temp = inFrame.size.width;
	
	inFrame.size.width = inFrame.size.height;
	inFrame.size.height = temp;
	
	temp = inFrame.origin.y;
	
	inFrame.origin.y = inFrame.origin.x;
	inFrame.origin.x = temp;
	
	return inFrame;
}

-(CGPoint)rotateCenter:(CGPoint)inCenter
{
	double temp = inCenter.y;
	
	inCenter.y = inCenter.x;
	inCenter.x = temp;
	
	return inCenter;
}

-(CGRect)getBounds
{
	//CGRect result = [videosTable frame];
	CGRect result = CGRectMake(0, 0, 320, 367);
	switch([[UIDevice currentDevice] orientation])
	{
		case UIDeviceOrientationLandscapeLeft:
		case UIDeviceOrientationLandscapeRight:
			result = [self rotateFrame:result];
			break;
	}
	
	NSLog(@"Origin: %f %f", result.origin.x, result.origin.y);
	return result;
}

-(CGPoint)getCenter
{
	CGPoint result = [videosTable center];
	switch([[UIDevice currentDevice] orientation])
	{			
		case UIDeviceOrientationLandscapeLeft:		
		case UIDeviceOrientationLandscapeRight:
			//result = [self rotateCenter:result];
			break;
	}
	return result;
}

-(void)rotateMovie:(NSNotification*)note
{
	if(self.moviePlayer != nil)
	{
		[UIView beginAnimations:@"View Rotation" context:nil];
		[UIView setAnimationDuration: 0.5f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		
		moviePlayer.view.transform = CGAffineTransformIdentity;
		moviePlayer.view.transform = CGAffineTransformMakeRotation([self getRotationAngle]);
		
		moviePlayer.view.bounds = [self getBounds];
		moviePlayer.view.center = [self getCenter];
		
		[UIView commitAnimations];
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if([self interfaceOrientation] == UIInterfaceOrientationPortrait)
	{
		[[moviePlayer view] removeFromSuperview];
		self.moviePlayer = nil;
	}
}

-(void)viewWillDisappear:(BOOL)animated
{
	[self movieDone];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
	BOOL result = YES;
	
	if(self.moviePlayer == nil)
	{
		result = (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
	
    return result; 
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

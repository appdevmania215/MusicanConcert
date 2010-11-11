//
//  PhotoViewController.m
//  Area520.com
//
//  Created by Eisen Montalvo on 9/12/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "VideoViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "JJMoviePlayerController.h"

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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackFinish) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
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

-(void)createDirectories
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	BOOL isDir = NO;
	
	NSString* thumbsDirectory = [NSString stringWithFormat:@"%@/thumbnails", [self getDocumentDirectory]];
	
	if([fileManager fileExistsAtPath:thumbsDirectory isDirectory:&isDir] == NO && !isDir)
	{
		[fileManager createDirectoryAtPath:thumbsDirectory withIntermediateDirectories:NO attributes:nil error:nil];
	}
}

-(void)getVideos:(NSString*)urlStr
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	[self getVideoCount:@"http://www.hyem3.com/jjapp/getvideos.php?mode=0" tabIndex:[[self tabBarController] selectedIndex] sign:-1];
	
	NSURL *url = [NSURL URLWithString:urlStr];
	
	NSDictionary* data = [NSDictionary dictionaryWithContentsOfURL:url];
	
	self.videos = [data objectForKey:@"videos"];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[videos writeToFile:[self getCacheFilename] atomically:YES];
	
	[self createDirectories];
	
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
		[[cell textLabel] setText:@"Downloading videos..."];
		[[cell textLabel] setTextColor:[UIColor whiteColor]];
		
		[[cell detailTextLabel] setText:@""];
		[[cell detailTextLabel] setTextColor:[UIColor whiteColor]];
	}
	
    return cell;
}

-(void)moviePlaybackFinish
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveMoviePlayerBackground" object:nil];
	UIDevice* curDevice = [UIDevice currentDevice];
	if( [curDevice respondsToSelector:@selector(setOrientation:)] == YES )
	{
		[curDevice setOrientation:UIInterfaceOrientationPortrait];
	}
	[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UseMoviePlayerBackground" object:nil];
	
	int row = [indexPath row];
	
	NSDictionary* selVideo = [videos objectAtIndex:row];
	
	NSURL* url = [NSURL URLWithString:[selVideo objectForKey:@"videourl"]];
	
	self.moviePlayer = [[JJMoviePlayerController alloc] initWithContentURL:url];
	
	[[(MPMoviePlayerViewController*)moviePlayer moviePlayer] setUseApplicationAudioSession:NO];
	
	[self presentMoviePlayerViewControllerAnimated:(MPMoviePlayerViewController*) moviePlayer];
}

- (void)reloadTableViewDataSource
{
	[self performSelectorInBackground:@selector(getVideos:) withObject:@"http://www.hyem3.com/jjapp/getvideos.php?mode=1"];
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

-(void)updateBadgeValue:(int)index count:(int)count
{
	UITabBarController* tabBarCtrl = [self tabBarController];
	NSArray* tabBarItems = [[tabBarCtrl tabBar] items];
	
	if(index >= [tabBarItems count])
	{
		index = [tabBarItems count] - 1;
	}
	
	UITabBarItem* tabBarItem = [tabBarItems objectAtIndex:index];
	
	int badgeValue = 0;
	
	if([[tabBarItem badgeValue] length] > 0)
	{
		badgeValue = [[tabBarItem badgeValue] intValue];
	}
	
	badgeValue += count;
	
	if(badgeValue > 0)
	{
		[tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d", badgeValue]];
	}
	else
	{
		[tabBarItem setBadgeValue:nil];
	}
}

-(void)reloadData
{
	[videosTable reloadData];
	
	[self dataSourceDidFinishLoadingNewData];
	
	[activity stopAnimating];
}

-(void)getVideoCount:(NSString*)urlStr tabIndex:(int)index sign:(int)sign
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSURL *url = [NSURL URLWithString:urlStr];
	
	NSDictionary* data = [NSDictionary dictionaryWithContentsOfURL:url];
	
	int count = [[data objectForKey:@"videocount"] intValue];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[self getCacheFilename]] == YES && videos == nil)
	{
		self.videos = [NSArray arrayWithContentsOfFile:[self getCacheFilename]];
	}
	
	[self updateBadgeValue:index count:sign * (count - [videos count])];
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
		[self performSelectorInBackground:@selector(getVideos:) withObject:@"http://www.hyem3.com/jjapp/getvideos.php?mode=1"];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

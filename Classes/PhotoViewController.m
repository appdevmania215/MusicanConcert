//
//  AlbumViewController.m
//  Area520.com
//
//  Created by Eisen Montalvo on 9/12/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "PhotoViewController.h"
#import "PictureViewController.h"
#import "ThumbnailViewCell.h"
#import "ThumbnailView.h"
#import "EGORefreshTableHeaderView.h"

@implementation PhotoViewController

@synthesize activity;
@synthesize thumbsTable;
@synthesize tmpCell;
@synthesize thumbs;
@synthesize selThumbnail;
@synthesize pictureViewController;

-(void)awakeFromNib
{
	NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
	
	[center addObserver:self selector:@selector(removeSelection:) name:@"NewThumbnailSelected" object:nil];
}

- (void)removeSelection:(NSNotification*)note
{
	self.pictureViewController = [[PictureViewController alloc] initWithNibName: @"PictureViewController" bundle: nil];
	
	[self.selThumbnail removeSelection];
	
	self.selThumbnail = [note object];
	
	pictureViewController.thumbs = self.thumbs;
	pictureViewController.index = [selThumbnail index];
	
	[[self navigationController] pushViewController:pictureViewController animated:YES];
}

-(NSString*)getDocumentDirectory
{
	return [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
}

-(NSArray*)getPathComponents:(NSDictionary*)thumb
{
	NSString* thumburl = [[thumb objectForKey:@"thumburl"] substringFromIndex:6];
	return [thumburl pathComponents];
}

-(NSString*)getCacheFilename
{	
	return [NSString stringWithFormat:@"%@/thumbnails.plist", [self getDocumentDirectory]];
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
	
	NSString* photosDirectory = [NSString stringWithFormat:@"%@/photos", [self getDocumentDirectory]];
	
	if([fileManager fileExistsAtPath:photosDirectory isDirectory:&isDir] == NO && !isDir)
	{
		[fileManager createDirectoryAtPath:photosDirectory withIntermediateDirectories:NO attributes:nil error:nil];
	}
}

-(NSString*)getCacheImageFilenameForAlbum:(NSDictionary*)curAlbum
{	
	NSString* thumburl = [[curAlbum objectForKey:@"thumburl"] substringFromIndex:6];
	NSArray* pathComps = [thumburl pathComponents];
	
	return [NSString stringWithFormat:@"%@/thumbnails/%@.jpg", [self getDocumentDirectory], [pathComps objectAtIndex:[pathComps count] - 2]];
}

-(void)getThumbnails
{
	NSData* imageData;
	
	for (NSDictionary* thumb in self.thumbs)
	{
		NSURL* imageURL = [NSURL URLWithString:[thumb objectForKey:@"thumburl"]];
		imageData = [NSData dataWithContentsOfURL:imageURL];
		[imageData writeToFile:[self getCacheImageFilenameForAlbum:thumb] atomically:YES];
	}
}

-(void)getThumbs:(NSString*)urlStr
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	[self getPhotoCount:@"http://www.jaimejorge.com/app/getphotos.php?mode=0" tabIndex:[[self tabBarController] selectedIndex] sign:-1];
	
	NSURL *url = [NSURL URLWithString:urlStr];
	
	NSDictionary* data = [NSDictionary dictionaryWithContentsOfURL:url];
	
	self.thumbs = [data objectForKey:@"photos"];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[thumbs writeToFile:[self getCacheFilename] atomically:YES];
	
	[self createDirectories];
	
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

-(void)getCachedThumbs:(NSString*)urlStr
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	self.thumbs = [NSArray arrayWithContentsOfFile:[self getCacheFilename]];
	
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

- (void)reloadTableViewDataSource
{
	[self performSelectorInBackground:@selector(getThumbs:) withObject:@"http://www.jaimejorge.com/app/getphotos.php?mode=1"];
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
		[self.thumbsTable setContentInset:UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f)];
		[UIView commitAnimations];
	}
}

- (void)dataSourceDidFinishLoadingNewData
{	
	if( reloading == YES)
	{
		reloading = NO;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.3];
		[self.thumbsTable setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
		[UIView commitAnimations];
		
		[refreshHeaderView setState:EGOOPullRefreshNormal];
		[refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
	}
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
	[thumbsTable reloadData];
	
	[self dataSourceDidFinishLoadingNewData];
	
	[activity stopAnimating];
}

-(void)getPhotoCount:(NSString*)urlStr tabIndex:(int)index sign:(int)sign
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSURL *url = [NSURL URLWithString:urlStr];
	
	NSDictionary* data = [NSDictionary dictionaryWithContentsOfURL:url];
	
	int count = [[data objectForKey:@"photocount"] intValue];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[self getCacheFilename]] == YES && thumbs == nil)
	{
		self.thumbs = [NSArray arrayWithContentsOfFile:[self getCacheFilename]];
	}

	[self updateBadgeValue:index count:sign * (count - [thumbs count])];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if(refreshHeaderView == nil)
	{
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.thumbsTable.bounds.size.height, 320.0f, self.thumbsTable.bounds.size.height)];
		[refreshHeaderView setBackgroundColor:[UIColor clearColor]];
		[self.thumbsTable addSubview:refreshHeaderView];
		self.thumbsTable.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
	
	if( thumbs == nil )
	{
		if([[NSFileManager defaultManager] fileExistsAtPath:[self getCacheFilename]] == NO)
		{
			[activity startAnimating];
			[self performSelectorInBackground:@selector(getThumbs:) withObject:@"http://www.jaimejorge.com/app/getphotos.php?mode=1"];
		}
		else
		{
			[self performSelectorInBackground:@selector(getCachedThumbs:) withObject:nil];
		}
	}
}

-(void)clearView
{
	self.thumbs = nil;
	[self reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int result = [thumbs count] / 4;
	
	if([thumbs count] % 4 > 0)
	{
		++result;
	}
	return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    ThumbnailViewCell* cell = (ThumbnailViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        [[NSBundle mainBundle] loadNibNamed:@"ThumbnailViewCell" owner:self options:nil];
        cell = tmpCell;
        tmpCell = nil;
    }
	
	int index = [indexPath row];
	
	for( int startIndex = index * 4; startIndex < (index * 4) + 4; ++startIndex)
	{
		if(startIndex < [thumbs count])
		{
			NSString* urlStr = [[thumbs objectAtIndex:startIndex] objectForKey:@"thumburl"];
			ThumbnailView* thumbnail = [cell thumbView:startIndex % 4];
			[thumbnail setThumbUrl:urlStr];
			[thumbnail setIndex:startIndex];
		}
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}

@end

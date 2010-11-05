//
//  MusicViewController.m
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "MusicViewController.h"
#import "AlbumViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "JSON.h"

@implementation MusicViewController

@synthesize albums;
@synthesize albumsTable;
@synthesize activity;
@synthesize albumViewController;

-(void)awakeFromNib
{    
    self.albumViewController = [[AlbumViewController alloc] initWithNibName: @"AlbumViewController" bundle: nil];
}

-(NSString*)getDocumentDirectory
{
	return [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
}

-(NSString*)getCacheFilename
{	
	return [NSString stringWithFormat:@"%@/MusicRoot.json", [self getDocumentDirectory]];
}

-(NSString*)getCacheImageFilenameForIndex:(int)index
{	
	NSDictionary* album = [self.albums objectAtIndex:index];
	return [NSString stringWithFormat:@"%@/%@S.jpg", [self getDocumentDirectory], [album objectForKey:@"collectionId"]];
}

-(NSString*)getCacheImageFilenameForAlbum:(NSDictionary*)album
{	
	return [NSString stringWithFormat:@"%@/%@S.jpg", [self getDocumentDirectory], [album objectForKey:@"collectionId"]];
}

-(void)getCoverImages
{
	NSData* imageData;
	
	for (NSDictionary* album in self.albums)
	{
		NSURL* imageURL = [NSURL URLWithString:[album objectForKey:@"artworkUrl60"]];
		imageData = [NSData dataWithContentsOfURL:imageURL];
		[imageData writeToFile:[self getCacheImageFilenameForAlbum:album] atomically:YES];
	}
}

-(UIImage*)getCoverImageForIndex:(int)index
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

	return [UIImage imageWithData:imageData];
}

-(void)parseAlbums:(NSString*)jsonStr
{
	NSArray* results = [[jsonStr JSONValue] objectForKey:@"results"];
	
	NSMutableArray* actualAlbums = [NSMutableArray arrayWithArray:nil];
	
	for (NSDictionary* album in results)
	{
		NSString* wrapperType = [album objectForKey:@"wrapperType"];
		
		if([wrapperType isEqualToString:@"collection"] == YES)
		{
			[actualAlbums addObject:album];
		}
	}
	
	self.albums = actualAlbums;
}

-(void)eraseCache
{
	NSArray* cacheFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self getDocumentDirectory] error:nil];
	
	for (NSString* cacheFile in cacheFiles)
	{
		NSString* path = [NSString stringWithFormat:@"%@/%@", [self getDocumentDirectory], cacheFile];
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	}
}

- (void)getAlbums
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	// Search for artist albums = http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/wsLookup?id=264493238&entity=album
	NSURL* artistURL = [NSURL URLWithString:@"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/wsLookup?id=264493238&entity=album"];
	NSString* albumsJSON = [NSString stringWithContentsOfURL:artistURL encoding:NSASCIIStringEncoding error:nil];
	
	[self parseAlbums:albumsJSON];
	
	[self eraseCache];
	
	[albumsJSON writeToFile:[self getCacheFilename] atomically:YES encoding:NSASCIIStringEncoding error:nil];
	
	[self getCoverImages];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

-(void)getCachedAlbums
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString* albumsJSON = [NSString stringWithContentsOfFile:[self getCacheFilename] encoding:NSASCIIStringEncoding error:nil];
	
	[self parseAlbums:albumsJSON];
	
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if(refreshHeaderView == nil)
	{
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.albumsTable.bounds.size.height, 320.0f, self.albumsTable.bounds.size.height)];
		[refreshHeaderView setBackgroundColor:[UIColor clearColor]];
		[self.albumsTable addSubview:refreshHeaderView];
		self.albumsTable.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}

	if([[NSFileManager defaultManager] fileExistsAtPath:[self getCacheFilename]] == YES)
	{
		[self performSelectorInBackground:@selector(getCachedAlbums) withObject:nil];
	}
	else
	{
		[self performSelectorInBackground:@selector(getAlbums) withObject:nil];
	}
	
    [activity startAnimating];
}

- (void)reloadTableViewDataSource
{
	[self performSelectorInBackground:@selector(getAlbums) withObject:nil];
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
		[self.albumsTable setContentInset:UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f)];
		[UIView commitAnimations];
	}
}

- (void)dataSourceDidFinishLoadingNewData
{	
	reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.albumsTable setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView setState:EGOOPullRefreshNormal];
	[refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
}

-(void)reloadData
{
	[albumsTable reloadData];
	
	[self dataSourceDidFinishLoadingNewData];
	
	[activity stopAnimating];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [albums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	int index = [indexPath row];
	
	NSDictionary* albumToShow = [albums objectAtIndex:index];
	
	UILabel* titleLabel = [cell textLabel];
	NSString* titleString = [albumToShow objectForKey:@"collectionName"];
	
	[titleLabel setAdjustsFontSizeToFitWidth:YES];
	[titleLabel setText:titleString];
	[titleLabel setTextColor:[UIColor whiteColor]];
	
	UIImageView* imageView = [cell imageView];
	UIImage* albumCover = [self getCoverImageForIndex:index];
	
	[imageView setImage:albumCover];
	
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	
	NSDictionary* selAlbum = [albums objectAtIndex:row];
	
	[albumViewController clearView];
	albumViewController.album = selAlbum;
	
	[albumViewController viewWillAppear:YES];
	[[self navigationController] pushViewController:albumViewController animated:YES];
	[albumViewController viewDidAppear:YES];
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
	self.albumViewController = nil;
    [super dealloc];
}


@end

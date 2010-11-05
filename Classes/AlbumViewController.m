//
//  AlbumViewController.m
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "AlbumViewController.h"
#import "JSON.h"
#import "TrackPreviewController.h"

#define CHARS_PER_LINE 21
#define TRACK_PREVIEW_TAG 7
#define INDEX_LABEL_TAG 77

@implementation AlbumViewController

@synthesize album;
@synthesize albumCover;
@synthesize trackPreviews;
@synthesize trackIndex;
@synthesize tracks;
@synthesize tracksTable;
@synthesize activity;

-(NSString*)getDocumentDirectory
{
	return [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
}

-(NSString*)getCacheFilename
{	
	return [NSString stringWithFormat:@"%@/%@.json", [self getDocumentDirectory], [album objectForKey:@"collectionId"]];
}

-(NSString*)getCacheImageFilename
{	
	return [NSString stringWithFormat:@"%@/%@L.jpg", [self getDocumentDirectory], [album objectForKey:@"collectionId"]];
}

-(void)parseTracks:(NSString*)jsonStr
{
	self.tracks = [[jsonStr JSONValue] objectForKey:@"results"];
}

-(void)getCoverImage
{
	NSData* imageData;
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[self getCacheImageFilename]] == YES)
	{
		imageData = [NSData dataWithContentsOfFile:[self getCacheImageFilename]];
	}
	else
	{
		NSURL* imageURL = [NSURL URLWithString:[[tracks objectAtIndex:0] objectForKey:@"artworkUrl100"]];
		imageData = [NSData dataWithContentsOfURL:imageURL];
		[imageData writeToFile:[self getCacheImageFilename] atomically:YES];
	}
	
	self.albumCover = [UIImage imageWithData:imageData];
}

- (void)getTracks
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	// Search for album tracks = http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/wsLookup?id=<CollectionID>&entity=song
	NSString* albumURLString = [NSString stringWithFormat:@"http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStoreServices.woa/wa/wsLookup?id=%@&entity=song", [album objectForKey:@"collectionId"]];
	NSURL* albumURL = [NSURL URLWithString:albumURLString];
	NSString* tracksJSON = [NSString stringWithContentsOfURL:albumURL encoding:NSASCIIStringEncoding error:nil];
	
	[self parseTracks:tracksJSON];
	
	[tracksJSON writeToFile:[self getCacheFilename] atomically:YES encoding:NSASCIIStringEncoding error:nil];
	
	[self getCoverImage];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

-(void)getCachedTracks
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString* tracksJSON = [NSString stringWithContentsOfFile:[self getCacheFilename] encoding:NSASCIIStringEncoding error:nil];
	
	[self parseTracks:tracksJSON];
	
	[self getCoverImage];
	
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

-(void)reloadData
{
	[tracksTable reloadData];
	
	[activity stopAnimating];
}

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	if(trackPreviews == nil)
	{
		trackPreviews = [[NSMutableDictionary alloc] init];
	}
	
	[activity startAnimating];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StopPreviewPlayback" object:nil];
	
	[activity startAnimating];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[self getCacheFilename]] == YES)
	{
		[self performSelectorInBackground:@selector(getCachedTracks) withObject:nil];
	}
	else
	{
		[self performSelectorInBackground:@selector(getTracks) withObject:nil];
	}
}

-(void)clearView
{
	self.tracks = nil;
	[self reloadData];
}

-(void)buyTrack:(id)sender
{
	int tag = [sender tag];
	NSDictionary* selTrack = [tracks objectAtIndex:tag];
	
	if(tag == 0)
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[selTrack objectForKey:@"collectionViewUrl"]]];
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tracks count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	CGFloat defaultRowHeight = [tableView rowHeight];
	CGFloat extraHeight = 0;
	int row = [indexPath row];
	
	if (row == 0)
	{
		defaultRowHeight = 100.0;
	}
	else
	{
		NSDictionary *item = [tracks objectAtIndex:[indexPath row]];
		
		NSString *title = [item objectForKey:@"trackName"];
		if([title length] > CHARS_PER_LINE * 2)
		{
			extraHeight = 24.0;
		}
		else if([title length] > CHARS_PER_LINE)
		{
			extraHeight = 12.0;
		}
	}

    return defaultRowHeight + extraHeight;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	UILabel *titleLabel;
	CGRect frame;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		titleLabel = [cell textLabel];
		[titleLabel setLineBreakMode: UILineBreakModeWordWrap];
        [titleLabel setNumberOfLines:3];
    }
    
    int index = [indexPath row];
	
	NSDictionary* trackToShow = [tracks objectAtIndex:index];
	
	if ([[trackToShow objectForKey:@"wrapperType"] isEqualToString:@"track"] == YES)
	{
		TrackPreviewController* trackPreviewController = [trackPreviews objectForKey:[NSNumber numberWithInt:index]];
		
		if(trackPreviewController == nil)
		{
			trackPreviewController = [[[TrackPreviewController alloc] initWithNibName: @"TrackPreviewController" bundle: nil] autorelease];
			[trackPreviews setObject:trackPreviewController forKey:[NSNumber numberWithInt:index]];
		}
		
		[trackPreviewController setPreviewURL:[trackToShow objectForKey:@"previewUrl"]];
		
		titleLabel = [cell textLabel];
		NSString* titleString = [trackToShow objectForKey:@"trackName"];
		
		[titleLabel setAdjustsFontSizeToFitWidth:YES];
		[titleLabel setText:titleString];
		[titleLabel setTextColor:[UIColor whiteColor]];
		
		frame = [titleLabel frame];
		
		[[trackPreviewController view] setTag:TRACK_PREVIEW_TAG];
		[[[cell contentView] viewWithTag:TRACK_PREVIEW_TAG] removeFromSuperview];
		[[cell contentView] addSubview:[trackPreviewController view]];
		
		CGRect frame2 = CGRectMake(4, 4, 36, 36);
		CGRect frame3 = CGRectMake(46, 4, 56, 36);
		
		if([titleString length] > CHARS_PER_LINE * 2)
		{
			frame.size.height = 68.0;
			frame2.origin.y = 16;
			frame3.origin.y = 16;
			
		}
		else if([titleString length] > CHARS_PER_LINE)
		{
			frame.size.height = 56.0;
			frame2.origin.y = 10;
			frame3.origin.y = 10;
		}

		[titleLabel setFrame:frame];
		[[trackPreviewController view] setFrame:frame2];
		
		UILabel* indexLabel = [trackIndex objectForKey:[NSNumber numberWithInt:index]];
		
		if(indexLabel == nil)
		{
			indexLabel = [[[UILabel alloc] initWithFrame:frame3] autorelease];
			[indexLabel setTag: INDEX_LABEL_TAG];
			[indexLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
			[indexLabel setBackgroundColor:[UIColor clearColor]];
			[indexLabel setTextColor:[titleLabel textColor]];
			[trackIndex setObject:indexLabel forKey:[NSNumber numberWithInt:index]];
		}
		
		[indexLabel setText:[NSString stringWithFormat:@"%d- ", index]];
		[indexLabel setFrame:frame3];
		
		
		[[[cell contentView] viewWithTag:INDEX_LABEL_TAG] removeFromSuperview];
		[[cell contentView] addSubview:indexLabel];
		
		UIImageView* imageView = [cell imageView];
		[imageView setImage:nil];
		
		[cell setAccessoryView:nil];
		if(index < 10)
		{
			[cell setIndentationLevel:6];
		}
		else
		{
			[cell setIndentationLevel:7];
		}
	}
	else
	{		
		UILabel* titleLabel = [cell textLabel];
		NSString* titleString = [trackToShow objectForKey:@"collectionName"];
		
		[titleLabel setAdjustsFontSizeToFitWidth:YES];
		[titleLabel setText:titleString];
		[titleLabel setTextColor:[UIColor whiteColor]];
		
		UIImageView* imageView = [cell imageView];
		
		[imageView setImage:self.albumCover];
		
		UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		
		[button setTag:index];
		[button setTitle:@"Buy" forState:UIControlStateNormal];
		[button sizeToFit];
		[button addTarget:self action:@selector(buyTrack:) forControlEvents:UIControlEventTouchUpInside ];
		
		[cell setAccessoryView:button];
		[cell setIndentationLevel:0];
	}

    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[trackPreviews objectForKey:[NSNumber numberWithInt:[indexPath row]]] previewTrack:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
	[trackPreviews release];
    [super dealloc];
}

@end


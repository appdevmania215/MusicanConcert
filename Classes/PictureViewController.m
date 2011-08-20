//
//  PictureViewController.m
//  Area520.com
//
//  Created by Eisen Montalvo on 9/17/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "PictureViewController.h"

#define MAX_WIDTH 320
#define MAX_HEIGHT 370

@implementation PictureViewController 

@synthesize thumbs;
@synthesize mainScrollView;
@synthesize index;
@synthesize prevPage;
@synthesize curPage;
@synthesize nextPage;
@synthesize activity;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{

    }
    return self;
}

-(NSString*)getDocumentDirectory
{
	return [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
}

-(NSArray*)getPathComponents:(NSString*)strurl
{
	NSString* thumburl = [strurl substringFromIndex:6];
	return [thumburl pathComponents];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return [[curPage subviews] objectAtIndex:0];
}

-(void)setScrollViewAspectRatio:(UIScrollView*)scrollView
{
	UIImageView* imageView = [[scrollView subviews] objectAtIndex:0];
	UIImage* image = [imageView image];
	
	if(image != nil)
	{
		CGSize size = [image size];
		
		CGFloat ratio = size.width / size.height;
		
		CGRect frame = CGRectMake(0, 0, MAX_WIDTH, MAX_HEIGHT);
		
		if(ratio > 1.0) // Wide
		{
			frame.size.height = frame.size.width / ratio;
			frame.origin.y = (MAX_HEIGHT - frame.size.height) / 2;
		}
		else // Tall
		{
			frame.size.width = frame.size.height * ratio;
			frame.origin.x = (MAX_WIDTH - frame.size.width) / 2;
		}
		
		[imageView setFrame:frame];
	}
}

-(void)setImageViewAspectRatio:(UIView*)view
{
	UIImageView* imageView = (UIImageView*)view;
	UIImage* image = [imageView image];
	
	CGSize size = [image size];
	
	CGFloat ratio = size.width / size.height;
	
	CGRect frame = [view frame];
	
	if(ratio > 1.0) // Wide
	{
		if(frame.size.height < MAX_HEIGHT)
		{
			frame.origin.y = (MAX_HEIGHT - frame.size.height) / 2;;
		}
		else
		{
			frame.origin.y = 0;
		}
	}
	else // Tall
	{
		if(frame.size.width < MAX_WIDTH)
		{
			frame.origin.x = (MAX_WIDTH - frame.size.width) / 2;
		}
		else
		{
			frame.origin.x = 0;
		}
	}
	
	[imageView setFrame:frame];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	[self setImageViewAspectRatio:view];
}

-(NSString*)getPictureFilename:(NSDictionary*)data
{
	NSString* photourl = [data objectForKey:@"photourl"];
	NSArray* elements = [self getPathComponents:photourl];
	
	return [NSString stringWithFormat:@"%@/photos/%@", [self getDocumentDirectory], [elements objectAtIndex:[elements count] - 1]];
}

-(NSString*)getThumbFilename:(NSDictionary*)data
{
	NSString* thumburl = [data objectForKey:@"thumburl"];
	NSArray* elements = [self getPathComponents:thumburl];
	
	return [NSString stringWithFormat:@"%@/thumbnails/%@", [self getDocumentDirectory], [elements objectAtIndex:[elements count] - 1]];
}

-(void)setOffsetForPage:(UIScrollView*)scrollView page:(int)pageNum
{
	CGPoint offset = CGPointMake(MAX_WIDTH * pageNum, 0);
	
	CGRect frame = [scrollView frame];
	
	frame.origin = offset;
	
	[scrollView setFrame:frame];
}

-(void)setThumbnailImageForView:(UIScrollView*)scrollView page:(int)num
{
	UIImageView* imageView = [[scrollView subviews] objectAtIndex:0];
	
	if(num >= 0 && num < [thumbs count])
	{
		UIImage* image = [UIImage imageWithContentsOfFile:[self getThumbFilename:[thumbs objectAtIndex:num]]];
		
		[imageView setImage:image];
		
		[self setScrollViewAspectRatio:scrollView];
	}
	else
	{
		[imageView setImage:nil];
	}
}

-(void)setImageForView:(UIScrollView*)scrollView page:(int)num
{
	UIImageView* imageView = [[scrollView subviews] objectAtIndex:0];
	
	if(num >= 0 && num < [thumbs count])
	{
		[imageView setImage:[UIImage imageWithContentsOfFile:[self getPictureFilename:[thumbs objectAtIndex:num]]]];
	}
	else
	{
		[imageView setImage:nil];
	}
}

-(void)resetScrollView:(UIScrollView*)scrollView
{
	[scrollView setZoomScale:1.0];
	[scrollView setContentSize:CGSizeMake(MAX_WIDTH, MAX_HEIGHT)];
	
	[self setScrollViewAspectRatio:scrollView];
}

-(void)moveToPage:(int)page
{
	[self setOffsetForPage:prevPage page:page - 1];
	[self resetScrollView:prevPage];
	
	[self setOffsetForPage:curPage page:page];
	[self resetScrollView:curPage];
	
	[self setOffsetForPage:nextPage page:page + 1];
	[self resetScrollView:nextPage];
}

-(void)moveToPrevPage
{
	UIScrollView* tmp = curPage;
	
	curPage = prevPage;
	prevPage = nextPage;
	nextPage = tmp;
	
	[self moveToPage:curPageNum - 1];
}

-(void)moveToNextPage
{
	UIScrollView* tmp = curPage;
	
	curPage = nextPage;
	nextPage = prevPage;
	prevPage = tmp;
	
	[self moveToPage:curPageNum + 1];
}

-(void)getCachedPicture:(NSDictionary*)data
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[self setImageForView:curPage page:curPageNum];
	
	[pool release];
}

-(void)noInternet
{	
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Internet required" message:@"Internet required to download the photos. Try again when the device has a connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[[self navigationController] popViewControllerAnimated:YES];
}

-(void)checkForDirectories
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	BOOL isDir = NO;
		
	NSString* photosDirectory = [NSString stringWithFormat:@"%@/photos", [self getDocumentDirectory]];
	
	if([fileManager fileExistsAtPath:photosDirectory isDirectory:&isDir] == NO && !isDir)
	{
		[fileManager createDirectoryAtPath:photosDirectory withIntermediateDirectories:NO attributes:nil error:nil];
	}
}


-(void)getPicture:(NSDictionary*)data
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[self checkForDirectories];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSURL* imageURL = [NSURL URLWithString:[data objectForKey:@"photourl"]];
	NSData* imageData = [NSData dataWithContentsOfURL:imageURL];
	
	if( imageData != nil )
	{
		[imageData writeToFile:[self getPictureFilename:data] atomically:YES];
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
		[self setImageForView:curPage page:curPageNum];
	}
	else
	{
		[self noInternet];
	}
	
	[activity stopAnimating];
	
	[pool release];
}

-(void)getThumbnailForPage:(NSNumber*)page
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	int pageNum = [page intValue];
	
	if(pageNum >= 0 && pageNum < [thumbs count])
	{
		NSDictionary* data = [thumbs objectAtIndex:pageNum];
		
		if([[NSFileManager defaultManager] fileExistsAtPath:[self getThumbFilename:data]] == NO)
		{
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
			
			NSURL* imageURL = [NSURL URLWithString:[data objectForKey:@"thumburl"]];
			NSData* imageData = [NSData dataWithContentsOfURL:imageURL];
			[imageData writeToFile:[self getThumbFilename:data] atomically:YES];
			
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		}
	}
	
	[pool release];
}

-(void)setImageForCurrentPage
{
	if([[NSFileManager defaultManager] fileExistsAtPath:[self getPictureFilename:[thumbs objectAtIndex:curPageNum]]] == YES)
	{
		[self performSelectorInBackground:@selector(getCachedPicture:) withObject:[thumbs objectAtIndex:curPageNum]];
	}
	else
	{
		[activity startAnimating];
		[self performSelectorInBackground:@selector(getPicture:) withObject:[thumbs objectAtIndex:curPageNum]];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	if(scrollView == mainScrollView)
	{
		int offset = (int)([scrollView contentOffset].x) % MAX_WIDTH;
		if(offset == 0)
		{
			int newPage = [scrollView contentOffset].x / MAX_WIDTH;
			
			if(newPage != curPageNum)
			{
				[self resetScrollView:prevPage];
				[self resetScrollView:curPage];
				[self resetScrollView:nextPage];
				
				if(newPage > curPageNum)
				{
					[self moveToNextPage];
				}
				else
				{
					[self moveToPrevPage];
				}

				curPageNum = newPage;
				
				[self setImageForCurrentPage];
				
				[self performSelectorInBackground:@selector(getThumbnailForPage:) withObject:[NSNumber numberWithInt:curPageNum + 1]];
				[self setThumbnailImageForView:nextPage page:curPageNum + 1];
				[self performSelectorInBackground:@selector(getThumbnailForPage:) withObject:[NSNumber numberWithInt:curPageNum - 1]];
				[self setThumbnailImageForView:prevPage page:curPageNum - 1];
				[self performSelectorInBackground:@selector(getThumbnailForPage:) withObject:[NSNumber numberWithInt:curPageNum + 2]];
				[self performSelectorInBackground:@selector(getThumbnailForPage:) withObject:[NSNumber numberWithInt:curPageNum - 2]];
			}
		}
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	CGSize size = CGSizeMake(MAX_WIDTH * [thumbs count], MAX_HEIGHT);
	
	[mainScrollView setContentSize:size];
	
	CGPoint offset = CGPointMake(MAX_WIDTH * index, 0);
	
	[mainScrollView setContentOffset:offset];
	
	[self setThumbnailImageForView:prevPage page:index - 1];
	[self resetScrollView:prevPage];
	[self setThumbnailImageForView:curPage page:index];
	[self resetScrollView:curPage];
	[self setThumbnailImageForView:nextPage page:index + 1];
	[self resetScrollView:nextPage];
	
	[self moveToPage:index];
	
	curPageNum = index;
	
	[self setImageForCurrentPage];
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

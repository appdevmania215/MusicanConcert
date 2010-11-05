//
//  ThumbnailView.m
//  Area520.com
//
//  Created by Eisen Montalvo on 9/13/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "ThumbnailView.h"


@implementation ThumbnailView

@synthesize activity;
@synthesize imageView;
@synthesize imageData;
@synthesize urlStr;
@synthesize borderView;
@synthesize index;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		
    }
    return self;
}

-(NSString*)getDocumentDirectory
{
	return [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
}

-(NSArray*)getPathComponents
{
	NSString* thumburl = [urlStr substringFromIndex:6];
	return [thumburl pathComponents];
}

-(NSString*)getCacheImageFilenameForThumb
{
	NSArray* pathComps = [self getPathComponents];
	
	NSString* albumDirectory = [pathComps objectAtIndex:[pathComps count] - 2];
	
	return [NSString stringWithFormat:@"%@/%@/%@", [self getDocumentDirectory], albumDirectory, [pathComps objectAtIndex:[pathComps count] - 1]];
}

-(NSData*)downloadThumb
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	NSURL* imageURL = [NSURL URLWithString:urlStr];
	NSData* urlData = [NSData dataWithContentsOfURL:imageURL];
	[urlData writeToFile:[self getCacheImageFilenameForThumb] atomically:YES];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	return urlData;
}

-(NSData*)readThumb
{
	return [NSData dataWithContentsOfFile:[self getCacheImageFilenameForThumb]];
}

-(void)getThumb
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSData* data;
	
	NSLock* lock = [[NSLock alloc] init];
	
	[lock lock];
	
	++threadCount;
	
	[lock unlock];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[self getCacheImageFilenameForThumb]] == YES)
	{
		data = [self readThumb];
	}
	else
	{
		[activity startAnimating];
		data = [self downloadThumb];
	}
	
	if(threadCount == 1)
	{
		UIImage* image = [UIImage imageWithData:data];
		
		[lock lock];
		
		[self.imageView setImage:image];
		
		[lock unlock];
		
		[activity stopAnimating];
	}
	
	[lock lock];
	
	--threadCount;
	
	[lock unlock];
	
	[lock release];
	
	[pool release];
}

-(void)setThumbUrl:(NSString*)inUrlStr
{
	[self removeSelection];
	
	[self.imageView setImage:nil];
	
	self.urlStr = inUrlStr;
	[self performSelectorInBackground:@selector(getThumb) withObject:nil];
}

-(void)setImage
{
	[activity stopAnimating];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NewThumbnailSelected" object:self];

	CGSize size = [[imageView image] size];
	
	CGFloat ratio = size.width / size.height;
	
	CGRect frame = CGRectMake(0, 0, 80, 80);
	
	if(ratio > 1.0) // Wide
	{
		frame.size.height = (80 / ratio) + 2;
		frame.origin.y = (80 - frame.size.height) / 2;
	}
	else // Tall
	{
		frame.size.width = (80 * ratio) + 2;
		frame.origin.x = (80 - frame.size.width) / 2;
	}
	
	borderView.frame = frame;
	
	borderView.hidden = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)removeSelection
{
	borderView.hidden = YES;
}

- (void)drawRect:(CGRect)rect
{

}

- (void)dealloc
{
    [super dealloc];
}


@end

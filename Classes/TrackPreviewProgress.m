//
//  TrackPreviewProgress.m
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/22/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "TrackPreviewProgress.h"

#define TO_RAD 0.017453292519943

@implementation TrackPreviewProgress

@synthesize position;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        self.position = 0.0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect parentViewBounds = self.bounds;
	CGFloat x = CGRectGetWidth(parentViewBounds) / 2;
	CGFloat y = CGRectGetHeight(parentViewBounds) / 2;
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth(ctx, 18.5);
	
	double start_angle = (0.0 - 90.0) * TO_RAD;
	double end_angle = (self.position - 90.0) * TO_RAD;
	
	CGContextSetFillColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
	CGContextFillEllipseInRect(ctx, parentViewBounds);
	
	CGContextSetStrokeColorWithColor(ctx, [UIColor darkGrayColor].CGColor);
	CGContextAddArc(ctx, x, y, 9,  start_angle, end_angle, 0);
	CGContextStrokePath(ctx);
}

- (void)dealloc
{
    [super dealloc];
}

@end

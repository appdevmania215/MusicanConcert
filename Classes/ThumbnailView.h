//
//  ThumbnailView.h
//  Area520.com
//
//  Created by Eisen Montalvo on 9/13/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ThumbnailView : UIView
{
	UIActivityIndicatorView* activity;
	UIImageView* imageView;
	
	NSData* imageData;
	
	NSString* urlStr;
	
	UIView* borderView;
	
	int index;
	int threadCount;
}

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView* activity;
@property (retain, nonatomic) IBOutlet UIImageView* imageView;
@property (retain, nonatomic) IBOutlet UIView* borderView;
@property (retain, nonatomic) NSData* imageData;
@property (retain, nonatomic) NSString* urlStr;
@property (assign) int index;

-(void)setThumbUrl:(NSString*)inUrlStr;
-(void)removeSelection;

@end

//
//  AlbumViewController.h
//  Area520.com
//
//  Created by Eisen Montalvo on 9/12/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThumbnailViewCell;
@class ThumbnailView;
@class PictureViewController;
@class EGORefreshTableHeaderView;

@interface PhotoViewController : UIViewController <UITableViewDelegate>
{
	UITableView* thumbsTable;
	
	UIActivityIndicatorView* activity;
	
	ThumbnailViewCell* tmpCell;
	
	ThumbnailView* selThumbnail;
	
	PictureViewController* pictureViewController;
	
	EGORefreshTableHeaderView* refreshHeaderView;
	
	NSArray* thumbs;
	
	BOOL reloading;
}

@property (retain, nonatomic) NSArray* thumbs;
@property (retain, nonatomic) ThumbnailView* selThumbnail;
@property (retain, nonatomic) IBOutlet PictureViewController* pictureViewController;
@property (retain, nonatomic) IBOutlet UITableView* thumbsTable;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView* activity;
@property (retain, nonatomic) IBOutlet ThumbnailViewCell* tmpCell;

-(void)clearView;

@end

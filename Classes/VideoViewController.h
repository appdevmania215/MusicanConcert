//
//  PhotoViewController.h
//  Area520.com
//
//  Created by Eisen Montalvo on 9/12/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EGORefreshTableHeaderView;
@class MPMoviePlayerController;

@interface VideoViewController : UIViewController <UITableViewDelegate>
{
	UITableView* videosTable;
	
	UIActivityIndicatorView* activity;
	
	NSArray* videos;
	
	BOOL reloading;
	
	EGORefreshTableHeaderView* refreshHeaderView;
	
	MPMoviePlayerController* moviePlayer;
}

@property (retain, nonatomic) NSArray* videos;
@property (retain, nonatomic) MPMoviePlayerController* moviePlayer;
@property (retain, nonatomic) IBOutlet UITableView* videosTable;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView* activity;

@end

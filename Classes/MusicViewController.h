//
//  MusicViewController.h
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumViewController;
@class EGORefreshTableHeaderView;

@interface MusicViewController : UIViewController
{
	NSArray* albums;
	
	UITableView* albumsTable;
	
	UIActivityIndicatorView* activity;
	
	AlbumViewController* albumViewController;
	
	EGORefreshTableHeaderView *refreshHeaderView;
	
	BOOL reloading;
}

@property (retain, nonatomic) NSArray* albums;
@property (retain, nonatomic) AlbumViewController* albumViewController;
@property (retain, nonatomic) IBOutlet UITableView* albumsTable;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView* activity;

@end

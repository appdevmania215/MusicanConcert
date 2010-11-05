//
//  AlbumViewController.h
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumViewController : UIViewController
{
	NSDictionary* album;
	NSArray* tracks;
	
	NSMutableDictionary* trackPreviews;
	NSMutableDictionary* trackIndex;
	
	UITableView* tracksTable;
	
	UIImage* albumCover;
	
	UIActivityIndicatorView* activity;
}

@property (retain, nonatomic) NSDictionary* album;
@property (retain, nonatomic) UIImage* albumCover;
@property (retain, nonatomic) NSMutableDictionary* trackPreviews;
@property (retain, nonatomic) NSMutableDictionary* trackIndex;
@property (retain, nonatomic) NSArray* tracks;
@property (retain, nonatomic) IBOutlet UITableView* tracksTable;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView* activity;

-(void)clearView;

@end

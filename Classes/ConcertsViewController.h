//
//  ConcertsViewController.h
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTMLParserDelegate;
@class EGORefreshTableHeaderView;

@interface ConcertsViewController : UIViewController <UITableViewDelegate, NSXMLParserDelegate, UIActionSheetDelegate>
{
	NSXMLParser* parser;
	NSXMLParser* htmlParser;
	
	NSMutableDictionary* concert;
	NSMutableArray* concerts;
	
	UITableView* concertsTable;
	
	HTMLParserDelegate* htmlParserDelegate;
	
	BOOL newConcert;
	BOOL concertTitle;
	BOOL concertDescription;
	BOOL reloading;
	
	int numButtons;
	
	NSIndexPath* savedIndexPath;
	
	UIActivityIndicatorView* activity;
	
	EGORefreshTableHeaderView *refreshHeaderView;
}

@property (retain, nonatomic) NSXMLParser* parser;
@property (retain, nonatomic) NSXMLParser* htmlParser;
@property (retain, nonatomic) HTMLParserDelegate* htmlParserDelegate;
@property (retain, nonatomic) NSMutableDictionary* concert;
@property (retain, nonatomic) NSMutableArray* concerts;
@property (retain, nonatomic) NSIndexPath* savedIndexPath;
@property (retain, nonatomic) IBOutlet UITableView* concertsTable;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView* activity;

@end

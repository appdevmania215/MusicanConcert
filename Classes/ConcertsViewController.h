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

enum {
	CALENDAR = 0,
	MAP,
	CALL
};

@interface ConcertsViewController : UIViewController <UITableViewDelegate, NSXMLParserDelegate, UIActionSheetDelegate>
{
	NSXMLParser* parser;
	NSXMLParser* htmlParser;
	
	NSMutableDictionary* concert;
	NSMutableArray* concerts;
	NSDictionary* selConcert;
	
	UITableView* concertsTable;
	
	UIAlertView* alertView;
	
	HTMLParserDelegate* htmlParserDelegate;
	
	BOOL newConcert;
	BOOL concertTitle;
	BOOL concertDescription;
	BOOL reloading;
	
	int numButtons;
	
	int index2type[4];
	
	NSIndexPath* savedIndexPath;
	
	UIActivityIndicatorView* activity;
	
	EGORefreshTableHeaderView *refreshHeaderView;
	
	NSString* defaultMessage;
}

@property (retain, nonatomic) NSXMLParser* parser;
@property (retain, nonatomic) NSXMLParser* htmlParser;
@property (retain, nonatomic) UIAlertView* alertView;
@property (retain, nonatomic) HTMLParserDelegate* htmlParserDelegate;
@property (retain, nonatomic) NSMutableDictionary* concert;
@property (retain, nonatomic) NSMutableArray* concerts;
@property (retain, nonatomic) NSDictionary* selConcert;
@property (retain, nonatomic) NSIndexPath* savedIndexPath;
@property (retain, nonatomic) NSString* defaultMessage;
@property (retain, nonatomic) IBOutlet UITableView* concertsTable;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView* activity;

@end

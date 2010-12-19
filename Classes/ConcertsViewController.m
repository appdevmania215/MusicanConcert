//
//  ConcertsViewController.m
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "ConcertsViewController.h"
#import "HTMLParserDelegate.h"
#import "EGORefreshTableHeaderView.h"
#import <EventKit/EventKit.h>

@implementation ConcertsViewController

@synthesize parser;
@synthesize htmlParser;
@synthesize htmlParserDelegate;
@synthesize concert;
@synthesize concerts;
@synthesize concertsTable;
@synthesize savedIndexPath;
@synthesize activity;
@synthesize selConcert;
@synthesize alertView;
@synthesize defaultMessage;

#define EVENT_START 0
#define ONE_HOUR_BEFORE -3600
#define ONE_DAY_BEFORE ONE_HOUR_BEFORE * 24

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if( refreshHeaderView == nil )
	{
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.concertsTable.bounds.size.height, 320.0f, self.concertsTable.bounds.size.height)];
		[refreshHeaderView setBackgroundColor:[UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0]];
		[refreshHeaderView setBackgroundColor:[UIColor clearColor]];
		[self.concertsTable addSubview:refreshHeaderView];
		self.concertsTable.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
	
	self.defaultMessage = @"No upcoming concerts.";
	
	[activity startAnimating];
	
	[self performSelectorInBackground:@selector(getConcerts) withObject:nil];
}

- (void)reloadTableViewDataSource
{
	[self performSelectorInBackground:@selector(getConcerts) withObject:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{		
	if (scrollView.isDragging)
	{
		float pos = scrollView.contentOffset.y;
		
		if(pos > -65.0 && pos < 0.0)
		{
			[refreshHeaderView setAlpha: pos / -65.0];
		}
		
		if (refreshHeaderView.state == EGOOPullRefreshPulling && pos > -65.0f && pos < 0.0f && !reloading)
		{
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		}
		else if (refreshHeaderView.state == EGOOPullRefreshNormal && pos < -65.0f && !reloading)
		{
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (scrollView.contentOffset.y <= - 65.0f && !reloading)
	{
		if([concerts count] == 0)
		{
			[activity startAnimating];
			[concertsTable reloadData];
		}
		reloading = YES;
		[self reloadTableViewDataSource];
		[refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		[self.concertsTable setContentInset:UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f)];
		[UIView commitAnimations];
	}
}

- (void)dataSourceDidFinishLoadingNewData
{	
	reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.concertsTable setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView setState:EGOOPullRefreshNormal];
	[refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
}

-(void)getConcerts
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.jaimejorge.com/?feed=gigpress"]];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	self.htmlParserDelegate = [[HTMLParserDelegate alloc] init];
	
	[parser setDelegate:self];
	
	[parser parse];
	
	[pool release];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	[self performSelectorOnMainThread:@selector(noInternet) withObject:nil waitUntilDone:NO];
}

-(NSDate*)dateFromDate:(NSString*)indate time:(NSString*)intime
{
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	
	NSArray* dateElements = [indate componentsSeparatedByString:@", "];
	NSString* newDate = [dateElements objectAtIndex:1];
	dateElements = [newDate componentsSeparatedByString:@" "]; // Discard name of day
	
	NSString* finalDate = [NSString stringWithFormat:@"%@-%@-%@ %@ %@", 
						   [dateElements objectAtIndex:2],
						   [dateElements objectAtIndex:0],
						   [[dateElements objectAtIndex:1] substringToIndex:[[dateElements objectAtIndex:1] length] - 2],
						   [intime substringToIndex:[intime length] - 2],
						   [intime substringFromIndex:[intime length] - 2]];
	
	[dateFormatter setDateFormat:@"yyyy-MMMM-d hh:mm a"];
	
	return [dateFormatter dateFromString:finalDate];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int results = [concerts count];
	
	if(results == 0)
	{
		results = 1;
	}
	
    return results;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	if([concerts count] > 0)
	{
		int index = [indexPath row];
		
		NSDictionary* concertToShow = [concerts objectAtIndex:index];
		
		UILabel* titleLabel = [cell textLabel];
		NSString* titleString = [NSString stringWithFormat:@"%@, %@", [concertToShow objectForKey:@"Venue"], [concertToShow objectForKey:@"City"]];
		
		[titleLabel setAdjustsFontSizeToFitWidth:YES];
		[titleLabel setText:titleString];
		[titleLabel setTextColor:[UIColor whiteColor]];
		
		UILabel* detailLabel = [cell detailTextLabel];
		NSString* detailString = [NSString stringWithFormat:@"%@ - %@", [concertToShow objectForKey:@"Date"], [concertToShow objectForKey:@"Time"]];
		
		[detailLabel setText:detailString];
		[detailLabel setTextColor:[UIColor whiteColor]];
	}
	else
	{
		UILabel* titleLabel = [cell textLabel];
		NSString* titleString;
		
		if([activity isAnimating] == YES)
		{
			titleString = @"Searching for upcoming concerts...";
		}
		else 
		{
			titleString = defaultMessage;
		}
		
		[titleLabel setAdjustsFontSizeToFitWidth:YES];
		[titleLabel setText:titleString];
		[titleLabel setTextColor:[UIColor whiteColor]];
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([concerts count] > 0)
	{
		int row = [indexPath row];
		
		NSString* buttons[4] =
		{
			nil, nil, nil, nil
		};
		
		numButtons = 0;
		
		self.selConcert = [concerts objectAtIndex:row];
		
		for(int i = 0; i < 4; ++i)
		{
			index2type[i] = -1;
		}
		
		UIActionSheet* action;
		
		NSString* address = [selConcert objectForKey:@"Address"];
		NSString* phone = [selConcert objectForKey:@"Venue phone"];
		
		NSDate* eventdate = [self dateFromDate:[selConcert objectForKey:@"Date"] time:[selConcert objectForKey:@"Time"]];
		
		if(eventdate != nil)
		{
			buttons[numButtons] = @"Add event to calendar";
			index2type[numButtons] = CALENDAR;
			++numButtons;
		}
		
		if(address != nil)
		{
			buttons[numButtons] = @"Show venue in map";
			index2type[numButtons] = MAP;
			++numButtons;
		}
		
		if(phone != nil)
		{
			buttons[numButtons] = [NSString stringWithFormat:@"Call venue: %@", [selConcert objectForKey:@"Venue phone"]];
			index2type[numButtons] = CALL;
			++numButtons;
		}
		
		if(numButtons > 0)
		{
			action = [[UIActionSheet alloc] initWithTitle:@"Would you like to..."
												 delegate:self
										cancelButtonTitle:@"Do nothing" 
								   destructiveButtonTitle:nil
										otherButtonTitles:buttons[0], buttons[1], buttons[2], buttons[3], nil];
			
			
			[action showInView:[[self view] superview]];
		}
		else
		{
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
		
		self.savedIndexPath = indexPath;
	}
	else
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString* phoneNumber = [NSString stringWithFormat:@"tel:%@", [selConcert objectForKey:@"Venue phone"]];
	NSString* address;
	NSDate* eventdate;
	
	EKAlarm* alarm;
	EKEvent* event;
	EKCalendar* calendar;
	NSError* error;
	
	EKEventStore* store = [[EKEventStore alloc] init];
	
	// Determine which button was pressed
	switch (index2type[buttonIndex])
	{
		case CALENDAR:
			eventdate = [self dateFromDate:[selConcert objectForKey:@"Date"] time:[selConcert objectForKey:@"Time"]];
			
			event = [EKEvent eventWithEventStore:store];
			
			calendar = [store defaultCalendarForNewEvents];
			
			event.title = @"Jaime Jorge in Concert";
			event.location = [selConcert objectForKey:@"Address"];
			if (phoneNumber != nil)
			{
				event.notes = [NSString stringWithFormat:@"Phone number: %@", [selConcert objectForKey:@"Venue phone"]];
			}
			
			event.startDate = eventdate;
			event.endDate = eventdate;
			event.calendar = calendar;
			
			alarm = [EKAlarm alarmWithRelativeOffset:ONE_DAY_BEFORE]; // Start of event
			[event addAlarm:alarm];
			
			alarm = [EKAlarm alarmWithRelativeOffset:ONE_HOUR_BEFORE]; // One hour before
			[event addAlarm:alarm];
			
			[store saveEvent:event span:EKSpanThisEvent error:&error];
			
			break;
			
		case MAP:
			address = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", [[selConcert objectForKey:@"Address"] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:address]];
			break;
			
		case CALL:
			if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:"]] == NO )
			{
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
			}
			else
			{
				self.alertView = [[UIAlertView alloc] initWithTitle:@"Feature not available" message:@"Your device doesn't support making phone calls. Please, copy the phone number and place the call from another device." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				
				[alertView show];
			}
			
			break;
	}
	
	[store release];
	
	[concertsTable deselectRowAtIndexPath:savedIndexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	self.alertView = nil;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	newConcert = NO;
	self.concerts = [[NSMutableArray alloc] initWithArray:nil];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"item"] == YES)
	{
		self.concert = [[NSMutableDictionary alloc] init];
		newConcert = YES;
	}
	else if ([elementName isEqualToString:@"title"] == YES && newConcert == YES)
	{
		concertTitle = YES;
	}
	else if ([elementName isEqualToString:@"description"] == YES && newConcert == YES)
	{
		concertDescription = YES;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if(newConcert == YES)
	{
		if (concertTitle == YES)
		{
			
		}
	}
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	if(newConcert == YES)
	{
		if (concertDescription == YES)
		{
			self.htmlParser = [[NSXMLParser alloc] initWithData:CDATABlock];
			
			[htmlParser setDelegate:htmlParserDelegate];
			[htmlParserDelegate setConcert:self.concert];
			
			[htmlParser parse];
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if([elementName isEqualToString:@"item"])
	{
		[self.concerts addObject:self.concert];
		self.concert = nil;
		newConcert = NO;
	}
	else if ([elementName isEqualToString:@"title"] == YES && newConcert == YES)
	{
		concertTitle = NO;
	}
	else if ([elementName isEqualToString:@"description"] == YES && newConcert == YES)
	{
		concertDescription = NO;
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)reloadData
{
	[concertsTable reloadData];
	
	[self dataSourceDidFinishLoadingNewData];
	
	[activity stopAnimating];
}

-(void)noInternet
{	
	self.defaultMessage = @"Internet connection required"; 
	
	[concertsTable reloadData];
	
	[activity stopAnimating];
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

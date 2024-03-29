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

//static NSString* kAppId = @"217126961670143"; //Jaime Jorge's FB ID

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
    [cell setBackgroundColor:[UIColor clearColor]];
	if([concerts count] > 0)
	{
		int index = [indexPath row];
		
		NSDictionary* concertToShow = [concerts objectAtIndex:index];
		
		UILabel* titleLabel = [cell textLabel];
		//NSString* titleString = [NSString stringWithFormat:@"%@, %@", [concertToShow objectForKey:@"Venue"], [concertToShow objectForKey:@"City"]];
		NSString* titleString = [NSString stringWithFormat:@"%@", [concertToShow objectForKey:@"City"]];
		
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
		
		NSString* buttons[BUTTONS_SIZE];
		
		numButtons = 0;
		
		self.selConcert = [concerts objectAtIndex:row];
		
		for(int i = 0; i < BUTTONS_SIZE; ++i)
		{
			buttons[i] = nil;
			index2type[i] = -1;
		}
        
        buttons[numButtons] = @"Share this concert";
        index2type[numButtons] = FACEBOOK;
        ++numButtons;
		
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
		
		buttons[numButtons] = [NSString stringWithFormat:@"Tell a friend"];
		index2type[numButtons] = TELL_A_FRIEND;
		++numButtons;
		
		if(numButtons > 0)
		{
			action = [[UIActionSheet alloc] initWithTitle:@"Would you like to..."
												 delegate:self
										cancelButtonTitle:@"Do nothing" 
								   destructiveButtonTitle:nil
										otherButtonTitles:buttons[0], buttons[1], buttons[2], buttons[3],  nil];
			
			
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

-(void)sendEmail
{
	NSString* hiStr = [NSString stringWithFormat:@"Hi! Jaime Jorge will be in concert at %@.", [selConcert objectForKey:@"City"]];
	NSString* venue = @"";
	NSString* date = [NSString stringWithFormat:@"The date is %@ at %@.", [selConcert objectForKey:@"Date"], [selConcert objectForKey:@"Time"]];
	NSString* address = @"";
	NSString* phone = @"";
	
	if([selConcert objectForKey:@"Venue"] != nil )
	{
		venue = [NSString stringWithFormat:@"The concert will be in %@.", [selConcert objectForKey:@"Venue"]];
	}
	
	if([selConcert objectForKey:@"Address"] != nil )
	{
		address = [NSString stringWithFormat:@"If you would like to attend the address is %@.", [selConcert objectForKey:@"Address"]];
	}
	
	if([selConcert objectForKey:@"Venue phone"] != nil )
	{
		phone = [NSString stringWithFormat:@"For more information call %@.", [selConcert objectForKey:@"Venue phone"]];
	}
	
	NSString* messageBody = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", hiStr, venue, date, address, phone];
	
	if([MFMailComposeViewController canSendMail] == YES)
	{	
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		[picker setSubject:NSLocalizedString(@"Jaime Jorge in Concert!", @"Jaime Jorge in Concert!")];
		[picker setToRecipients:[NSArray arrayWithObject:@""]];
		[picker setMessageBody:messageBody isHTML:NO];
		
		picker.navigationBar.barStyle = UIBarStyleBlack;
		
		[self presentModalViewController:picker animated:YES];
		[picker release];
	}
	else
	{
		NSString *recipients = [NSString stringWithFormat:@"mailto:friend@email.here.com?subject=%@&body=%@",NSLocalizedString(@"Jaime Jorge in Concert!", @"Jaime Jorge in Concert!"), messageBody];
		
		NSString *email = [NSString stringWithFormat:@"%@", recipients];
		email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
	
    [self dismissModalViewControllerAnimated:YES];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString* phoneNumber = [NSString stringWithFormat:@"tel:%@", [selConcert objectForKey:@"Venue phone"]];
	NSString* address;
	//NSDate* eventdate;
	
		
	EKEventStore* store = [[EKEventStore alloc] init];
	
	// Determine which button was pressed
	switch (index2type[buttonIndex])
	{
		case CALENDAR:
            
            if([store respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
                // need user permission for iOS 6 and later
                [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                    if (granted) {
                        EKAlarm* alarm;
                        EKEvent* event;
                        EKCalendar* calendar;
                        NSError* error;
                        NSDate* eventdate;
                        
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

                        
                        }
                    else {
                       }
                }];
            }
            
						
			break;
			
		case MAP:
			address = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", [[selConcert objectForKey:@"Address"] stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
            //address = [NSString stringWithFormat:@"http://maps.google.com/maps?&amp;q=3440+SW+Urish+Rd,Topeka+KS+66614-4601,785-478-4726,US"];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:address]];
			break;
			
		case CALL:
			if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:"]] == YES )
			{
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
			}
			else
			{
				self.alertView = [[UIAlertView alloc] initWithTitle:@"Feature not available" message:@"Your device doesn't support making phone calls. Please, copy the phone number and place the call from another device." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				
				[alertView show];
			}
			
			break;
			
		case TELL_A_FRIEND:     //SHOULD "DO NOTHING"
			[self sendEmail];  // JF
            
			break;
            
        case FACEBOOK:
            //[self shareOnFacebook]; // JF
           
            NSLog(@"Sharing...");
            
            NSString* hiStr = [NSString stringWithFormat:@"Hi! Jaime Jorge will be in concert at %@.", [selConcert objectForKey:@"City"]];
            NSString* venue = @"";
            NSString* date = [NSString stringWithFormat:@"Date is %@ at %@.", [selConcert objectForKey:@"Date"], [selConcert objectForKey:@"Time"]];
            NSString* address = @"";
            NSString* phone = @"";
            
            if([selConcert objectForKey:@"Venue"] != nil )
            {
                venue = [NSString stringWithFormat:@"The concert will be in %@.", [selConcert objectForKey:@"Venue"]];
            }
            
            if([selConcert objectForKey:@"Address"] != nil )
            {
                address = [NSString stringWithFormat:@"The address is %@.", [selConcert objectForKey:@"Address"]];
            }
            
            if([selConcert objectForKey:@"Venue phone"] != nil )
            {
                phone = [NSString stringWithFormat:@"For information call %@.", [selConcert objectForKey:@"Venue phone"]];
            }
            
            NSString* messageBody = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", hiStr, venue, date, address, phone];
            
            NSArray *activityItems = [NSArray arrayWithObjects:messageBody, nil];
            
            UIActivityViewController *activityVC =
            [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                              applicationActivities:nil];
            [self presentViewController:activityVC animated:YES completion:nil];
            
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
//			self.htmlParser = [[NSXMLParser alloc] initWithData:CDATABlock];
//			[htmlParser setDelegate:htmlParserDelegate];
//			[htmlParserDelegate setConcert:self.concert];
//			[htmlParser parse];
            
            NSMutableString *parseText = [[NSMutableString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
            NSString *temp1 = [parseText stringByReplacingOccurrencesOfString:@"<ul>" withString:@""];
            temp1 = [temp1 stringByReplacingOccurrencesOfString:@"</ul>" withString:@""];
            temp1 = [temp1 stringByReplacingOccurrencesOfString:@"</li>" withString:@""];
            temp1 = [temp1 stringByReplacingOccurrencesOfString:@"<strong>" withString:@""];
            temp1 = [temp1 stringByReplacingOccurrencesOfString:@"</strong>" withString:@""];
            temp1 = [temp1 stringByReplacingOccurrencesOfString:@": " withString:@"!!"];
            NSArray *value = [temp1 componentsSeparatedByString:@"<li>"];
            
            for (int i=0;i<value.count;i++){
                NSArray *temp2;
                if(i==2){
                    temp2= [value[i] componentsSeparatedByString:@":\n"];
                }else{
                     temp2 = [value[i] componentsSeparatedByString:@"!!"];
                }
                if(temp2.count==2){
                     NSString * key = [temp2[0] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    NSString * value_ = [temp2[1] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    value_ = [value_ stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    if([key isEqualToString:@"Address"]){
                        value_ = [value_ stringByReplacingOccurrencesOfString:@"</a></li>" withString:@""];
                        NSArray * temp3 = [value_ componentsSeparatedByString:@"\">"];
                        value_ = temp3[1];
                        value_ = [value_ stringByReplacingOccurrencesOfString:@"</a>" withString:@""];
                    }
                    [self.concert setObject:value_ forKey:key];
                }
                
            }
            int j=0;
            
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

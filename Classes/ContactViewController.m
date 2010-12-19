//
//  ContactViewController.m
//  JaimeJorge
//
//  Created by Eisen Montalvo on 10/31/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "ContactViewController.h"

@implementation ContactViewController

@synthesize callButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:"]] == YES)
	{
		[callButton setEnabled:YES];
	}
	else
	{
		[callButton setBackgroundImage:nil forState:UIControlStateNormal];
	}
}

-(IBAction)sendEmail:(id)sender
{
	NSString* messageBody = [NSString stringWithFormat:@"<Write your message here>"];
	
	if([MFMailComposeViewController canSendMail] == YES)
	{	
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		[picker setSubject:NSLocalizedString(@"Information request", @"Information request")];
		[picker setToRecipients:[NSArray arrayWithObject:@"bookings@jaimejorge.com"]];
		[picker setMessageBody:messageBody isHTML:NO];
		
		picker.navigationBar.barStyle = UIBarStyleBlack;
		
		[self presentModalViewController:picker animated:YES];
		[picker release];
	}
	else
	{
		NSString *recipients = [NSString stringWithFormat:@"mailto:bookings@jaimejorge.com?subject=%@&body=%@",NSLocalizedString(@"Information request", @"Information request"), messageBody];
		
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

-(IBAction)callNumber:(id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:1-888-501-9882"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)twitter:(id)sender
{
	UIApplication* app = [UIApplication sharedApplication];
	
	if([app canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=jaimejorgemusic"]] == YES )
	{
		[app openURL:[NSURL URLWithString:@"twitter://user?screen_name=jaimejorgemusic"]];
	}
	else
	{
		[app openURL:[NSURL URLWithString:@"http://twitter.com/jaimejorgemusic"]];
	}
}

-(IBAction)facebook:(id)sender
{
	UIApplication* app = [UIApplication sharedApplication];
	
//  if(![app openURL:[NSURL URLWithString:@"fb://profile/439925475153"]] )
//  {
//		[app openURL:[NSURL URLWithString:@"fb://profile/439925475153"]];
//	}
//	else
//	{
		[app openURL:[NSURL URLWithString:@"http://www.facebook.com/pages/Fans-of-Jaime-Jorge/439925475153"]];
//	}
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

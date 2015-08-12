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
    _emailbtn.layer.cornerRadius =5;
    _emailbtn.layer.borderWidth =1;
    _emailbtn.layer.borderColor =[UIColor grayColor].CGColor;
       
    _callbtn.layer.cornerRadius =5;
    _callbtn.layer.borderWidth =1;
    _callbtn.layer.borderColor =[UIColor grayColor].CGColor;

    _twitterbtn.layer.cornerRadius =5;
    _twitterbtn.layer.borderWidth =1;
    _twitterbtn.layer.borderColor =[UIColor grayColor].CGColor;
    
    _facebookbtn.layer.cornerRadius =5;
    _facebookbtn.layer.borderWidth =1;
    _facebookbtn.layer.borderColor =[UIColor grayColor].CGColor;
    
    _insagrambtn.layer.cornerRadius =5;
    _insagrambtn.layer.borderWidth =1;
    _insagrambtn.layer.borderColor =[UIColor grayColor].CGColor;
    
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
	
  if([app canOpenURL:[NSURL URLWithString:@"fb://profile/439925475153"]]==YES )
  {
		[app openURL:[NSURL URLWithString:@"fb://profile/439925475153"]];
	}
	else
	{
		[app openURL:[NSURL URLWithString:@"http://www.facebook.com/pages/Fans-of-Jaime-Jorge/439925475153"]];
	}
}

-(IBAction)instagram:(id)sender
{
    UIApplication* app = [UIApplication sharedApplication];
    
    if([app canOpenURL:[NSURL URLWithString:@"instagram://user?id=367933671"]]==YES )
      {
    		[app openURL:[NSURL URLWithString:@"instagram://user?id=367933671"]];
    	}
    	else
    	{
    [app openURL:[NSURL URLWithString:@"http://instagram.com/jaimejorgemusic"]];
    	}
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

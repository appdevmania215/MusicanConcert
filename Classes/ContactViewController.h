//
//  ContactViewController.h
//  JaimeJorge
//
//  Created by Eisen Montalvo on 10/31/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ContactViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
	UIButton* callButton;
}

@property (retain, nonatomic) IBOutlet UIButton* callButton;

-(IBAction)sendEmail:(id)sender;
-(IBAction)callNumber:(id)sender;
-(IBAction)mailingAddress:(id)sender;

@end

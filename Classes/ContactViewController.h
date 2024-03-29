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
-(IBAction)twitter:(id)sender;
-(IBAction)facebook:(id)sender;
-(IBAction)instagram:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton* emailbtn;
@property (retain, nonatomic) IBOutlet UIButton* callbtn;
@property (retain, nonatomic) IBOutlet UIButton* twitterbtn;
@property (retain, nonatomic) IBOutlet UIButton* facebookbtn;
@property (retain, nonatomic) IBOutlet UIButton* insagrambtn;
@end

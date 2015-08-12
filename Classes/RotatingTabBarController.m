//
//  RotatingTabBarController.m
//  Area520.com
//
//  Created by Eisen Montalvo on 9/20/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "RotatingTabBarController.h"


@implementation RotatingTabBarController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
	BOOL result = [self.selectedViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];

	return result;
}

-(void)beginCustomizingTabBar:(id)sender
{
	[super beginCustomizingTabBar:sender];
	
	// Get the new view inserted by the method called above
	id modalViewCtrl = [[[self view] subviews] objectAtIndex:1];
	
	if([modalViewCtrl isKindOfClass:NSClassFromString(@"UITabBarCustomizeView")] == YES)
	{
		//UINavigationBar* navBar = (UINavigationBar*) [[modalViewCtrl subviews] objectAtIndex:0];
		
		//[navBar setBarStyle:UIBarStyleBlackTranslucent];
		//[navBar setTranslucent:YES];
	}
}

@end

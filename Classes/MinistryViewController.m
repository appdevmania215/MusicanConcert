//
//  MinistryViewController.m
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "MinistryViewController.h"

@implementation MinistryViewController

@synthesize imageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
	imageIndex = [defaults integerForKey:@"MinistryPhoto"];
	
	++imageIndex;
	
	if(imageIndex > 3)
	{
		imageIndex = 1;
	}
	
	UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"Photo%d.png", imageIndex]];
	
	[imageView setImage:image];
	
	[defaults setInteger:imageIndex forKey:@"MinistryPhoto"];
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

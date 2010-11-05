//
//  BackgroundRotator.m
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "BackgroundRotator.h"

#define BACKGROUND_IMAGE_COUNT 4

@implementation BackgroundRotator

@synthesize front;
@synthesize back;
@synthesize tabBarCtrl;

-(NSString*)nextImageName
{
	int newImage = usedImage;
	
	while (newImage == usedImage)
	{
		newImage = (random() % BACKGROUND_IMAGE_COUNT) + 1;
	}
	
	usedImage = newImage;
	
	return [NSString stringWithFormat:@"background%d", usedImage];
}

-(void)changeImage
{
	UIImage* image = [UIImage imageNamed:[self nextImageName]];
	
	[views[!activeView] setImage:image]; // Set back view
	
	[UIView animateWithDuration:0.5 
					 animations:^{
						 [views[activeView] setAlpha:0.0];
					 }
					 completion:^(BOOL finished){
						 [[self view] exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
						 [views[activeView] setAlpha:1.0];
						 activeView = !activeView;
					 }];
}

-(void)viewDidLoad
{
	views[0] = front;
	views[1] = back;
	
	activeView = 0;
	curIndex = 0;
	
	UIImage* image = [UIImage imageNamed:[self nextImageName]];
	
	[views[activeView] setImage:image];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	int newIndex = [tabBarController selectedIndex];
	
	if(newIndex != curIndex)
	{
		[self changeImage];
		curIndex = newIndex;
	}
	
	NSNumber* selectedTab = [NSNumber numberWithInt:newIndex];
	
	[defaults setObject:selectedTab forKey:@"SelectedTab"];
	
	[defaults synchronize];
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    int count = tabBarController.viewControllers.count;
    NSMutableArray *savedTabsOrderArray = [NSMutableArray arrayWithCapacity:count];
	
    for (int i = 0; i < count; i ++)
	{
		int tabTag = [[[tabBarController.viewControllers objectAtIndex:i] tabBarItem] tag];
        [savedTabsOrderArray addObject:[NSNumber numberWithInt:tabTag]];
    }
	
    [defaults setObject:[NSArray arrayWithArray:savedTabsOrderArray] forKey:@"TabsOrder"];
	[defaults synchronize];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
}

@end

//
//  JaimeJorgeAppDelegate.m
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright Hye Multimedia Ministries LLC 2010. All rights reserved.
//

#import "JaimeJorgeAppDelegate.h"


@implementation JaimeJorgeAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize moreListCtrl;

-(void)restoreOrder
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
	NSArray *initialViewControllers = [NSArray arrayWithArray:self.tabBarController.viewControllers];
    NSArray *tabBarOrder = [defaults arrayForKey:@"TabsOrder"];
    if( tabBarOrder != nil )
	{
        NSMutableArray *newViewControllers = [NSMutableArray arrayWithCapacity:initialViewControllers.count];
        for (NSNumber *tabBarNumber in tabBarOrder)
		{
            NSUInteger tabBarIndex = [tabBarNumber unsignedIntegerValue];
            [newViewControllers addObject:[initialViewControllers objectAtIndex:tabBarIndex]];
        }
        self.tabBarController.viewControllers = newViewControllers;
    }
	
	NSNumber* selectedTab = [defaults objectForKey:@"SelectedTab"];
	
    if (selectedTab != nil)
	{
		int tab = [selectedTab intValue];
		
        if ( tab == NSIntegerMax )
		{
            tabBarController.selectedViewController = tabBarController.moreNavigationController;
        }
        else
		{
            tabBarController.selectedIndex = tab;
        }
    }
}

-(void)configureMoreVC
{
	UINavigationController* moreVC = tabBarController.moreNavigationController;
	UINavigationBar* moreNavBar = moreVC.navigationBar;
	
	[moreNavBar setBarStyle:UIBarStyleBlackTranslucent];
	[moreNavBar setTranslucent:YES];
	
	UITableView* moreTV = (UITableView*)moreVC.topViewController.view;
	
	moreTV.backgroundColor = [UIColor clearColor];
	moreTV.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	if( moreTV.dataSource != self )
	{
		self.moreListCtrl = (UIMoreListController*)moreTV.dataSource;
		
		moreTV.dataSource = self;
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
	UIImage* defaultImage = [UIImage imageNamed:@"Default.png"];
	UIImageView* imageView = [[[UIImageView alloc] initWithImage:defaultImage] autorelease];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
	[self configureMoreVC];
	[self restoreOrder];
	
    [window addSubview:tabBarController.view];
	[window addSubview:imageView];
    [window makeKeyAndVisible];
	
	[UIView animateWithDuration:1.0 
					 animations:^
	                 {
						 [imageView setAlpha:0.0];
					 }
					 completion:^(BOOL finished)
	                 {
						 [imageView removeFromSuperview];
					 }];
	
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [moreListCtrl tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = [moreListCtrl tableView:tableView cellForRowAtIndexPath:indexPath];
	
	UILabel* textLabel = cell.textLabel;
	
	textLabel.textColor = [UIColor whiteColor];
	
	UIImageView* imageView = cell.imageView;
	
	imageView.highlighted = YES;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[moreListCtrl tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
	[self configureMoreVC];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{

}

- (void)dealloc
{
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end


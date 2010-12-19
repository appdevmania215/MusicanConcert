//
//  JaimeJorgeAppDelegate.m
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright Hye Multimedia Ministries LLC 2010. All rights reserved.
//

#import "JaimeJorgeAppDelegate.h"
#import "PhotoViewController.h"
#import "VideoViewController.h"
#import "MusicViewController.h"
#import "FlurryAPI.h"

@implementation JaimeJorgeAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize moreListCtrl;

void uncaughtExceptionHandler(NSException *exception)
{
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}

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
	UITableView* moreTV = (UITableView*)[[[moreVC viewControllers] objectAtIndex:0] view];
	
	[moreNavBar setBarStyle:UIBarStyleBlackTranslucent];
	[moreNavBar setTranslucent:YES];
	
	moreTV.backgroundColor = [UIColor clearColor];
	moreTV.separatorStyle = UITableViewCellSeparatorStyleNone;
	[moreTV setNeedsDisplay];
	
	if( moreTV.dataSource != self )
	{
		self.moreListCtrl = (UIMoreListController*)moreTV.dataSource;
		
		moreTV.dataSource = self;
	}
}

-(void)resetBadgeValues
{
	UITabBarController* tabBarCtrl = [self tabBarController];
	NSArray* tabBarItems = [[tabBarCtrl tabBar] items];
	
	for (UITabBarItem* tabBarItem in tabBarItems)
	{
		[tabBarItem setBadgeValue:nil];
	}
}

-(void)updateBadgeValues
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSArray *viewControllers = [tabBarController viewControllers];
	
	[self resetBadgeValues];
	
	int tabIndex = 0;
	
	for(UINavigationController* navc in viewControllers)
	{
		UIViewController* vc = [navc topViewController];
		if( [vc respondsToSelector:@selector(getPhotoCount:tabIndex:sign:)] == YES )
		{
			[(PhotoViewController*)vc getPhotoCount:@"http://www.jaimejorge.com/app/getphotos.php?mode=0" tabIndex:tabIndex sign:1];
		}
		else if( [vc respondsToSelector:@selector(getVideoCount:tabIndex:sign:)] == YES )
		{
			[(VideoViewController*)vc getVideoCount:@"http://www.jaimejorge.com/app/getvideos.php?mode=0" tabIndex:tabIndex sign:1];
		}
		else if( [vc respondsToSelector:@selector(getAlbumCountWithTabIndex:sign:)] == YES )
		{
			[(MusicViewController*)vc getAlbumCountWithTabIndex:tabIndex sign:1];
		}
		
		++tabIndex;
	}
	
	[pool release];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
	UIImage* defaultImage = [UIImage imageNamed:@"Default.png"];
	UIImageView* imageView = [[[UIImageView alloc] initWithImage:defaultImage] autorelease];
	
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[FlurryAPI startSessionWithLocationServices:@"ZC2TW18UYGB1CNC67F99"];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeValues) name:@"UpdateBadgeValues" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureMoreVC) name:@"ConfigureMoreVC" object:nil];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
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
	
	[FlurryAPI countPageViews:tabBarController];
	
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
	
	[self performSelectorInBackground:@selector(updateBadgeValues) withObject:nil];
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


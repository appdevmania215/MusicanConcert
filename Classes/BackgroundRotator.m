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

-(UIImage*)nextImage
{
	int newImage = usedImage;
	
	while (newImage == usedImage)
	{
		newImage = (random() % BACKGROUND_IMAGE_COUNT) + 1;
	}
	
	usedImage = newImage;
	
	return [UIImage imageNamed:[NSString stringWithFormat:@"background%d", usedImage]];
}

-(void)changeImage:(UIImage*)image delay:(float)delay
{
	[views[!activeView] setImage:image]; // Set back view
	
	[UIView animateWithDuration:delay 
					 animations:^{
						 [views[activeView] setAlpha:0.0];
					 }
					 completion:^(BOOL finished){
						 [[self view] exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
						 [views[activeView] setAlpha:1.0];
						 activeView = !activeView;
					 }];
}

-(void)useMoviePlayerBackground
{
	[self changeImage:[UIImage imageNamed:@"MusicPlayerBackground.png"] delay:0.0];
}

-(void)removeMoviePlayerBackground
{
	[self changeImage:[self nextImage] delay:0.0];
}

-(void)viewDidLoad
{
	NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
	
	[center addObserver:self selector:@selector(useMoviePlayerBackground) name:@"UseMoviePlayerBackground" object:nil];
	[center addObserver:self selector:@selector(removeMoviePlayerBackground) name:@"RemoveMoviePlayerBackground" object:nil];
	
	views[0] = front;
	views[1] = back;
	
	activeView = 0;
	curIndex = 0;
	
	[views[activeView] setImage:[self nextImage]];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	int newIndex = [tabBarController selectedIndex];
	
	if(newIndex != curIndex)
	{
		[self changeImage:[self nextImage] delay:0.5];
		curIndex = newIndex;
	}
	
	NSNumber* selectedTab = [NSNumber numberWithInt:newIndex];
	
	[defaults setObject:selectedTab forKey:@"SelectedTab"];
	
	[defaults synchronize];
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateBadgeValues" object:nil];
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

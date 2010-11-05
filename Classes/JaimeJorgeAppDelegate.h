//
//  JaimeJorgeAppDelegate.h
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright Hye Multimedia Ministries LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIMoreListController;

@interface JaimeJorgeAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UITableViewDataSource>
{
    UIWindow* window;
    UITabBarController* tabBarController;
	UIMoreListController* moreListCtrl;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) UIMoreListController* moreListCtrl;

@end

//
//  BackgroundRotator.h
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackgroundRotator : UIViewController <UITabBarControllerDelegate>
{
	UIImageView* front;
	UIImageView* back;
	
	UIImageView* views[2];
	
	UITabBarController* tabBarCtrl;
	
	int activeView;
	int usedImage;
	int curIndex;
}

@property (retain, nonatomic) IBOutlet UIImageView* front;
@property (retain, nonatomic) IBOutlet UIImageView* back;
@property (retain, nonatomic) IBOutlet UITabBarController* tabBarCtrl;

@end

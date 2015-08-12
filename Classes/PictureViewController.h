//
//  PictureViewController.h
//  Area520.com
//
//  Created by Eisen Montalvo on 9/17/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PictureViewController : UIViewController <UIScrollViewDelegate>
{
	NSArray* thumbs;
	
	UIScrollView* mainScrollView;
	
	UIScrollView* prevPage;
	UIScrollView* curPage;
	UIScrollView* nextPage;
	
	UIImageView* prevImage;
	UIImageView* curImage;
	UIImageView* nextImage;
	
	UIActivityIndicatorView* activity;
	
	int index;
	int curPageNum;
    
    UIImage* CurrentImage;   // JF
}

@property (retain, nonatomic) NSArray* thumbs;
@property (retain, nonatomic) IBOutlet UIScrollView* mainScrollView;
@property (retain, nonatomic) IBOutlet UIScrollView* prevPage;
@property (retain, nonatomic) IBOutlet UIScrollView* curPage;
@property (retain, nonatomic) IBOutlet UIScrollView* nextPage;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView* activity;
@property (assign) int index;
@property (retain, nonatomic)  UIImage* CurrentImage; // JF

@end

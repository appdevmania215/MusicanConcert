//
//  ThumbnailViewCell.h
//  Area520.com
//
//  Created by Eisen Montalvo on 9/12/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThumbnailView;

@interface ThumbnailViewCell : UITableViewCell
{
	ThumbnailView* thumbs[4];
	ThumbnailView* thumb1;
	ThumbnailView* thumb2;
	ThumbnailView* thumb3;
	ThumbnailView* thumb4;
}
+ (NSString*) resueIdentifier;
@property (retain, nonatomic) IBOutlet ThumbnailView* thumb1;
@property (retain, nonatomic) IBOutlet ThumbnailView* thumb2;
@property (retain, nonatomic) IBOutlet ThumbnailView* thumb3;
@property (retain, nonatomic) IBOutlet ThumbnailView* thumb4;

-(ThumbnailView*)thumbView:(int)thumb;

@end

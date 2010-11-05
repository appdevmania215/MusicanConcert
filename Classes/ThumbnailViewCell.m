//
//  ThumbnailViewCell.m
//  Area520.com
//
//  Created by Eisen Montalvo on 9/12/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "ThumbnailViewCell.h"
#import "ThumbnailView.h"

@implementation ThumbnailViewCell

@synthesize thumb1;
@synthesize thumb2;
@synthesize thumb3;
@synthesize thumb4;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
	{
        
    }
    return self;
}

-(void)awakeFromNib
{
	thumbs[0] = thumb1;
	thumbs[1] = thumb2;
	thumbs[2] = thumb3;
	thumbs[3] = thumb4;
}

-(ThumbnailView*)thumbView:(int)thumb
{
	return thumbs[thumb];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
}


- (void)dealloc
{
    [super dealloc];
}

@end

//
//  JJMoviePlayerController.m
//  JaimeJorge
//
//  Created by Eisen Montalvo on 11/7/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "JJMoviePlayerController.h"


@implementation JJMoviePlayerController

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)dealloc
{
    [super dealloc];
}

@end

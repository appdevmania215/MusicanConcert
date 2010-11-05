//
//  HTMLParserDelegate.h
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HTMLParserDelegate : NSObject <NSXMLParserDelegate>
{
	NSMutableDictionary* concert;
	
	BOOL newObject;
	BOOL newKey;
	BOOL link;
	
	NSString* key;
	NSString* value;
}

@property (retain, nonatomic) NSMutableDictionary* concert;
@property (retain, nonatomic) NSString* key;
@property (retain, nonatomic) NSString* value;

@end

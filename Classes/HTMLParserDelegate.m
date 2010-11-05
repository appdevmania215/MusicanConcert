//
//  HTMLParserDelegate.m
//  JaimeJorge
//
//  Created by Eisen Montalvo on 8/15/10.
//  Copyright 2010 Hye Multimedia Ministries LLC. All rights reserved.
//

#import "HTMLParserDelegate.h"


@implementation HTMLParserDelegate

@synthesize concert;
@synthesize key;
@synthesize value;

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	self.value = @"";
	newObject = NO;
	newKey = NO;
	link = NO;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"li"] == YES)
	{
		newObject = YES;
		self.key = nil;
	}
	else if([elementName isEqualToString:@"strong"] == YES)
	{
		newKey = YES;
	}
	else if([elementName isEqualToString:@"a"] == YES)
	{
		link = YES;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if(newObject == YES && newKey == YES && link == NO)
	{
		self.key = [string substringToIndex:[string length] - 1];
	}
	else if(newObject == YES && newKey == NO)
	{
		self.value = [NSString stringWithFormat:@"%@%@", self.value, [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if([elementName isEqualToString:@"li"] == YES)
	{
		newObject = NO;
		
		if(self.key != nil)
		{
			[concert setObject:self.value forKey:self.key];
		}
		
		self.value = @"";
	}
	else if([elementName isEqualToString:@"strong"] == YES)
	{
		newKey = NO;
	}
	else if([elementName isEqualToString:@"a"] == YES)
	{
		link = NO;
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	
}

@end

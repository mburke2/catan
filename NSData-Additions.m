//
//  NSData-Additions.m
//  catan
//
//  Created by James Burke on 1/28/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSData-Additions.h"


@implementation NSData (Additions)

-(NSString*) stringValue	{
	int i;
	NSMutableString* str = [NSMutableString string];
	unsigned char bytes[100];
	[self getBytes:bytes];
	for (i = 0; i < [self length] && i < 100; i++)	{
		[str appendFormat:@"%d ", bytes[i]];
	}
	return str;
}

//-(NSString*) stringWithRange:

@end

//
//  NSSocketPort-Additions.m
//  catan
//
//  Created by James Burke on 1/28/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSSocketPort-Additions.h"


@implementation NSSocketPort (Additions)

-(int) portNumber	{
	NSData* data = [self address];
	unsigned char bytes[25] = {0};
	[data getBytes:bytes];

	return  256 * bytes[2] + bytes[3];

}
-(NSString*) ipAddress	{
	NSData* data = [self address];
	unsigned char bytes[25] = {0};
	[data getBytes:bytes];
	
	return [NSString stringWithFormat:@"%d.%d.%d.%d", bytes[4], bytes[5], bytes[6], bytes[7]];
}

@end

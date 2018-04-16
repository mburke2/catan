//
//  CityToken.m
//  catan
//
//  Created by James Burke on 1/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CityToken.h"


@implementation CityToken

/*
-(NSImage*) image	{
	NSImage* image = [[[NSImage alloc] initWithSize:NSMakeSize(18, 18)] autorelease];
	NSBezierPath* path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(0, 0)];
	[path lineToPoint:NSMakePoint(3, 18)];
	[path lineToPoint:NSMakePoint(6, 0)];
	[path lineToPoint:NSMakePoint(9, 18)];
	[path lineToPoint:NSMakePoint(12, 0)];
	[path lineToPoint:NSMakePoint(15, 18)];
	[path lineToPoint:NSMakePoint(18, 0)];
	[path lineToPoint:NSMakePoint(0, 0)];
	
	[image lockFocus];
	[[myOwner color] set];
	[path fill];
	[image unlockFocus];

	return image;
}*/

-(NSSize) size	{
	return NSMakeSize(35, 33);
}

-(int) perspectives		{
	return 4;
}

-(NSString*) imagePrefix	{
	return @"city";
}
@end

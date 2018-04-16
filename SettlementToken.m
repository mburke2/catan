//
//  SettlementToken.m
//  catan
//
//  Created by James Burke on 1/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SettlementToken.h"


@implementation SettlementToken
/*
-(id) initWithOwner:(id)owner	{
	self = [super initWithOwner:owner];
	if (self)	{
		[self makeImage];
	}
	return self;
}	*/
/*
-(void) makeImage	{
	myImage = [self newImage];
	[myImage retain];
}
-(NSImage*) oldImage	{

	NSImage* image = [[[NSImage alloc] initWithSize:NSMakeSize(18, 18)] autorelease];
	NSBezierPath* path = [NSBezierPath bezierPath];
	
	[path moveToPoint:NSMakePoint(0, 0)];
	[path lineToPoint:NSMakePoint(9, 18)];
	[path lineToPoint:NSMakePoint(18, 0)];
	[path lineToPoint:NSMakePoint(0, 0)];
	
	[image lockFocus];
	[[myOwner color] set];
	[path fill];
	[image unlockFocus];
	
	return image;
}	


-(NSImage*) image	{
	return myImage;
}	
*/
-(NSString*) imagePrefix	{
	return @"settlement";
}

-(int) perspectives	{
	return 2;
}

-(NSSize) size	{
	return NSMakeSize(25, 31);
}

@end

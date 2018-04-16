//
//  TradeRoute.m
//  catan
//
//  Created by James Burke on 1/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TradeRoute.h"
#import "Vertex.h"

@implementation TradeRoute

-(id) init	{
	self = [super init];
	if (self)	{
		resource = nil;
		vertices = [NSArray array];
		[vertices retain];
		myImage = nil;
		[self buildImage];
	}
	return self;
}

-(void) buildImage	{
	NSColor* theColor = [NSColor colorWithCalibratedRed:0.4 green:0.5 blue:0.55 alpha:1.0];
	NSImage* baseImage;
	NSAttributedString* ratioString;
	if (resource)	{
		ratioString = [[[NSAttributedString alloc] initWithString:@"2:1" attributes:nil] autorelease];
		baseImage = [NSImage imageNamed:[NSString stringWithFormat:@"%@TR.png", resource]];
	}
	else	{
		ratioString = [[[NSAttributedString alloc] initWithString:@"3:1" attributes:nil] autorelease];
		baseImage = [[[NSImage alloc] initWithSize:NSMakeSize(100, 100)] autorelease];
		[baseImage lockFocus];
		[[NSColor whiteColor] set];
		[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, 0, 100, 100)] fill];
		NSAttributedString* str = [[[NSAttributedString alloc] initWithString:@"?" attributes:
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSFont fontWithName:@"Arial" size:56], NSFontAttributeName,
				theColor, NSForegroundColorAttributeName,
				[NSNumber numberWithFloat:0.05], NSObliquenessAttributeName,
				nil]] autorelease];
		[str drawAtPoint:NSMakePoint( (100 - [str size].width) / 2, (100 - [str size].height ) / 2)];
		[baseImage unlockFocus];
	}
	NSBezierPath* circlePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, 0, [baseImage size].width, [baseImage size].height)];

	[myImage release];
	myImage = [[NSImage alloc] initWithSize:[baseImage size]];
	
	[myImage lockFocus];
	[[[NSColor whiteColor] colorWithAlphaComponent:0.4] set];
	[circlePath fill]; 
	[baseImage drawInRect:NSMakeRect(0, 0, [myImage size].width, [myImage size].height) fromRect:NSMakeRect(0, 0, [myImage size].width, [myImage size].height) operation:NSCompositeSourceOver fraction:0.8];
//	[ratioString drawAtPoint:NSMakePoint(([myImage size].width - [ratioString size].width) / 2, (([myImage size].height - [ratioString size].height) / 2))];
	[theColor set];
//	[[NSColor redColor] set];
//0.384314 0.482353 0.54902 0
	[circlePath setLineWidth:4];
	[circlePath stroke];
	[[NSColor blackColor] set];
	[circlePath setLineWidth:0.5];
	[circlePath stroke];
	[myImage unlockFocus];
	
	
}
-(void) addVertex:(Vertex*)vertex	{
	NSMutableArray* arr = [NSMutableArray arrayWithArray:vertices];
	[arr addObject:vertex];
	[vertices release];
	vertices = [NSArray arrayWithArray:arr];
	[vertices retain];
}

+(TradeRoute*) tradeRouteWithResource:(NSString*)r  {
	TradeRoute* t = [[TradeRoute alloc] init];
	[t autorelease];
	
	[t setResource:r];
//	[t setLocation:p];
	
	return t;
}

-(void) setLocation:(NSPoint)p	{
	location = p;
}


-(void) setOffset:(NSPoint)p	{
	offset = p;
}

-(NSPoint) offset	{
	return offset;
}	
-(NSPoint) location	{
	return location;
}
-(void) setResource:(NSString*)str	{
	if (str != nil)	{
		[resource release];
		resource = [[str copy] retain];
	}
	
	[self buildImage];
}
-(NSString*) resource	{
	return resource;
}

-(NSArray*) vertices	{
	return vertices;
}


-(NSImage*) image	{
	return myImage;
}
@end

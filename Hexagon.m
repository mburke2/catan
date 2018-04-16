//
//  Hexagon.m
//  catan
//
//  Created by James Burke on 12/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Hexagon.h"
//#import "Vertex.h"
//#import "Edge.h"


@implementation Hexagon

-(id) initWithVertices:(NSPoint[6])pts center:(NSPoint)p	{
	self = [super init];
	if (self)	{
		int i;
		for (i = 0; i < 6; i++)	{
			myVertices[i] = pts[i];
		}
		myCenter = p;
//		myNeighbors = nil;
	}
	return self;
}

-(void) dealloc	{
//	[myNeighbors release];
	[super dealloc];
}

+(void) getVertices:(NSPoint[6])pts forCenter:(NSPoint)p size:(NSSize)sz	{
	pts[0] = NSMakePoint(p.x - sz.width / 2, p.y);
	pts[1] = NSMakePoint(p.x - sz.width / 4, p.y + sz.height / 2);
	pts[2] = NSMakePoint(p.x + sz.width / 4, p.y + sz.height / 2);
	pts[3] = NSMakePoint(p.x + sz.width / 2, p.y);
	pts[4] = NSMakePoint(p.x + sz.width / 4, p.y - sz.height / 2);
	pts[5] = NSMakePoint(p.x - sz.width / 4, p.y - sz.height / 2);
}

+(Hexagon*) hexagonWithCenter:(NSPoint)p size:(NSSize)sz	{
	NSPoint vertices[6] = {NSMakePoint(p.x - sz.width / 2, p.y) ,
						NSMakePoint(p.x - sz.width / 4, p.y + sz.height / 2),
						NSMakePoint(p.x + sz.width / 4, p.y + sz.height / 2),
						NSMakePoint(p.x + sz.width / 2, p.y),
						NSMakePoint(p.x + sz.width / 4, p.y - sz.height / 2),
						NSMakePoint(p.x - sz.width / 4, p.y - sz.height / 2)};
//						NSMakePoint(p.x - sz.width / 2, p.y)};

	return [Hexagon hexagonWithVertices:vertices center:p];
}
+(Hexagon*) hexagonWithVertices:(NSPoint[6])pts	center:(NSPoint)p{
	Hexagon* h = [[Hexagon alloc] initWithVertices:pts center:p];
	[h autorelease];
	
	return h;
}


-(void) copyVertices:(NSPoint[6])pts	{
	int i;
	for (i = 0; i < 6; i++)	{
		pts[i] = myVertices[i];
	}
//	return myVertices;
}	
/*
-(void) setNeighbors:(NSArray*)arr	{
	[myNeighbors release];
	myNeighbors = [arr retain];
}
*/
/*
-(NSBezierPath*) bezierPath	{
	NSBezierPath* path = [[NSBezierPath alloc] init];
	[path autorelease];
	
	[path moveToPoint:myVertices[0]];
	
	int i;
	for (i = 1; i < 6; i++)	{
		[path lineToPoint:myVertices[i]];
	}
	
	return path;
}*/

-(NSPoint) center	{
	return myCenter;
}


-(NSString*) description	{
	return [NSString stringWithFormat:@"Hexagon: center%@", NSStringFromPoint(myCenter)];
}

-(NSComparisonResult) compareByCenter:(Hexagon*)h	{
	NSPoint hCenter = [h center];
	if (myCenter.y - 1 > hCenter.y)
		return NSOrderedAscending;
	if (myCenter.y + 1 < hCenter.y)
		return NSOrderedDescending;
	if (myCenter.x + 1 < hCenter.x)
		return NSOrderedAscending;
	if (myCenter.x - 1 > hCenter.x)
		return NSOrderedDescending;

	NSLog(@"THIS SHOULD NOT HAVE HAPPENED, %s, %@, %@", __FUNCTION__, self, h);
	return NSOrderedSame;
}



@end

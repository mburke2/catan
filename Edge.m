//
//  Edge.m
//  catan
//
//  Created by James Burke on 12/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Edge.h"
#import "Vertex.h"
#import "BoardHexagon.h"
#define PP NSLog(@"%s", __FUNCTION__)

@implementation Edge

-(id) initWithVertex:(Vertex*)v1 andVertex:(Vertex*)v2	{
	self = [super init];
	if (self)	{
		myVertices = [NSArray arrayWithObjects:v1, v2, nil];
		[myVertices retain];
		myHexagons = [NSArray array];
		[myHexagons retain];
		//myItem = nil;
	}
	return self;
}

-(NSRect) bounds	{
	NSPoint p1 = [(Vertex*)[myVertices objectAtIndex:0] location];
	NSPoint p2 = [(Vertex*)[myVertices objectAtIndex:1] location];
	
	NSPoint origin;
	NSSize sz;
	
	if (p1.x < p2.x)	{
		origin.x = p1.x;
		sz.width = p2.x - p1.x;
	}
	else	{
		origin.x = p2.x;
		sz.width = p1.x -p2.x;
	}
	
	if (p1.y < p2.y)	{
		origin.y  = p1.y;
		sz.height = p2.y - p1.y;
	}
	else	{
		origin.y = p2.y;
		sz.height = p1.y - p2.y;
	}
	
	return NSMakeRect(origin.x, origin.y, sz.width, sz.height);

}

-(void) addHexagon:(BoardHexagon*)hex	{
	NSMutableArray* tmp = [NSMutableArray arrayWithArray:myHexagons];
	[tmp addObject:hex];
	
	[myHexagons release];
	myHexagons = [NSArray arrayWithArray:tmp];
	[myHexagons retain];
}

-(void) dealloc	{
	NSLog(@"DEALLOCING VERTEX (edge)");
	
	[super dealloc];
}
-(NSArray*) vertices	{
	return myVertices;
}
-(NSArray*) hexagons	{
	return myHexagons;
}
/*
-(void) setItem:(NSString*)str	{
	[myItem release];
	myItem = [str retain];
}
-(NSString*) item	{
	return myItem;
}
*/


-(void) setItem:(BoardToken*)token	{
//	NSLog(@"setting road");
	[super setItem:token];
//	NSLog(@"set generic");
	[self orientToken];
}

-(void) orientToken		{
	
	RoadToken* road = (RoadToken*)[self item];//token;
//-(void) setSize:(NSSize)size orientation:(int)orientation;
	NSRect rect = [self imageRect];
	int orientation;
	NSPoint points[2];// = {[[myVertices objectAtIndex:0] location], [[myVertices objectAtIndex:1] location]};
	points[0].x = [(Vertex*)[myVertices objectAtIndex:0] location].x;
	points[0].y = [(Vertex*)[myVertices objectAtIndex:0] location].y;
	
	points[1].x = [(Vertex*)[myVertices objectAtIndex:1] location].x;
	points[1].y = [(Vertex*)[myVertices objectAtIndex:1] location].y;
	
//	NSPoint hold;
	if (points[0].x > points[1].x)	{
		NSPoint hold = points[0];
		points[0] = points[1];
		points[1] = hold;
	}
	
	if (points[0].y < points[1].y - 1)
		orientation = 0;
	else if (points[1].y < points[0].y - 1)
		orientation = 1;
	else
		orientation = 2;
	
//	NSLog(@"tweaking token");
	[road setSize:rect.size orientation:orientation];
//	NSLog(@"set");
//	[road setPoint1:[(Vertex*)[myVertices objectAtIndex:0] location] point2:[(Vertex*)[myVertices objectAtIndex:1] location]];
}
-(NSRect) imageRect	{
	NSPoint p1 = [(Vertex*)[myVertices objectAtIndex:0] location];
	NSPoint p2 = [(Vertex*)[myVertices objectAtIndex:1] location];
	
	NSPoint origin;
	NSSize size;
	
	if (p1.x < p2.x)	{
		origin.x = p1.x;
		size.width = p2.x - p1.x;
	}
	else	{
		origin.x = p2.x;
		size.width = p1.x - p2.x;
	}
	
	if (p1.y < p2.y)	{	
		origin.y = p1.y;
		size.height = p2.y - p1.y;
	}
	else	{
		origin.y = p2.y;
		size.height = p1.y - p2.y;
	}
	
	
	
	NSSize minSize  = NSMakeSize(7.0, 7.0);
	if (size.width < minSize.width)	{
		origin.x -= ((minSize.width - size.width) / 2.0);
		size.width = minSize.width;
	}
	if (size.height < minSize.height)	{
		origin.y -= ((minSize.height - size.height) / 2.0);
		size.height = minSize.height;
	}
	return NSMakeRect(origin.x, origin.y, size.width, size.height);

//	return NSMakeRect(0, 0, 0, 0);
}


-(NSArray*) neighboringEdges	{
	int i, j;
	NSMutableArray* arr = [NSMutableArray array];
	NSMutableArray* edges;
	for (i = 0; i < [myVertices count]; i++)	{
		edges = [[myVertices objectAtIndex:i] edges];
		for (j = 0; j < [edges count]; j++)	{
			if ([edges objectAtIndex:j] != self && [arr indexOfObject:[edges objectAtIndex:j]] == NSNotFound)
				[arr addObject:[edges objectAtIndex:j]];
		}
	}
	
	return arr;
}

-(NSArray*) edgesForVertex:(int)n	{
	if (n > 1 || n < 0)	{
		PP;
		NSLog(@"*** OOPS n = %d", n);
		return nil;
	}
	NSMutableArray* tmp = [NSMutableArray array];
	NSArray* edges = [[myVertices objectAtIndex:n] edges];
	int i;
	for (i = 0; i < [edges count]; i++)	{
		if (self != [edges objectAtIndex:i])
			[tmp addObject:[edges objectAtIndex:i]];
	}
	return tmp;
}


@end

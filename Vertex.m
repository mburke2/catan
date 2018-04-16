//
//  Vertex.m
//  catan
//
//  Created by James Burke on 12/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Vertex.h"
#import "BoardHexagon.h"
#import "Edge.h"
//#import "PurchaseTableView.h"


@implementation Vertex

-(id) init	{
	self = [super init];
	if (self)	{
		myEdges = [[NSArray alloc] init];
//		myHexagons = [[NSArray alloc] init];
        myHexagons = [[NSMutableArray alloc] init];
	//	myItem = nil;
		myTradeRoute = nil;
	}
	return self;
}

-(void) dealloc	{
//	NSLog(@"DEALLOCING VERTEX");
	
	[super dealloc];
}
/*
-(void) setItem:(NSString*)item	{
	[myItem release];
	myItem = [item copy];
	[myItem retain];
}

-(NSString*) item	{
	return myItem;
}
*/

-(Edge*) addNeighbor:(Vertex*)v	{
	if ([self isNeighbor:v])
		return nil;
	Edge* newEdge = [[[Edge alloc] initWithVertex:self andVertex:v] autorelease];
	[self addEdge:newEdge];
	[v addEdge:newEdge];
	
	return newEdge;
}

-(void) addEdge:(Edge*)edge	{
	NSMutableArray* tmp = [NSMutableArray arrayWithArray:myEdges];
	[tmp addObject:edge];
	[myEdges release];
	myEdges = [NSArray arrayWithArray:tmp];
	[myEdges retain];
//	[myEdges addObject:edge];
}

-(NSArray*) edges	{
	return myEdges;
}

-(NSArray*) neighbors	{
	int i;
	NSMutableArray* returnArray = [NSMutableArray array];
	NSArray* arr;
	for (i = 0; i < [myEdges count]; i++)	{
		arr = [(Edge*)[myEdges objectAtIndex:i] vertices];
		if (self == [arr objectAtIndex:0])
			[returnArray addObject:[arr objectAtIndex:1]];
		else
			[returnArray addObject:[arr objectAtIndex:0]];
	}
	return returnArray;
}

-(NSArray*) hexagons	{
	return myHexagons;
}

-(void) addHexagon:(BoardHexagon*)h	{
	NSInteger index = [myHexagons indexOfObject:h];
	if (index != NSNotFound)
		return;
    /* !!!!! changed int index = ... to NSInteger index =  ... " so that the comparison above actually works*/

    
	NSMutableArray* tmp = [NSMutableArray arrayWithArray:myHexagons];
	[tmp addObject:h];
	[myHexagons release];
	myHexagons = [NSArray arrayWithArray:tmp];
	[myHexagons retain];
}


+(Vertex*) vertexWithLocation:(NSPoint)p	{
	Vertex* v = [[Vertex alloc] init];
	[v setLocation:p];
	[v autorelease];
	
	
	return v;
}


-(BOOL) isNeighbor:(Vertex*)v	{
	int i;
	NSArray* endPoints;
	for (i = 0; i < [myEdges count]; i++)	{
		endPoints = [[myEdges objectAtIndex:i] vertices];
		if ((self == [endPoints objectAtIndex:0] && v == [endPoints objectAtIndex:1]) ||
			(self == [endPoints objectAtIndex:1] && v == [endPoints objectAtIndex:0]))
			return YES;
	}
	return NO;
}	

-(void) setLocation:(NSPoint)p	{
	myLocation = p;
}

-(NSPoint) location	{
//	NSLog(@"querying location");
//	NSLog(@"going to return %@", NSStringFromPoint(myLocation));
	return myLocation;
}

-(NSString*) description	{
	return [NSString stringWithFormat:@"VERTEX: %@", NSStringFromPoint(myLocation)];
}

-(NSComparisonResult) compare:(Vertex*)v	{
	NSPoint vl = [v location];
	if (myLocation.y - 1> vl.y)
		return NSOrderedAscending;
	if (myLocation.y + 1 < [v location].y)
		return NSOrderedDescending;
		
	if (myLocation.x - 1< [v location].x)
		return NSOrderedAscending;
	
	if (myLocation.x + 1> [v location].x)
		return NSOrderedDescending;
		
	NSLog(@"THIS SHOULD NOT HAVE HAPPENED, %s, %@, %@", __FUNCTION__, self, v);
	return NSOrderedSame;
}


-(Edge*) edgeForNeighbor:(Vertex*)v	{
	int i;
	NSArray* verts;
	for (i = 0; i < [myEdges count]; i++)	{
		verts = [[myEdges objectAtIndex:i] vertices];
		if (v == [verts objectAtIndex:0] || v == [verts objectAtIndex:1])
			return [myEdges objectAtIndex:i];
	}
	
	NSLog(@"SHOULDN'T HAVE GOTTEN TO HERE, %s", __FUNCTION__);
	return nil;
}


-(void) setTradeRoute:(TradeRoute*)t	{
	myTradeRoute = [t retain];
}
-(TradeRoute*)tradeRoute	{
	return myTradeRoute;
}


-(NSRect) imageRect	{
	NSSize sz;
	if ([self item])
		sz = [[self item] size];
	else
		sz = NSMakeSize(0, 0);
	
	
//	NSSize sz = 
	return NSMakeRect(myLocation.x - (sz.width / 2), myLocation.y - (sz.height / 2), sz.width, sz.height);
}

@end

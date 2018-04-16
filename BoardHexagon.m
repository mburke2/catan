//
//  BoardHexagon.m
//  catan
//
//  Created by James Burke on 12/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BoardHexagon.h"
#import "Edge.h"
#import "Vertex.h"
#import "NSImage-Additions.h"

static BOOL SHOULD_ROTATE_TILES = NO;
@implementation BoardHexagon

-(id) init	{
	self = [super init];
	if (self)	{
		myEdges = [NSArray array];
		myVertices = [NSArray array];
		resource = nil;
		diceValue = 0;
		[myEdges retain];
		[myVertices retain];
		robber = NO;
		myImage = nil;
	//	[self buildImage];
	}
	return self;
}

-(void) dealloc	{
	[myImage release];
	[super dealloc];
}

+(void) setShouldRoateTiles:(BOOL)flag	{
	SHOULD_ROTATE_TILES = flag;
}

-(float) probability	{
	int diff = 7 - diceValue;
	if (diff < 0)
		diff = -1 * diff;
		
	return (6 - diff) / 36.0;
}

-(void) setRobber:(BOOL)flag	{
	robber = flag;
}
-(void) addVertex:(Vertex*)v	{
	NSMutableArray* mutVerts = [NSMutableArray arrayWithArray:myVertices];
	[mutVerts addObject:v];
//	[v setTag:2 * [mutVerts count]];
	
	[myVertices release];
	myVertices = [NSArray arrayWithArray:mutVerts];
	[myVertices retain];
//	[myVertices retain];
}
-(void) addEdge:(Edge*)e	{
	NSMutableArray* mutEdges = [NSMutableArray arrayWithArray:myEdges];
	[mutEdges addObject:e];
//	[e setTag:2 * [mutEdges count] - 1];
	
	[myEdges release];
	myEdges = [NSArray arrayWithArray:mutEdges];
	[myEdges retain];
}
/*
-(void) setCenter:(NSPoint)p	{
	myCenter = p;
}*/


-(void) setDiceValue:(int)d	{
	diceValue = d;
}
-(int) diceValue	{
	return diceValue;
}
-(void) setResource:(NSString*)str	{
//	NSLog(@"setting resource %@", str);
	if (str && str != [NSNull null])	{
		[resource release];
		resource = [str copy];
		[resource retain];
	}
//	NSLog(@"building image");
	[self buildImage];
//	NSLog(@"built");
}

-(void) setLetter:(char)c	{
	//NSLog(@"setting letter, %c", c);
	letter = c;
}	
-(char) letter	{
	return letter;
}
-(NSString*) resource	{
	return resource;
}


-(NSArray*) vertices	{
	return myVertices;
}


-(BOOL) robber	{
	return robber;
}


#pragma mark VIEW METHODS

-(NSBezierPath*) bezierPath	{
//	NSLog(@"vert count = %d", [myVertices count]);
	NSBezierPath* path = [NSBezierPath bezierPath];
	[path moveToPoint:[(Vertex*)[myVertices objectAtIndex:0] location]];
	
	int i;
//	NSLog(@"%@", [myVertices objectAtIndex:0]);
	for (i = 1; i < [myVertices count]; i++)	{
//		NSLog(@"%@", [myVertices objectAtIndex:i]);
		[path lineToPoint:[(Vertex*)[myVertices objectAtIndex:i] location]];
	}
	[path lineToPoint:[(Vertex*)[myVertices objectAtIndex:0] location]];
	
//	NSLog(@"returning path");
	return path;
}

-(NSPoint) center	{
	float x = 0;
	float y = 0;
	int i;
	for (i = 0; i < [myVertices count]; i++)	{
		x += [(Vertex*)[myVertices objectAtIndex:i] location].x;
		y += [(Vertex*)[myVertices objectAtIndex:i] location].y;
	}
	return NSMakePoint(x / 6, y / 6);
//	return myCenter;
}
-(float) height	{
	return [(Vertex*)[myVertices objectAtIndex:1] location].y - [(Vertex*)[myVertices objectAtIndex:4] location].y;
}
-(float) width	{
	return [(Vertex*)[myVertices objectAtIndex:3] location].x - [(Vertex*)[myVertices objectAtIndex:0] location].x;
}


-(NSRect) bounds	{
	float xOrigin = [(Vertex*)[myVertices objectAtIndex:0] location].x;
	float yOrigin = [(Vertex*)[myVertices objectAtIndex:4] location].y;
	
	float width = [self width];
	float height = [self height];
	
	return NSMakeRect(xOrigin, yOrigin, width, height);
}


-(void) buildImage	{
	NSString* fileName;
	if (resource)
		fileName = [NSString stringWithFormat:@"Half%@.png", resource];
	else
		fileName = @"HalfDesert.png";
	NSImage* baseImage = [NSImage imageNamed:fileName];
//	NSImage* baseImage = [[NSImage imageNamed:fileName] autorelease];


	if (SHOULD_ROTATE_TILES == NO)	{
		myImage = [baseImage retain];
		return;
	}
	[myImage release];
//	NSImage* tmpJunk = [[[NSImage alloc] ini
//	NSImage* tmpJunk = [baseImage imageByRotatingDegrees:60 * (rand() % 6)];
//	[tmpJunk lockFocus];
//	NSPoint p1 = NSMakePoint(0, 0);
//	NSPoint p2 = NSMakePoint(0, [tmpJunk size].height);
//	int i;
//	[[NSColor blackColor] set];
//	for (i = 0; i < 4; i++)	{
//		[NSBezierPath strokeLineFromPoint:p1 toPoint:p2];
//		p1.x += [tmpJunk size].width / 4.0;
//		p2.x += [tmpJunk size].width / 4.0;
//	}
//	[tmpJunk unlockFocus];
//	myImage = tmpJunk;

	myImage = [baseImage imageByRotatingDegrees:60 * (rand() % 6)];
//    myImage = baseImage;
	[myImage retain];
	return;
	/*
//	NSLog(@"GOT BASE IMAGE, IT'S %@", baseImage);
	NSSize baseSize = [baseImage size];
	NSImage* canvas = [[[NSImage alloc] initWithSize:NSMakeSize(baseSize.width * 2, baseSize.height * 2)] autorelease];

	[canvas lockFocus];
	NSAffineTransform* transform = [NSAffineTransform transform];
	[transform translateXBy:baseSize.width / 2 yBy:baseSize.height / 2];
	[transform rotateByDegrees:(60 * (rand() % 6))];
//	[transform rotateByDegrees:180];
	[transform translateXBy:-baseSize.width / 2 yBy:-baseSize.height / 2];
	[transform set];
	[baseImage drawInRect:NSMakeRect(0, 0, baseSize.width, baseSize.height) fromRect:NSMakeRect(0, 0, baseSize.width, baseSize.height) operation:NSCompositeSourceOver fraction:1.0];
	[canvas unlockFocus];
	
	[myImage release];
	myImage = [[NSImage alloc] initWithSize:baseSize];
	
	[myImage lockFocus];
	[canvas drawInRect:NSMakeRect(0, 0, baseSize.width, baseSize.height) fromRect:NSMakeRect(0, 0, baseSize.width, baseSize.height) operation:NSCompositeSourceOver fraction:1.0];
	[myImage unlockFocus];
	
//	[[myImage TIFFRepresentation] writeToFile:@"/BlahImage.tiff" atomically:NO];
//	[canvas release];
	*/
}

-(NSImage*) image	{
	return myImage;
}
@end

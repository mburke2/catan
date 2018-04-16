//
//  RoadToken.m
//  catan
//
//  Created by James Burke on 1/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RoadToken.h"
#import "Edge.h"
#define PP //NSLog(@"%s", __FUNCTION__)

@implementation RoadToken

-(id) initWithOwner:(id)obj	{
	myOrientation = -1;
	myImage = nil;
	self = [super initWithOwner:obj];
	return self;
}	


-(void) buildImage	{
	if (myOrientation < 0)
		return;
	if (myImage)
		return;
//	NSLog(@"building road image");
	NSString* colorName = [[myOwner color] description]; 
	NSString* imageName = [NSString stringWithFormat:@"Road%dColor:%@", myOrientation, colorName];
	myImage = [NSImage imageNamed:imageName];
	if (myImage)	{
		[myImage retain];
		return;
	}
		
	NSImage* base = [NSImage imageNamed:[NSString stringWithFormat:@"road%dNewRoad.png", myOrientation]];
	NSRect baseRect = NSMakeRect(0, 0, [base size].width, [base size].height);
	NSImage* shadow = [NSImage imageNamed:[NSString stringWithFormat:@"road%dNewShado.png", myOrientation]];
	NSImage* colorImage = [[[NSImage alloc] initWithSize:baseRect.size] autorelease];
	[colorImage lockFocus];
	[[myOwner color] set];
	[NSBezierPath fillRect:baseRect];
	[colorImage unlockFocus];
	
	NSImage* colorRoad = [[[NSImage alloc] initWithSize:baseRect.size] autorelease];
	[colorRoad lockFocus];
	[base drawInRect:baseRect fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[colorImage drawInRect:baseRect fromRect:baseRect operation:NSCompositeSourceAtop fraction:0.4];
	[colorRoad unlockFocus];

	NSImage* newImage = [[[NSImage alloc] initWithSize:[base size]] autorelease];
//	newImage = [[[NSImage alloc] 
	[newImage setScalesWhenResized:YES];
	
	[newImage lockFocus];
	[shadow drawInRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height) fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[colorRoad drawInRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height) fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[newImage unlockFocus];

	myImage = [[[NSImage alloc] initWithSize:[base size]] autorelease];
//	newImage = [[[NSImage alloc] 
//	[myImage setScalesWhenResized:YES];
	
	[myImage lockFocus];
	[shadow drawInRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height) fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[colorRoad drawInRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height) fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[myImage unlockFocus];

	[myImage setName:imageName];
	[myImage retain];
}
-(void) oldbuildImage	{
	//NSLog(@"%s", __FUNCTION__);
//	NSLog(@"orientation = %d", myOrientation);
	if (myOrientation < 0)
		return;
	NSSize tmpSize;
//	int perspective;
	if (myOrientation == 2)
		tmpSize = NSMakeSize(20, 5);
	else
		tmpSize = NSMakeSize(11, 20);
		
	NSImage* base = [NSImage imageNamed:[NSString stringWithFormat:@"road%dNewRoad.png", myOrientation]];
	NSRect baseRect = NSMakeRect(0, 0, [base size].width, [base size].height);
//	NSLog(@"baseRect = %@", NSStringFromRect(baseRect));
	NSImage* shadow = [NSImage imageNamed:[NSString stringWithFormat:@"road%dNewShadow.png", myOrientation]];
	
	NSImage* colorImage = [[[NSImage alloc] initWithSize:baseRect.size] autorelease];
	[colorImage lockFocus];
	[[myOwner color] set];
	[NSBezierPath fillRect:baseRect];
	[colorImage unlockFocus];
	
	NSImage* colorRoad = [[[NSImage alloc] initWithSize:baseRect.size] autorelease];
	[colorRoad lockFocus];
	[base drawInRect:baseRect fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[colorImage drawInRect:baseRect fromRect:baseRect operation:NSCompositeSourceAtop fraction:0.4];
	[colorRoad unlockFocus];
	
	
//	NSImage* newImage = [[[NSImage alloc] initWithSize:tmpSize] autorelease];
	NSImage* newImage = [[[NSImage alloc] initWithSize:[base size]] autorelease];
//	newImage = [[[NSImage alloc] 
	[newImage setScalesWhenResized:YES];
	
	[newImage lockFocus];
	[shadow drawInRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height) fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[colorRoad drawInRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height) fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[newImage unlockFocus];
	
//	[newImage setSize:mySize];
	[myImage release];
	myImage = [newImage retain];
//	return newImage;
}

-(NSImage*) oldImage	{
//	PP;
//	return [[NSImage alloc] initWithSize:NSMakeSize(0, 0)];
	NSBezierPath* path = [NSBezierPath bezierPath];
	if (myOrientation == 0)	{
		[path moveToPoint:NSMakePoint(5, 5)];
		[path lineToPoint:NSMakePoint(mySize.width - 5, mySize.height -5)];
	}
	else if (myOrientation == 1)	{
		[path moveToPoint:NSMakePoint(5, mySize.height - 5)];
		[path lineToPoint:NSMakePoint(mySize.width - 5, 0)];
	}
	
	else	{
		[path moveToPoint:NSMakePoint(5, 2.5)];
		[path lineToPoint:NSMakePoint(mySize.width - 5, 2.5)];
	}	
	
	[path setLineWidth:5];
	
	NSImage* image = [[[NSImage alloc] initWithSize:mySize] autorelease];
//	NSLog(@"size = %@", NSStringFromSize(mySize));
	[image lockFocus];
	[[myOwner color] set];
	[path stroke];
	
//	[[NSColor blackColor] set];
//	[NSBezierPath strokeRect:NSMakeRect(0, 0, [image size].width, [image size].height)];
	[image unlockFocus];
	
	return image;
		
}

-(NSImage*) oldimage	{
		
	float height, width;
	float top, bottom;
	width = point2.x - point1.x;
	if (point1.y > point2.y + 1)	{
		top = point1.y;
		bottom = point2.y;
		height = point1.y - point2.y;
	}
	else if (point2.y > point1.y + 1)	{
		top = point2.y;
		bottom = point1.y;
		height = point2.y - point1.y;
	}
	else	{
		top = point1.y;
		bottom = point1.y;
		height = 0;
	}

	if (width < 5)
		width = 5;
	if (height < 5)
		height = 5;
	NSImage* image = [[[NSImage alloc] initWithSize:NSMakeSize(width, height)] autorelease];
	
	NSBezierPath* path = [NSBezierPath bezierPath];
//	[path moveToPoint:NSMakePoint(0, 
	
	return image;
}

-(void) setEdge:(Edge*)e	{
	myEdge = [e retain];
}
-(Edge*) edge	{
	return myEdge;
}	

-(void) setPoint1:(NSPoint)p1 point2:(NSPoint)p2	{
	if (p1.x < p2.x)	{
		point1.x = p1.x;
		point2.x = p2.x;
		point1.y = p1.y;
		point2.y = p2.y;
	}	else	{
		point1.x = p2.x;
		point2.x = p1.x;
		point1.y = p2.y;
		point2.y = p1.y;
	}
	
//	point1 = p1;
//	point2 = p2;
	if (point1.x < point2.x - 1)	{
		point1.x += 5;
		point2.x -= 5;
	}
	else if (point2.x < point1.x - 1)	{
		point1.x += 5;
		point2.x -= 5;
	}
	
	if (point1.y < point2.y - 1)	{
		point1.y += 5;
		point2.y -=5;
	}
	else if (point2.y < point1.y - 1)	{
		point1.y -= 5;
		point2.y += 5;
	}
}


-(void) setSize:(NSSize)size orientation:(int)orientation	{
	[self setSize:size];
	[self setOrientation:orientation];
	[self buildImage];
}
-(void) setSize:(NSSize)size	{
	mySize = size;

	if (mySize.width < 5)
		mySize.width = 5;
	if (mySize.height < 5)
		mySize.height = 5;
}
-(void) setOrientation:(int)orientation	{
	myOrientation = orientation;

}


-(NSArray*) computeLongestRoad	{

	NSArray* tmp;
	NSArray* longest = [NSArray array];
	NSArray* ends = [self endsOfRoad];
//	NSLog(@"got ends");
//	return ends;
	int i;
	for (i = 0; i < [ends count]; i++)	{
//		NSLog(@"starting with end");
		tmp = [[[ends objectAtIndex:i] item] computeLongestRoadExcluding:[NSArray array] startingWith:[NSMutableArray array]];
//		NSLog(@"tmp count = %d", [tmp count]);
		if ([tmp count] > [longest count])
			longest = [NSArray arrayWithArray:tmp];
	}
//	NSLog(@"got longest, %d\n%@", [longest count], longest);
	NSMutableArray* result = [NSMutableArray array];
	for (i = 0; i < [longest count]; i++)	{
		[result addObject:[(RoadToken*)[longest objectAtIndex:i] edge]];
	}
//	NSLog(@"returning result, %d", [result count]);
	return result;
}


-(NSArray*) computeLongestRoadExcluding:(NSArray*)excluding startingWith:(NSMutableArray*)alreadyIn {
//	NSLog(@"excluding %d", [excluding count]);
	NSArray* myNeighbors = [myEdge neighboringEdges];
	NSMutableArray* roadNeighbors = [NSMutableArray array];
	int i;
	for (i = 0; i < [myNeighbors count]; i++)	{
		if ([[myNeighbors objectAtIndex:i] item] && [[[myNeighbors objectAtIndex:i] item] owner] == myOwner)
			[roadNeighbors addObject:[[myNeighbors objectAtIndex:i] item]];
	}
	
//	NSLog(@"have %d neighbors", [roadNeighbors count]);
	NSInteger index;
	for (i = 0; i < [excluding count]; i++)	{
		index =[roadNeighbors indexOfObject:[excluding objectAtIndex:i]];
		if (index != NSNotFound)
			[roadNeighbors removeObjectAtIndex:index];
	}
	
//	NSLog(@"%d after removal", [roadNeighbors count]);
	NSMutableArray* result = [NSMutableArray arrayWithArray:alreadyIn];
	[result addObject:self];
	if ([roadNeighbors count] == 0)	
		return result;
	
	NSArray* longest = [NSArray array];
	NSArray* tmp;
	NSMutableArray* toExclude;
	toExclude = [NSMutableArray arrayWithArray:result];
	[toExclude addObjectsFromArray:roadNeighbors];
//	[toExclude addObject:self];
//
	NSMutableArray* reallyExclude;
	for (i = 0; i < [roadNeighbors count]; i++)	{
		reallyExclude = [NSMutableArray arrayWithArray:toExclude];
		[reallyExclude removeObject:[roadNeighbors objectAtIndex:i]];
		tmp = [[roadNeighbors objectAtIndex:i] computeLongestRoadExcluding:reallyExclude startingWith:result];
		if ([tmp count] > [longest count])
			longest = [NSArray arrayWithArray:tmp];
	}

	return [NSArray arrayWithArray:longest];
//	result = [NSMutableArray arrayWithArray:longest];
	
}
-(NSArray*) endsOfRoad	{
//	NSLog(@"getting ends");
	NSMutableArray* ends = [NSMutableArray array];
	NSMutableArray* visited = [NSMutableArray array];
	NSMutableArray* toVisit = [NSMutableArray array];
	NSMutableArray* toVisitNext = [NSMutableArray array];
	int i, j, k;
	
	int nCount;
	NSArray* neighbors;
	Edge* currentEdge;// = myEdge;
	Edge* otherEdge;
	[toVisit addObject:myEdge];
//	int nCount;
	BOOL isEdgeFlag;
	while ([toVisit count] > 0)	{
		for (i = 0; i < [toVisit count]; i++)	{
			isEdgeFlag = NO;
			currentEdge = [toVisit objectAtIndex:i];
//			neighbors = [currentEdge neighboringEdges];
			nCount = 0;
			for (k = 0; k < 2; k++)	{
				neighbors = [currentEdge edgesForVertex:k];
				nCount = 0;
				for (j = 0; j < [neighbors count]; j++)	{
					otherEdge = [neighbors objectAtIndex:j];
					if ([otherEdge item] && [(BoardToken*)[otherEdge item] owner] == myOwner)	{
						nCount++;
						if ([toVisitNext indexOfObject:otherEdge] == NSNotFound && [visited indexOfObject:otherEdge] == NSNotFound)
							[toVisitNext addObject:[neighbors objectAtIndex:j]];
					}
				}
				if (nCount == 0)
					isEdgeFlag = YES;

			}
			//if (nCount == 1 || nCount == 0)
			if (isEdgeFlag)
				if ([ends indexOfObject:currentEdge] == NSNotFound)
					[ends addObject:currentEdge];
			[visited addObject:currentEdge];
		}
//		NSLog(@"finished first round");
		[toVisit removeAllObjects];
		[toVisit addObjectsFromArray:toVisitNext];
		[toVisitNext removeAllObjects];
	}

//	NSLog(@"returning %d ends", [ends count]);
	return ends;
}


@end

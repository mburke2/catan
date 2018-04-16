//
//  BoardHexagon.h
//  catan
//
//  Created by James Burke on 12/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BoardObject.h"

@class Edge;
@class Vertex;

@interface BoardHexagon : BoardObject {
	NSImage* myImage;
	NSArray* myEdges;
	NSArray* myVertices;
	
//	NSPoint myCenter;
	
	NSString* resource;
	int diceValue;
	
	BOOL robber;
	
	
	char letter;
}

-(void) setLetter:(char)c;
-(char) letter;
//-(void) setCenter:(NSPoint)p;
-(void) addVertex:(Vertex*)v;
-(NSArray*) vertices;
-(void) addEdge:(Edge*)e;
-(void) setDiceValue:(int)d;
-(int) diceValue;
-(void) setResource:(NSString*)str;
-(NSString*) resource;
-(void) setRobber:(BOOL)flag;
-(BOOL) robber;
-(NSImage*) image;
-(float) probability;


#pragma mark VIEW METHODS
-(NSBezierPath*) bezierPath;
-(NSPoint) center;
-(float) height;
-(float) width;
-(NSRect) bounds;

@end

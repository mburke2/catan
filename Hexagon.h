//
//  Hexagon.h
//  catan
//
//  Created by James Burke on 12/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "BoardObject.h"
//@class Vertex;
//@class Edge;

@interface Hexagon : NSObject {
	
//	NSArray* myVerticesNew;
//	NSArray* myEdges;
//	int tag;
	NSPoint myVertices[6];
//	NSArray* myEdges;
//	NSArray* myNeighbors;
	
	NSPoint myCenter;
}

-(id) initWithVertices:(NSPoint[6])pts center:(NSPoint)p;
+(void) getVertices:(NSPoint[6])pts forCenter:(NSPoint)c size:(NSSize)sz;

+(Hexagon*) hexagonWithVertices:(NSPoint[6])pts center:(NSPoint)p;
+(Hexagon*) hexagonWithCenter:(NSPoint)p size:(NSSize)sz;
//-(void) setTag:(int)t;
//-(void) setNeighbors:(NSArray*)arr;

-(void) copyVertices:(NSPoint[6])pts;
-(NSPoint) center;

-(NSComparisonResult) compareByCenter:(Hexagon*)h;

//-(NSBezierPath*) bezierPath;

@end

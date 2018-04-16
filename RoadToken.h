//
//  RoadToken.h
//  catan
//
//  Created by James Burke on 1/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BoardToken.h"

@class Edge;
@interface RoadToken : BoardToken {
	NSPoint point1;
	NSPoint point2;
	
	
	Edge* myEdge;
	NSSize mySize;
	int myOrientation;
}

-(NSArray*) computeLongestRoad;
-(NSArray*) computeLongestRoadExcluding:(NSArray*)arr;
-(NSArray*) endsOfRoad;
-(void) setEdge:(Edge*)e;
-(Edge*) edge;
-(void) setPoint1:(NSPoint)p1 point2:(NSPoint)p2;
-(void) setSize:(NSSize)size orientation:(int)orientation;

@end

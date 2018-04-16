//
//  Edge.h
//  catan
//
//  Created by James Burke on 12/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BoardObject.h"
@class Vertex;
@class BoardHexagon;


@interface Edge : BoardObject {
	NSArray* myVertices;
	NSArray* myHexagons;
	
	
//	NSString* myItem;
//	NSColor* myColor;
}

//-(void) setItem:(NSString*)str;
//-(NSString*) item;
-(id) initWithVertex:(Vertex*)v1 andVertex:(Vertex*)v2;
-(NSArray*) neighboringEdges;
-(NSArray*) vertices;
-(NSRect) imageRect;
-(void) orientToken;
-(NSRect) bounds;

@end

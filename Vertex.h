//
//  Vertex.h
//  catan
//
//  Created by James Burke on 12/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BoardObject.h"
#import "TradeRoute.h"
@class Edge;
@class BoardHexagon;
//@class PurchaseTableView;

@interface Vertex : BoardObject {
	NSArray* myEdges;
	NSArray* myHexagons;
	
	NSPoint myLocation;
	
//	NSString* myItem;
	
	TradeRoute* myTradeRoute;
}

-(void) setTradeRoute:(TradeRoute*)t;
-(TradeRoute*)tradeRoute;
-(NSArray*) edges;
//-(NSString*) item;
-(NSArray*) hexagons;
-(void) addHexagon:(BoardHexagon*)h;
//-(void) setItem:(NSString*)str;
-(void) setTag:(int)t;
-(Edge*) edgeForNeighbor:(Vertex*)v;
-(Edge*) addNeighbor:(Vertex*)v;
+(Vertex*) vertexWithLocation:(NSPoint)p;
-(BOOL) isNeighbor:(Vertex*)v;
-(void) setLocation:(NSPoint)p;
-(NSPoint) location;
-(NSComparisonResult) compare:(Vertex*)v;
-(NSArray*) neighbors;
-(void) addEdge:(Edge*)e;

-(NSRect) imageRect;

@end

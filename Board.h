//
//  Board.h
//  catan
//
//  Created by James Burke on 12/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BoardHexagon.h"
#import "Edge.h"
#import "Vertex.h"
#import "Hexagon.h"
#import "NSMutableArray-Shuffle.h"

@interface Board : NSObject {
	NSArray* myHexagons;
	NSArray* myEdges;
	NSArray* myVertices;
	NSArray* myTradeRoutes;
	NSArray* myWaterHexagons;
	
	
}

-(NSArray*) tiles;
-(NSArray*) tileEdges;
-(NSArray*) tileIntersections;
-(NSArray*) tradeRoutes;
+(NSData*) infoForNewBoardWithDesertInCenter:(BOOL)flag;
+(NSArray*) boardInfoFromArray:(int[])values length:(int)len startingAt:(int)startIndex clockwise:(BOOL)clockwiseFlag;
+(Board*) newBoard;
-(void) moveRobberToTile:(BoardHexagon*)tile;
-(id) initWithHexagons:(NSArray*)hex edges:(NSArray*)edge vertices:(NSArray*)vert;
-(NSData*) boardInfo;
-(BoardHexagon*) tileWithRobber;
-(void) setFrame:(NSRect)frame;


@end

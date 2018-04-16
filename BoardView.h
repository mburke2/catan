/* BoardVIew */

#import <Cocoa/Cocoa.h>
#import "Hexagon.h"
#import "Vertex.h"
#import "Edge.h"
#import "GameController.h"
#import "NSMutableArray-Shuffle.h"
#import "TradeRoute.h"
#import "Board.h"
#import "BoardTokens.h"
#import "FrameView.h"
#import "RealBoardView.h"

@interface BoardView : NSView	{
//	NSArray* myHexagons;
//	NSPoint pointToHighlight;
//	NSPoint lineToHighlight[2];
	
//	NSArray* vertices;

	Board* theBoard;
	
	NSSize vertexHighlightSize;
	float highlightWidth;

//	NSMutableArray* theVertices;
//	NSArray* edges;
//	NSArray* theHexagons;
//	NSArray* tradeRoutes;

	Vertex* vertexToHighlight;
	Edge* edgeToHighlight;
	BoardHexagon* hexToHighlight;

	BOOL robberIsMoving;
	BOOL shouldAdjustImage;

	
	NSRect robberRect;
	NSRect robberAnimationRect;
	NSPoint robberOriginPercentOfFrame;
	
	NSImageView* imageView;
	
	NSArray* waterTiles;
	NSArray* waterImages;
	
	NSColor* bgColor;
	
	NSArray* unshadedTiles;
	
	BOOL drawingLocked;
}
//-(void) drawAPoint:(NSPoint)p;
//-(NSBezierPath*) hexagonWithCenter:(NSPoint)p size:(NSSize)sz;
//-(NSPoint) isValidDropLocation:(NSPoint)p;

-(void) lockDrawing;
-(void) unlockDrawing;
-(void) updateBackground;
-(Vertex*) vertexForLocation:(NSPoint)p;
-(void) buildBoard;
-(void) drawBoard;
-(NSSize) tileSize;
-(NSSize) tradeRouteSize;
-(NSArray*) hexagonsForRect:(NSRect)r;
-(Vertex*) closestVertexToPoint:(NSPoint)p;
@end

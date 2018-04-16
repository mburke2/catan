/* CollectionView */

#import <Cocoa/Cocoa.h>
#import "ResView.h"
#import "SelectionView.h"
//#import "ResViewRep.h"
@interface CollectionView : NSView
{
	BOOL selecting;
	NSPoint cornerOne;
	NSPoint cornerTwo;
	
	SelectionView* selectionView;
	float scaleFactor;
	NSMutableArray* resViews;
	NSMutableArray* reservedViews;
	NSMutableArray* previouslySelected;
	NSPoint downPoint;
	float xMargin;
	float yMargin;
	float verticalOverlap;
	
	float animationLength;
	NSTimer* animationTimer;
	NSDate* animationStartTime;
	
	id dataSource;
	
	BOOL animating;
//	NSRect tmpRectToDraw;

}

-(BOOL) animating;
-(void) addResource:(NSString*)arr inRect:(NSRect)r;
-(void) setDataSource:(id)obj;
//-(NSRect) visibleRectForItem:(ResViewRep*)rep;
-(NSRect) visibleRectForItem:(ResView*)rep;
-(NSRect) frameForNewResourceOfType:(NSString*)str;
-(NSSize) itemSize;
-(NSPoint) locationForItem:(int)i;
-(NSBezierPath*) thinRect:(NSRect)rect;
-(NSRect) selectionRect;
-(void) addResource:(NSString*)str;
-(NSImage*) buildDragImageAndTranslatePoint:(NSPoint*)pointToTranslate forResource:(NSString*)theRes;
-(float) makeRoomForResourceOfType:(NSString*)type;
-(NSArray*) reserveFramesForResources:(NSArray*)res;
-(float) makeRoomForResourcesOfType:(NSArray*)types;

-(NSArray*) animationsToRemoveSelectedResources;
-(NSArray*) animationsToRemoveResources:(NSArray*)arr;
@end

/*
 * Original Windows comment:
 * "This code was created by Jeff Molofee 2000
 * A HUGE thanks to Fredric Echols for cleaning up
 * and optimizing the base code, making it more flexible!
 * If you've found this code useful, please let me know.
 * Visit my site at nehe.gamedev.net"
 * 
 * Cocoa port by Bryan Blackburn 2002; www.withay.com
 */

/* Lesson04View.h */

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>


typedef struct 	{
	float xVal;
	float yVal;
	float zVal;
	float xRot;
	float yRot;
	float zRot;
//	int red;
//	int blue;
//	int green;
	GLuint texture;
	//next;
} ConfettiPiece;

@interface ConfettiView : NSOpenGLView
{
   int colorBits, depthBits;
   BOOL runningFullScreen;
   NSDictionary *originalDisplayMode;
   ConfettiPiece** confettiPieces;
   NSMutableArray* confettiArray;
   ConfettiPiece theConfettiArray[100];
   int numberOfPieces;
   GLuint colorTextures[4];
   GLuint stringTexture;
   
   int frameCount;
   NSDate* startDate;
   float stringStep;
   float stringZ;
   NSSize pieceSize;
   float defaultDepth;
   
   
   NSView* frameReferenceView;
//   NSRect pieceRect;
//   GLfloat rtri;    // Angle for triangle
  // GLfloat rquad;   // Angle for quad
}

-(void) setFrameReferenceView:(NSView*)view;
- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits
       depthBits:(int)numDepthBits fullscreen:(BOOL)runFullScreen;
- (void) reshape;
-(void) resetConfettiPieceAtIndex:(int)i;
- (void) drawRect:(NSRect)rect;
- (BOOL) isFullScreen;
- (BOOL) setFullScreen:(BOOL)enableFS inFrame:(NSRect)frame;
- (void) dealloc;
-(NSRect) rectForPixelRect:(NSRect)pRect depth:(float)zVal;
  -(NSRect) boundsForDepth:(float)zVal;
@end

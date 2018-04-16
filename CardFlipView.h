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

/* Lesson07View.h */

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

@interface CardFlipView : NSOpenGLView
{
   int colorBits, depthBits;
   BOOL runningFullScreen;
   NSDictionary *originalDisplayMode;
//   GLenum texFormat[ 1 ];   // Format of texture (GL_RGB, GL_RGBA)
//   NSSize texSize[ 1 ];     // Width and height
//   char *texBytes[ 1 ];     // Texture data
   BOOL light;         // Lighting on/off
   GLfloat xrot;       // X rotation
   GLfloat yrot;       // Y rotation
   GLfloat xspeed;     // X rotation speed
   GLfloat yspeed;     // Y rotation speed
   GLfloat z;          // Depth into screen
   GLuint filter;                // Which filter to use
//   GLuint texture[ 3 ];          // Storage for three textures
	GLuint frontTexture;
	GLuint backTexture;
	
	NSDictionary* textures;
//	GLuint bgTexture;
	
	GLuint shadowTexture;
	int rotationType;
	NSSize cardSize;
}

- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits
       depthBits:(int)numDepthBits fullscreen:(BOOL)runFullScreen;
- (void) reshape;
-(void) rotate;
- (void) drawRect:(NSRect)rect;
-(void) drawScene;
-(void) setProgress:(float)f;
- (BOOL) isFullScreen;
- (void) toggleLight;
- (void) selectNextFilter;
- (void) decreaseZPos;
- (void) increaseZPos;
- (void) decreaseXSpeed;
- (void) increaseXSpeed;
- (void) decreaseYSpeed;
- (void) increaseYSpeed;
- (BOOL) setFullScreen:(BOOL)enableFS inFrame:(NSRect)frame;
- (void) dealloc;
-(void) setImage:(NSString*)name;
-(void) hide;

-(GLuint) faceForRotation;

-(NSRect) rectForPixelRect:(NSRect)pRect depth:(float)zVal;
-(NSRect) boundsForDepth:(float)zVal;
@end

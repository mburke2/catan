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

/* Lesson04View.m */

#import "ConfettiView.h"
static const int CONFETTI_COUNT = 100;

static GLfloat lightAmbient[] = { 0.5f, 0.5f, 0.5f, 1.0f };
// Diffuse light values
static GLfloat lightDiffuse[] = { 1.0f, 1.0f, 1.0f, 1.0f };
// Light position
static GLfloat lightPosition[] = { 0.0f, 0.0f, 2.0f, 1.0f };


@interface ConfettiView (InternalMethods)
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame;
- (void) switchToOriginalDisplayMode;
- (BOOL) initGL;
@end

@implementation ConfettiView

//- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits
 //      depthBits:(int)numDepthBits fullscreen:(BOOL)runFullScreen

-(id) initWithFrame:(NSRect)frame	{
	int numColorBits = 16;
	int numDepthBits = 16;
	BOOL runFullScreen = NO;
   NSOpenGLPixelFormat *pixelFormat;

   colorBits = numColorBits;
   depthBits = numDepthBits;
   runningFullScreen = runFullScreen;
   originalDisplayMode = (NSDictionary *) CGDisplayCurrentMode(
                                             kCGDirectMainDisplay );
 //  rtri = rquad = 0;
   pixelFormat = [ self createPixelFormat:frame ];
   if( pixelFormat != nil )
   {
      self = [ super initWithFrame:frame pixelFormat:pixelFormat ];
      [ pixelFormat release ];
      if( self )
      {
         [ [ self openGLContext ] makeCurrentContext ];
         if( runningFullScreen )
            [ [ self openGLContext ] setFullScreen ];
         [ self reshape ];
         if( ![ self initGL ] )
         {
            [ self clearGLContext ];
            self = nil;
         }
      }//const int CONFETTI_COUNT = 50;

		numberOfPieces = CONFETTI_COUNT;
		confettiArray = [NSMutableArray array];
		[confettiArray retain];
		startDate = nil;
		frameCount = 0;
		stringStep = 0.01;
		stringZ = -4.0;
		defaultDepth = -6.0;
		int i;
		for (i = 0; i < numberOfPieces; i++)	{
			[self resetConfettiPieceAtIndex:i];
		}
		
		NSTimer* t = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(update:) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:t forMode:NSModalPanelRunLoopMode];
		[[NSRunLoop currentRunLoop] addTimer:t forMode:NSEventTrackingRunLoopMode];
		[[NSRunLoop currentRunLoop] addTimer:t forMode:NSConnectionReplyMode];
		
   }
   else
      self = nil;

   return self;
}

-(void) update:(NSTimer*)t	{
//	NSLog(@"updating");
	[self drawScene];
}


/*
 * Create a pixel format and possible switch to full screen mode
 */
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame
{
   NSOpenGLPixelFormatAttribute pixelAttribs[ 16 ];
   int pixNum = 0;
   NSDictionary *fullScreenMode;
   NSOpenGLPixelFormat *pixelFormat;

   pixelAttribs[ pixNum++ ] = NSOpenGLPFADoubleBuffer;
   pixelAttribs[ pixNum++ ] = NSOpenGLPFAAccelerated;
   pixelAttribs[ pixNum++ ] = NSOpenGLPFAColorSize;
   pixelAttribs[ pixNum++ ] = colorBits;
   pixelAttribs[ pixNum++ ] = NSOpenGLPFADepthSize;
   pixelAttribs[ pixNum++ ] = depthBits;

   if( runningFullScreen )  // Do this before getting the pixel format
   {
      pixelAttribs[ pixNum++ ] = NSOpenGLPFAFullScreen;
      fullScreenMode = (NSDictionary *) CGDisplayBestModeForParameters(
                                           kCGDirectMainDisplay,
                                           colorBits, frame.size.width,
                                           frame.size.height, NULL );
      CGDisplayCapture( kCGDirectMainDisplay );
      CGDisplayHideCursor( kCGDirectMainDisplay );
      CGDisplaySwitchToMode( kCGDirectMainDisplay,
                             (CFDictionaryRef) fullScreenMode );
   }
   pixelAttribs[ pixNum ] = 0;
   pixelFormat = [ [ NSOpenGLPixelFormat alloc ]
                   initWithAttributes:pixelAttribs ];

   return pixelFormat;
}


/*
 * Enable/disable full screen mode
 */
- (BOOL) setFullScreen:(BOOL)enableFS inFrame:(NSRect)frame
{
   BOOL success = FALSE;
   NSOpenGLPixelFormat *pixelFormat;
   NSOpenGLContext *newContext;

   [ [ self openGLContext ] clearDrawable ];
   if( runningFullScreen )
      [ self switchToOriginalDisplayMode ];
   runningFullScreen = enableFS;
   pixelFormat = [ self createPixelFormat:frame ];
   if( pixelFormat != nil )
   {
      newContext = [ [ NSOpenGLContext alloc ] initWithFormat:pixelFormat
                     shareContext:nil ];
      if( newContext != nil )
      {
         [ super setFrame:frame ];
         [ super setOpenGLContext:newContext ];
         [ newContext makeCurrentContext ];
         if( runningFullScreen )
            [ newContext setFullScreen ];
         [ self reshape ];
         if( [ self initGL ] )
            success = TRUE;
      }
      [ pixelFormat release ];
   }
   if( !success && runningFullScreen )
      [ self switchToOriginalDisplayMode ];

   return success;
}


/*
 * Switch to the display mode in which we originally began
 */
- (void) switchToOriginalDisplayMode
{
   CGDisplaySwitchToMode( kCGDirectMainDisplay,
                          (CFDictionaryRef) originalDisplayMode );
   CGDisplayShowCursor( kCGDirectMainDisplay );
   CGDisplayRelease( kCGDirectMainDisplay );
}


/*
 * Initial OpenGL setup
 */
- (BOOL) initGL	{ 
	glEnable( GL_TEXTURE_2D );                // Enable texture mapping
   glShadeModel( GL_SMOOTH );                // Enable smooth shading
   glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );   // Black background
   glClearDepth( 1.0f );                     // Depth buffer setup
   glEnable( GL_DEPTH_TEST );                // Enable depth testing
   glDepthFunc( GL_LEQUAL );                 // Type of depth test to do

	[self loadColorTextures];
	[self loadStringTexture];
   // Really nice perspective calculations
   glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
	glEnable( GL_ALPHA_TEST );

	// Setup ambient light
	glLightfv( GL_LIGHT1, GL_AMBIENT, lightAmbient );
	// Setup diffuse light
	glLightfv( GL_LIGHT1, GL_DIFFUSE, lightDiffuse );
	// Position the light
	glLightfv( GL_LIGHT1, GL_POSITION, lightPosition );
	glEnable( GL_LIGHT1 );   // Enable light 1
	
	glEnable( GL_LIGHTING );

	glEnable (GL_BLEND); 
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	long opaque = 0;
	[[self openGLContext] setValues:&opaque forParameter:NSOpenGLCPSurfaceOpacity];


   return TRUE;
}

-(void) loadStringTexture	{
	NSImage* image = [[[NSImage alloc] initWithSize:NSMakeSize(512, 512)] autorelease];
	NSString* str = @"You Won!";
	NSDictionary* atts = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSColor redColor], NSForegroundColorAttributeName,
		[NSFont fontWithName:@"Helvetica" size:48], NSFontAttributeName, 
		nil];
	
	NSAttributedString* attStr = [[[NSAttributedString alloc] initWithString:str attributes:atts] autorelease];
//	NSLog(@"string size = %@", NSStringFromSize([attStr size]));
	NSShadow* shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowOffset:NSMakeSize(10, -10)];
	[shadow setShadowBlurRadius:3.0];
	[shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.7]];
	[image lockFocus];
	[shadow set];
	[attStr drawAtPoint:NSMakePoint(([image size].width - [attStr size].width) / 2, ([image size].height - [attStr size].height) / 2)];
	[image unlockFocus];
	
//	NSLog(@"stringImage = 
//	[[image TIFFRepresentation] writeToFile:@"/stringImage.tiff" atomically:NO];
	stringTexture = [self textureForImage:image size:[image size]];
}	

-(void) loadColorTextures	{
	NSArray* colors = [NSArray arrayWithObjects:[NSColor blueColor], [NSColor redColor], [NSColor greenColor], [NSColor yellowColor], nil];
	int i;
	NSImage* textureImage;
	NSSize sz = NSMakeSize(64, 64);
	NSRect rect = NSMakeRect(0, 0, sz.width, sz.height);
	for (i = 0; i < [colors count]; i++)	{	
		textureImage = [[[NSImage alloc] initWithSize:sz] autorelease];
		[textureImage lockFocus];
		[[colors objectAtIndex:i] set];
		[NSBezierPath fillRect:rect];
		[textureImage unlockFocus];
//		[[textureImage TIFFRepresentation] writeToFile:[NSString stringWithFormat:@"/color%d.tiff", i] atomically:NO];
		colorTextures[i] = [self textureForImage:textureImage size:[textureImage size]];
	}
}


-(GLuint) textureForImage:(NSImage*)image size:(NSSize)sz	{
//	NSLog(@"getting texture for %@", image);
	NSImage* texImage = [[[NSImage alloc] initWithSize:sz] autorelease];
	[texImage setFlipped:YES];
	[texImage lockFocus];
	[image drawInRect:NSMakeRect(0, 0, [texImage size].width, [texImage size].height) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
	[texImage unlockFocus];
	
	NSBitmapImageRep* texRep = [NSBitmapImageRep imageRepWithData:[texImage TIFFRepresentation]];
//	[[texRep TIFFRepresentation] writeToFile:@"/texRep.tiff" atomically:NO];
	GLuint localTexture;
	glGenTextures(1, &localTexture);
	glBindTexture(GL_TEXTURE_2D, localTexture);

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	GLint internalFormat;
	GLenum format;
	if ([texRep hasAlpha])	{
//		NSLog(@"texRep hasAlpha");
		internalFormat = 4;
		format = GL_RGBA;
	}
	else	{
//		NSLog(@"no alpha");
		internalFormat = 3;
		format = GL_RGB;
	}
		
	
	
	glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, [texRep pixelsWide], [texRep pixelsHigh] , 0, format, GL_UNSIGNED_BYTE, [texRep bitmapData]);

//	NSLog(@"localTexture = %d",localTexture);
	return localTexture;
}


-(void) update	{
//	NSLog(@"updating");
//	[self setNeedsDisplay:YES];
//	if (stringDir
	stringZ += stringStep;
	if (stringZ > -2 || stringZ < -4)
		stringStep = -1 * stringStep;
	[self drawScene];
}
/*
 * Resize ourself
 */

-(BOOL) isOpaque	{
	return NO;
}
- (void) reshape
{
//	NSLog(@"reshaping");
   NSRect sceneBounds;
   
   [ [ self openGLContext ] update ];
   sceneBounds = [ self bounds ];
   // Reset current viewport
   glViewport( 0, 0, sceneBounds.size.width, sceneBounds.size.height );
   glMatrixMode( GL_PROJECTION );   // Select the projection matrix
   glLoadIdentity();                // and reset it
   // Calculate the aspect ratio of the view
   gluPerspective( 45.0f, sceneBounds.size.width / sceneBounds.size.height,
                   0.1f, 100.0f );
   glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix
   glLoadIdentity();                // and reset it
	pieceSize = [self rectForPixelRect:NSMakeRect(0, 0, 18, 29) depth:defaultDepth].size;
}


/*
 * Called when the system thinks we need to draw.
 */
- (void) drawRect:(NSRect)rect
{
}
/*
-(NSView*) hitTest:(NSPoint)p		{
	NSLog(@"hit testing");
	return [super hitTest:p];
}
*/


-(void) setFrameReferenceView:(NSView*)view	{
	frameReferenceView = view;
	[frameReferenceView setPostsFrameChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(referenceFrameChanged:) name:NSViewFrameDidChangeNotification object:frameReferenceView];
}

-(void) referenceFrameChanged:(NSNotification*)note	{
	NSRect superviewFrame = [[self superview] frame];
	NSRect referenceFrame = [frameReferenceView frame];
	referenceFrame.origin = [[[frameReferenceView window] contentView] convertPoint:referenceFrame.origin fromView:frameReferenceView];
	NSRect myFrame = [self frame];
	myFrame.origin.y = referenceFrame.origin.y;
	myFrame.size.height = superviewFrame.size.height - myFrame.origin.y;
	
	[self setFrame:myFrame];
}

-(void) drawScene	{
//	NSLog(@"drawing scene");
	[self lockFocus];
//	frameCount++;
//	if (startDate == nil)
//		startDate = [[NSDate date] retain];
//	if (rand() % 100 == 0)
//		NSLog(@"fps = %f", frameCount / -[startDate timeIntervalSinceNow]);
   glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
//	[[NSColor blueColor] set];
//	[NSBezierPath fillRect:[self bounds]];
	ConfettiPiece* cp;
	int i;
//	float width = 0.15;
//	float height = 0.25;
	float width = pieceSize.width;
	float height = pieceSize.height;
	int trueYRot;
	int trueXRot;
	for (i = 0; i < numberOfPieces; i++)	{
		cp = &theConfettiArray[i];
		glLoadIdentity();                       // Reset current modelview matrix
		glTranslatef( cp->xVal, cp->yVal, defaultDepth + cp->zVal );      // Move right 3 units
	
		glRotatef( cp->xRot, 1.0f, 0.0f, 0.0f );
		glRotatef( cp->yRot, 0.0f, 1.0f, 0.0f );
		glRotatef( cp->zRot, 0.0f, 0.0f, 1.0f );

		trueYRot = (int)cp->yRot % 360;
		trueXRot = (int)cp->xRot % 360;
	
		glBindTexture( GL_TEXTURE_2D, cp->texture );
		if ((trueYRot > 90 && trueYRot < 270) || (trueXRot > 90 && trueXRot < 270))
			glNormal3f( 0.0f, 0.0f, -1.0f );      // Normal Pointing Towards Viewer
		else
			glNormal3f(0.0f, 0.0f, 1.0f);

		glBegin( GL_QUADS );                // Draw a quad
			glTexCoord2f( 0.0f, 0.0f );
			glVertex3f( -(width/2), -(height/2), 0.0f);   // Bottom left

			glTexCoord2f( 1.0f, 0.0f );
			glVertex3f(  width/2, -(height/2), 0.0f);   // Bottom right
		
			glTexCoord2f( 1.0f, 1.0f );
			glVertex3f(  width/2,  height/2, 0.0f);   // Top right

			glTexCoord2f( 0.0f, 1.0f );
			glVertex3f( -(width/2),  height/2, 0.0f );   // Top left
		glEnd();                            // Quad is complete

		cp->yVal -= (rand() % 100) / 1000.0;
		cp->xRot +=   rand() % 10;
		cp->yRot +=   rand() % 10;
		cp->zRot +=  rand() % 10;

		if (cp->yVal < -2.5)
			[self resetConfettiPieceAtIndex:i];
	}
	
/*	glLoadIdentity();
//	stringZ = -4.0;
	glTranslatef( 0.0f, 0.0f, stringZ );      // Move right 3 units

	glBindTexture( GL_TEXTURE_2D, stringTexture );
	glNormal3f( 0.0f, 0.0f, 1.0f );      // Normal Pointing Towards Viewer

	glBegin( GL_QUADS );	// Draw a quad
		glTexCoord2f(0.0f, 0.0f);
		glVertex3f(-1.0f, -1.0f, 0.0f);

		glTexCoord2f(0.0f, 1.0f);
		glVertex3f(-1.0f, 1.0f, 0.0f);
		
		glTexCoord2f(1.0f, 1.0f);
		glVertex3f(1.0f, 1.0f, 0.0f);
		
		glTexCoord2f(1.0f, 0.0f);
		glVertex3f(1.0f, -1.0f, 0.0f);
	glEnd();
*/
	[self unlockFocus];

   [ [ self openGLContext ] flushBuffer ];
}


-(void) resetConfettiPieceAtIndex:(int)index	{
	ConfettiPiece* cp = &theConfettiArray[index];
	cp->xRot = rand() % 360;
	cp->yRot = rand() % 360;
	cp->zRot = rand() % 360;
	cp->zVal = -1 + (rand() % 200) / 100.0;
	NSRect tmpBounds = [self boundsForDepth:defaultDepth + cp->zVal];
//	NSLog(@"bounds = %@", NSStringFromRect(tmpBounds));
	cp->xVal = tmpBounds.origin.x + (rand() % (int)(100.0 * tmpBounds.size.width)) / 100.0;
//	cp->xVal = -3.5f + (rand() % 700) / 100.0;//0.0f;
	cp->yVal = (7 * (rand() % 100) / 100.0) + 2.5f;

	cp->texture = colorTextures[rand() % 4];
}

-(NSColor*) randomColor	{
	NSArray* colors = [NSArray arrayWithObjects:[NSColor blueColor], [NSColor redColor], [NSColor greenColor], [NSColor yellowColor], nil];
	return [colors objectAtIndex:rand() % [colors count]];
}
/*
-(void) createPieces	{
//	NSLog(@"creating a piece");
	int i;
	ConfettiPiece* cp;
	NSData* data;
	if ([confettiArray count] > 50)
		return;
	NSColor* color;
	int newPieceCount = rand() % 2;
	for (i = 0; i < newPieceCount; i++)	{
//		cp = ConfettiPiece;
		cp = malloc( sizeof(ConfettiPiece));
//		NSLog(@"got the piece");
		cp->xRot = rand() % 360;
		cp->yRot = rand() % 360;
		cp->zRot = rand() % 360;
		cp->xVal = -3.5f + (rand() % 700) / 100.0;//0.0f;
		cp->yVal = 2.5f;
		
		color = [self randomColor];
//		cp->red = 256 * [color redComponent];
//		cp->blue = 256 * [color blueComponent];
//		cp->green = 256 * [color greenComponent];
//		cp->red = rand() % 256;
//		cp->blue = rand() % 256;
//		cp->green = rand() % 256;
//		NSLog(@"set the piece, %d, %d, %d", cp->red, cp->blue, cp->green);
		data = [NSData dataWithBytes:cp length:sizeof(ConfettiPiece)];
		[confettiArray addObject:data];
//		confettiPieces[numberOfPieces] = cp;
//		NSLog(@"put it in the array, %d, %d", [confettiArray count], numberOfPieces);
		numberOfPieces++;
	}
}*/

/*
 * Are we full screen?
 */
- (BOOL) isFullScreen
{
   return runningFullScreen;
}


/*
 * Cleanup
 */
 
  -(NSRect) boundsForDepth:(float)zVal	{
	float deg = 22.5;
	float pi = 3.14159265358979;
	float rad = deg * (pi / 180);
	float h = -zVal * tan(rad);
	float w = h * ([self bounds].size.width / [self bounds].size.height);

	return NSMakeRect(-w, -h, 2.0 * w, 2.0 * h);
	
 }
 
-(NSRect) rectForPixelRect:(NSRect)pRect depth:(float)zVal	{
	NSRect zBounds = [self boundsForDepth:zVal];
	NSSize frameSize = [self frame].size;
//	bounds.origin.x 0;
	NSPoint orgProportion = NSMakePoint(pRect.origin.x / frameSize.width, 
	                                    pRect.origin.y / frameSize.height);
	NSSize szProportion = NSMakeSize(pRect.size.width / frameSize.width, 
	                                 pRect.size.height / frameSize.height);
	
	NSPoint org = NSMakePoint(zBounds.origin.x + orgProportion.x * zBounds.size.width, 
	                          zBounds.origin.y + orgProportion.y * zBounds.size.height);
	NSSize sz = NSMakeSize(szProportion.width * zBounds.size.width, 
	                       szProportion.height * zBounds.size.height);
	
	return NSMakeRect(org.x, org.y, sz.width, sz.height);
}
- (void) dealloc
{
   if( runningFullScreen )
      [ self switchToOriginalDisplayMode ];
   [ originalDisplayMode release ];
}

@end

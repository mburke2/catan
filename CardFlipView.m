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

/* Lesson07View.m */

#import "CardFlipView.h"
#define NSLog //

@interface CardFlipView (InternalMethods)
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame;
- (void) switchToOriginalDisplayMode;
- (BOOL) initGL;
- (BOOL) loadGLTextures;
- (BOOL) loadBitmap:(NSString *)filename intoIndex:(int)texIndex;
- (void) checkLighting;
@end

@implementation CardFlipView

// Ambient light values
static GLfloat lightAmbient[] = { 0.5f, 0.5f, 0.5f, 1.0f };
// Diffuse light values
static GLfloat lightDiffuse[] = { 1.0f, 1.0f, 1.0f, 1.0f };
// Light position
static GLfloat lightPosition[] = { -0.2f, 0.2f, 2.0f, 1.0f };

//- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits
  //     depthBits:(int)numDepthBits fullscreen:(BOOL)runFullScreen	{

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
   xrot = yrot = xspeed = yspeed = filter = 0;
   z = -5.0f;
   pixelFormat = [self createPixelFormat:frame];
   if( pixelFormat != nil )	{
      self = [super initWithFrame:frame pixelFormat:pixelFormat];
      [ pixelFormat release ];
      if(self)	{
         [[ self openGLContext] makeCurrentContext];
         if( runningFullScreen )
            [[self openGLContext] setFullScreen];
         [self reshape];
         if (![self initGL])	{
            [self clearGLContext];
            self = nil;
         }
      }
   }
   else
      self = nil;

   return self;
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
- (BOOL) initGL
{
   if( ![self loadGLTextures] )
      return NO;
	NSLog(@"continuing with init");
	glEnable( GL_TEXTURE_2D );                // Enable texture mapping
	glShadeModel( GL_SMOOTH );                // Enable smooth shading
	glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );   // Black background
	glClearDepth( 1.0f );                     // Depth buffer setup
	glEnable( GL_DEPTH_TEST );                // Enable depth testing
	glDepthFunc( GL_LEQUAL );                 // Type of depth test to do
	// Really nice perspective calculations
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );

	// Setup ambient light
	glLightfv( GL_LIGHT1, GL_AMBIENT, lightAmbient );
	// Setup diffuse light
	glLightfv( GL_LIGHT1, GL_DIFFUSE, lightDiffuse );
	// Position the light
	glLightfv( GL_LIGHT1, GL_POSITION, lightPosition );
	glEnable( GL_LIGHT1 );   // Enable light 1
	
//	glEnable( GL_LIGHTING );

	glEnable (GL_BLEND); 
	glBlendFunc (GL_ONE, GL_ONE);

	long int opaque = 0;
	[[self openGLContext] setValues:&opaque forParameter:NSOpenGLCPSurfaceOpacity];
	return YES;
}

-(BOOL) isOpaque	{
	return NO;
}
-(GLuint) textureForImage:(NSImage*)image size:(NSSize)sz	{
//	NSLog(@"getting texture for %@", image);
//	image = [self shadowedImageForImage:image];

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

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR  );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,  GL_LINEAR);
//	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
//	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST );

	GLint internalFormat;
	GLenum format;
	if ([texRep hasAlpha])	{
		NSLog(@"texRep hasAlpha");
		internalFormat = 4;
		format = GL_RGBA;
	}
	else	{
		NSLog(@"no alpha");
		internalFormat = 3;
		format = GL_RGB;
	}
		
	
	gluBuild2DMipmaps(GL_TEXTURE_2D, internalFormat, [texRep pixelsWide], [texRep pixelsHigh], format, GL_UNSIGNED_BYTE, [texRep bitmapData] );

//	glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, [texRep pixelsWide], [texRep pixelsHigh] , 0, format, GL_UNSIGNED_BYTE, [texRep bitmapData]);

	NSLog(@"localTexture = %d",localTexture);
	return localTexture;
}

/*
 * Setup a texture from our model
 */
- (BOOL) loadGLTextures
{
//   BOOL status = FALSE;
	NSSize sz = NSMakeSize(256, 256);
//	NSLog(@"loading textures");
	shadowTexture = [self textureForImage:[NSImage imageNamed:@"ShadowRes"] size:NSMakeSize(256, 256)];
//	NSLog(@"got shadow");
	NSArray* names = [NSArray arrayWithObjects:@"BrickRes", @"WoodRes", @"SheepRes", @"GrainRes", @"OreRes", nil];
	cardSize = [[NSImage imageNamed:@"BackRes"] size];
//	backTexture = [self textureForImage:[NSImage imageNamed:@"WoodRes.tiff"] size:NSMakeSize(512, 512)];
	
	textures = [NSMutableDictionary dictionary];
	int i;
	for (i = 0; i < [names count]; i++)	{
		[textures setObject:[NSNumber numberWithInt:[self textureForImage:[NSImage imageNamed:[names objectAtIndex:i]] size:sz]]
			forKey:[names objectAtIndex:i]];
//			NSLog(@"got %@", [names objectAtIndex:i]);
	}
	[textures retain];
	frontTexture  = [self textureForImage:[NSImage imageNamed:@"BackRes"] size:sz];	
//	NSLog(@"loaded");
//	NSImage* bgImage = [[[NSImage alloc] initWithSize:NSMakeSize(64, 64)] autorelease];
//	[bgImage lockFocus];
//	[[NSColor whiteColor] set];
//	[NSBezierPath fillRect:NSMakeRect(0, 0, [bgImage size].width, [bgImage size].height)];
//	[bgImage unlockFocus];
//	bgTexture = [self textureForImage:bgImage size:[bgImage size]];
	return YES;
 /*  if( [ self loadBitmap:[ NSString stringWithFormat:@"%@/%s",
                                    [ [ NSBundle mainBundle ] resourcePath ],
                                    "Crate.bmp" ] intoIndex:0 ] )
   {
//		NSLog(@
      status = TRUE;

      glGenTextures( 3, &texture[ 0 ] );   // Create the textures

      // Create nearest filtered texture
      glBindTexture( GL_TEXTURE_2D, texture[ 0 ] );
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
      glTexImage2D( GL_TEXTURE_2D, 0, 3, texSize[ 0 ].width,
                    texSize[ 0 ].height, 0, texFormat[ 0 ],
                    GL_UNSIGNED_BYTE, texBytes[ 0 ] );
      // Create linear filtered texture
      glBindTexture( GL_TEXTURE_2D, texture[ 1 ] );
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
      glTexImage2D( GL_TEXTURE_2D, 0, 3, texSize[ 0 ].width,
                    texSize[ 0 ].height, 0, texFormat[ 0 ],
                    GL_UNSIGNED_BYTE, texBytes[ 0 ] );
      // Create mipmapped texture
      glBindTexture( GL_TEXTURE_2D, texture[ 2 ] );
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
      glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
                       GL_LINEAR_MIPMAP_NEAREST );
      gluBuild2DMipmaps( GL_TEXTURE_2D, 3, texSize[ 0 ].width,
                         texSize[ 0 ].height, texFormat[ 0 ],
                         GL_UNSIGNED_BYTE, texBytes[ 0 ] );

      free( texBytes[ 0 ] );
   }

   return status;*/
}


/*
 * The NSBitmapImageRep is going to load the bitmap, but it will be
 * setup for the opposite coordinate system than what OpenGL uses, so
 * we copy things around.
 */
 /*
- (BOOL) loadBitmap:(NSString *)filename intoIndex:(int)texIndex
{
   BOOL success = FALSE;
   NSBitmapImageRep *theImage;
   int bitsPPixel, bytesPRow;
   unsigned char *theImageData;
   int rowNum, destRowNum;
	filename = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"BackResScaledLarge.tiff"];
   theImage = [ NSBitmapImageRep imageRepWithContentsOfFile:filename ];
 //  NSImage* newImage = [[[NSImage alloc] initWithSize:NSMakeSize(512, 512)] autorelease];
//   [newImage lockFocus];
//   [theImage drawInRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height)];
//   [newImage unlockFocus];
//   [[newImage TIFFRepresentation] writeToFile:@"/BackResScaledMed.tiff" atomically:NO];
  
    if( theImage != nil )
   {
      bitsPPixel = [ theImage bitsPerPixel ];
      bytesPRow = [ theImage bytesPerRow ];
      if( bitsPPixel == 24 )        // No alpha channel
         texFormat[ texIndex ] = GL_RGB;
      else if( bitsPPixel == 32 )   // There is an alpha channel
         texFormat[ texIndex ] = GL_RGBA;
      texSize[ texIndex ].width = [ theImage pixelsWide ];
      texSize[ texIndex ].height = [ theImage pixelsHigh ];
      texBytes[ texIndex ] = calloc( bytesPRow * texSize[ texIndex ].height,
                                     1 );
      if( texBytes[ texIndex ] != NULL )
      {
         success = TRUE;
         theImageData = [ theImage bitmapData ];
         destRowNum = 0;
         for( rowNum = texSize[ texIndex ].height - 1; rowNum >= 0;
              rowNum--, destRowNum++ )
         {
            // Copy the entire row in one shot
            memcpy( texBytes[ texIndex ] + ( destRowNum * bytesPRow ),
                    theImageData + ( rowNum * bytesPRow ),
                    bytesPRow );
         }
      }
   }
   return success;
}*/
/*
-(NSString*) stringFromData:(NSData*)data	{
	NSMutableString* str = [NSMutableString string];
	unsigned char buffer[50];
//	NSRange
//	int i;
	[data getBytes:buffer length:50];
	for (i = 0; i < 50; i++)	{
		[str appendFormat:@"%d ", buffer[i]];
	}
	return str;
}*/

/*
 * Resize ourself
 */
- (void) reshape
{ 
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
}

-(void) setImage:(NSString*)name	{
	backTexture = [[textures objectForKey:name] intValue];
	[self pickRotationType];
}

-(void) pickRotationType	{
	rotationType = rand() % 6;
//	NSArray* keys = [textures allKeys];
//	NSString* key = [keys objectAtIndex:rand() % [keys count]];
//	backTexture = [[textures objectForKey:key] intValue];
}
-(void) setProgress:(float)f	{
	yrot = 180 * f;
}

/*
 * Called when the system thinks we need to draw.
 */
- (void) drawRect:(NSRect)rect	{
	[self lockFocus];
	[self drawScene];
	[self unlockFocus];
}

-(void) rotateShadow	{
	int rot = (int)yrot % 360;
//	if (rot > 90 && rot < 270)
//		rot += 180;
	switch (rotationType)	{
		case 0:	
			glRotatef( rot, 0.0f, 1.0f, 0.0f );
			break;
		case 1:
			glRotatef( -rot, 0.0f, 1.0f, 0.0f );
			break;
		case 2:
			glRotatef( rot, 1.0f, 0.0f, 0.0f );
			break;
		case 3:
			glRotatef( -rot, 1.0f, 0.0f, 0.0f );
			break;
		case 4:
			if (yrot > 90)	{
//				glNormal3f(0.0f, 0.0f, -1.0f);
				glRotatef(yrot - 180 , 1.0f, 1.0f, 0.0f );
				glRotatef( (yrot / 2) - 90, 0.0f, 0.0f, 1.0f);

			}
			else	{
				glRotatef(yrot, 1.0f, 1.0f, -0.0f );
				glRotatef( -yrot / 2, 0.0f, 0.0f, 1.0f);
			}

//			glRotatef(yrot, 0.0f, 1.0f, 0.0f);
			break;
		case 5:
			if (yrot > 90)		{
				glRotatef(180 - yrot, 1.0f, 1.0f, 0.0f);
				glRotatef(yrot/2 - 90, 0.0f, 0.0f, 1.0f);

			}
			else	{
				
				glRotatef( -yrot, 1.0f, 1.0f, 0.0f );
				glRotatef( -yrot /2  , 0.0f, 0.0f, 1.0f);
			}
			break;

		default:
			NSLog(@"no rotation");
	}
}
-(void) rotate	{
	int rot = (int)yrot % 360;
	if (rot > 90 && rot < 270)
		rot += 180;
	switch (rotationType)	{
		case 0:	
			glRotatef( rot, 0.0f, 1.0f, 0.0f );
			break;
		case 1:
			glRotatef( -rot, 0.0f, 1.0f, 0.0f );
			break;
		case 2:
			glRotatef( rot, 1.0f, 0.0f, 0.0f );
			break;
		case 3:
			glRotatef( -rot, 1.0f, 0.0f, 0.0f );
			break;
		case 4:
			if (yrot > 90)	{
//				glNormal3f(0.0f, 0.0f, -1.0f);
				glRotatef(yrot - 180 , 1.0f, 1.0f, 0.0f );
				glRotatef( (yrot / 2) - 90, 0.0f, 0.0f, 1.0f);

			}
			else	{
				glRotatef(yrot, 1.0f, 1.0f, -0.0f );
				glRotatef( -yrot / 2, 0.0f, 0.0f, 1.0f);
			}

//			glRotatef(yrot, 0.0f, 1.0f, 0.0f);
			break;
		case 5:
			if (yrot > 90)		{
				glRotatef(180 - yrot, 1.0f, 1.0f, 0.0f);
				glRotatef(yrot/2 - 90, 0.0f, 0.0f, 1.0f);

			}
			else	{
				
				glRotatef( -yrot, 1.0f, 1.0f, 0.0f );
				glRotatef( -yrot /2  , 0.0f, 0.0f, 1.0f);
			}
			break;

		default:
			NSLog(@"no rotation");
	}
}

-(GLuint) faceForRotation	{
//	if (rotationType < 3)	{
		if (yrot > 90)
			return backTexture;
		return frontTexture;
//	}
	
	return backTexture;
}	
-(void) drawScene	{
//	[self lockFocus];
//	NSLog(@"drawing");
   // Clear the screen and depth buffer
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
//	float bgSize = 10.0;


	NSRect bounds = [self bounds];
	NSRect cardRect = NSMakeRect(bounds.origin.x + (bounds.size.width - cardSize.width) / 2,
								 bounds.origin.y + (bounds.size.height - cardSize.height) / 2,
								 cardSize.width, cardSize.height);
//	NSRect shadowRect = NSMakeRect(cardRect.origin.x + 10, cardRect.origin.y - 10, cardRect.size.width, cardRect.size.height);
	NSRect shadowRect = cardRect;
	float shadowDepth  = -5.0;
	cardRect = [self rectForPixelRect:cardRect depth:z];
	shadowRect= [self rectForPixelRect:shadowRect depth:z + shadowDepth];
	NSSize shadowOffset = [self rectForPixelRect:NSMakeRect(0, 0, 10, 10) depth:z + shadowDepth].size;
//	NSRect shadowRect = NSMakeRect(cardRect.origin.x + shadowOffset.width,
//		cardRect.origin.y - shadowOffset.height, 
//		cardRect.size.width, 
//		cardRect.size.height);
		
//	glRotatef( -yrot, 1.0f, 1.0f, 0.0f );
//	glRotatef(-yrot / 2, 0.0f, 0.0f, 1.0f);
	float y = 1.61666666666667;
	int trueRot = (int)yrot % 360;

//	if (trueRot < 90 || trueRot > 270)		{
//		glBindTexture( GL_TEXTURE_2D, frontTexture );
//	}
//	else	{
//		glRotatef(180.0f, 0.0f, 1.0f, 0.0f);
//		glBindTexture( GL_TEXTURE_2D, backTexture );
//	}
	glLoadIdentity();
	glTranslatef(shadowOffset.width, -shadowOffset.height, z + shadowDepth);

	[self rotate];
	shadowDepth = 0;
	glBindTexture(GL_TEXTURE_2D, shadowTexture);

	glBegin( GL_QUADS ); 

//	glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE);
	glTexCoord2f( 0.0f, 0.0f );
	glVertex3f( shadowRect.origin.x, shadowRect.origin.y,  shadowDepth );   // Point 1 (Front) 

	glTexCoord2f( 1.0f, 0.0f );
	glVertex3f(  shadowRect.origin.x + shadowRect.size.width, shadowRect.origin.y,  shadowDepth );   // Point 2 (Front)

	glTexCoord2f( 1.0f, 1.0f );
	glVertex3f(  shadowRect.origin.x + shadowRect.size.width,  shadowRect.origin.y + shadowRect.size.height,  shadowDepth );   // Point 3 (Front)

	glTexCoord2f( 0.0f, 1.0f );
	glVertex3f( shadowRect.origin.x,  shadowRect.origin.y + shadowRect.size.height,  shadowDepth );   // Point 4 (Front)	

	glEnd();
//	glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);

	glBindTexture(GL_TEXTURE_2D, [self faceForRotation]);

	glLoadIdentity();   // Reset the current modelview matrix
	

	glTranslatef( 0.0f, 0.0f, z );   // In/out of screen by zPos
	glNormal3f( 0.0f, 0.0f, 1.0f );      // Normal Pointing Towards Viewer

	[self rotate];

	glBegin(GL_QUADS);

	glTexCoord2f( 0.0f, 0.0f );
	glVertex3f( cardRect.origin.x, cardRect.origin.y,  0.0f );   // Point 1 (Front) 

	glTexCoord2f( 1.0f, 0.0f );
	glVertex3f(  cardRect.origin.x + cardRect.size.width, cardRect.origin.y,  0.0f );   // Point 2 (Front)

	glTexCoord2f( 1.0f, 1.0f );
	glVertex3f(  cardRect.origin.x + cardRect.size.width,  cardRect.origin.y + cardRect.size.height,  0.0f );   // Point 3 (Front)

	glTexCoord2f( 0.0f, 1.0f );
	glVertex3f( cardRect.origin.x,  cardRect.origin.y + cardRect.size.height,  0.0f );   // Point 4 (Front)	
	glEnd();                             // Done Drawing Quads



//	[self unlockFocus];
	[[self openGLContext] flushBuffer];

//   xrot += xspeed;
//   yrot += yspeed;
}


-(void) hide	{
	[self setHidden:YES];
}

-(NSImage*) shadowedImageForImage:(NSImage*)image	{
	NSImage* newImage = [[[NSImage alloc] initWithSize:NSMakeSize([image size].width + 10, [image size].height + 10)] autorelease];
	NSShadow* shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowOffset:NSMakeSize(10, -10)];
	[shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.6]];
	[shadow setShadowBlurRadius:3.0];
	
	[newImage lockFocus];
	[shadow set];
	[image drawInRect:NSMakeRect(0, 10, [image size].width, [image size].height) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
	[newImage unlockFocus];
	
	
	return newImage;
}



/*
 * Are we full screen?
 */
- (BOOL) isFullScreen
{
   return runningFullScreen;
}

-(NSRect) boundsForDepth:(float)zVal	{
	float deg = 22.5;
	float pi = 3.14159265358979;
	float rad = deg * (pi / 180);
	float h = -zVal * tan(rad);
	float w = h * ([self bounds].size.width / [self bounds].size.height);

	return NSMakeRect(-w, -h, 2.0 * w, 2.0 * h);
	
 }
 
-(NSRect) rectForPixelRect:(NSRect)pRect depth:(float)zVal	{
	NSLog(@"pixelRect = %@", NSStringFromRect(pRect));
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


- (void) toggleLight
{
   light = !light;
   [ self checkLighting ];
}


- (void) selectNextFilter
{
   filter = ( filter + 1 ) % 3;
}


- (void) decreaseZPos
{
   z -= 0.02f;
}


- (void) increaseZPos
{
   z += 0.02f;
}


- (void) decreaseXSpeed
{
   xspeed -= 0.01f;
}

- (void) increaseXSpeed
{
   xspeed += 0.01f;
}

- (void) decreaseYSpeed
{
   yspeed -= 0.01f;
}

- (void) increaseYSpeed
{
   yspeed += 0.01f;
}


- (void) checkLighting
{
   if( !light )
      glDisable( GL_LIGHTING );
   else
      glEnable( GL_LIGHTING );
}


/*
 * Cleanup
 */
- (void) dealloc
{
   if( runningFullScreen )
      [ self switchToOriginalDisplayMode ];
   [ originalDisplayMode release ];
}

@end

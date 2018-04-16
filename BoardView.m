#import "BoardView.h"
#import "PurchaseTableView.h"
#import "DiceValueChips.h"

static NSSize ROBBER_SIZE;

#define PP //NSLog(@"%s", __FUNCTION__)

@implementation BoardView

- (id)initWithFrame:(NSRect)frameRect	{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		ROBBER_SIZE = NSMakeSize(20, 30);
		unshadedTiles = nil;
//		nilPoint = NSMakePoint(-1, -1);
		// Add initialization code here
//		myHexagons = nil;
//		pointToHighlight = nilPoint;
	//	lineToHighlight = nil;
//		[self buildBoard];
//		[self setPostsBoundsChangedNotifications:YES];
		theBoard = nil;
		[self setPostsFrameChangedNotifications:YES];
		robberIsMoving = NO;
		vertexHighlightSize = NSMakeSize(12, 12);
		highlightWidth = 4.0;
		shouldAdjustImage = NO;
		bgColor = [NSColor colorWithCalibratedRed:0.4 green:0.5 blue:0.55 alpha:0.4];
		[bgColor retain];
		drawingLocked = NO;
//		int i;
	//	theVertices = [[NSMutableArray alloc] init];
	//	for (i = 0; i < 54; i++)	{
	//		[theVertices addObject:[[[Vertex alloc] init] autorelease]];
	//	}
		vertexToHighlight = nil;
		edgeToHighlight = nil;
		hexToHighlight = nil;
		robberRect = NSMakeRect(0, 0, 0, 0);
//		[self createBoard];
//		[self adjustBoard];
		NSMutableArray* tmpTiles = [NSMutableArray array];
		int i, j;
		for (i = 0; i < 18; i++)	{
			[tmpTiles addObject:[[[BoardHexagon alloc] init] autorelease]];
			[[tmpTiles objectAtIndex:i] setResource:@"Water"];
			for (j = 0; j < 6; j++)	{
				[[tmpTiles objectAtIndex:i] addVertex:[Vertex vertexWithLocation:NSMakePoint(0, 0)]];
			}
		}
		waterTiles = [NSArray arrayWithArray:tmpTiles];
		[waterTiles retain];
//		[waterTiles retain];
		[self registerForDraggedTypes:[NSArray arrayWithObject:@"CATAN_ROBBER_TYPE"]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameChanged:) name:NSViewFrameDidChangeNotification object:self];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsChanged:) name:NSViewBoundsDidChangeNotification object:self];
	}
	return self;
}

-(void) awakeFromNib	{
	[self setBoard:[[GameController gameController] board]];
}
#pragma mark RESIZING
-(void) frameChanged:(NSNotification*)note	{
	if ([self inLiveResize])
		return;
	[self adjustBoard];
//	shouldAdjustImage = YES;
}

- (void)viewDidEndLiveResize	{
	PP;
	[self unlockDrawing];
}
- (void)viewWillStartLiveResize	{
	PP;
	[self lockDrawing];
//	[[imageView image] lockFocus];
//	[self drawRect:[self bounds]];
//	[self drawTokens:[self bounds]];
//	[self drawRobber:[self bounds]];
//	[[imageView image] unlockFocus];
}

-(void) lockDrawing	{
	[[imageView image] lockFocus];
	[self drawRect:[self bounds]];
//	[self drawTokens:[self bounds]];
//	[self drawRobber:[self bounds]];
	[[imageView image] unlockFocus];
	drawingLocked = YES;

}


-(void) updateBackground	{
//	[self adjustBoard];
//	[self adjustBoardImage];
//	[[imageView image] lockFocus];
//	[self drawTradeRoutes:[self bounds]];
//	[[imageView image] unlockFocus];
//	[imageView setNeedsDisplay:YES];
//	[self adjustBoardImage];
	[self adjustBoard];
	[self adjustBoardImage];
	[self display];
}


-(void) unlockDrawing	{
	drawingLocked = NO;
	[self adjustBoard];
	[self adjustBoardImage];
	[self display];
}

-(void) unshadeAllTiles	{
	[unshadedTiles release];
	unshadedTiles = nil;
	[self setNeedsDisplay:YES];
}

-(NSImage*) shadeImageForTiles:(NSArray*)notShaded	{
	NSMutableArray* tiles = [NSMutableArray arrayWithArray:[theBoard tiles]];
	[tiles addObjectsFromArray:waterTiles];
	
	NSImage* image = [[[NSImage alloc] initWithSize:[self bounds].size] autorelease];
	[image lockFocus];
	[[[NSColor blackColor] colorWithAlphaComponent:0.6] set];

	int i;
	for (i = 0; i < [tiles count]; i++)	{
		if ([notShaded indexOfObject:[tiles objectAtIndex:i]] == NSNotFound)
			[[[tiles objectAtIndex:i] bezierPath] fill];
	}
	
	[image unlockFocus];
	return image;
}
-(NSImage*)oldshadeImageForTiles:(NSArray*)arr	{
	unshadedTiles = [arr retain];
	NSImage* image = [[[NSImage alloc] initWithSize:[self bounds].size] autorelease];
	[image lockFocus];
	[self drawShade];
	[image unlockFocus];
	[unshadedTiles release];
	unshadedTiles = nil;
	return image;
}

-(void) shadeAllTilesExcept:(NSArray*)arr	{
	PP;
	if ([arr count] == 0)
		return;
	unshadedTiles = [arr retain];
	//NSLog(@"unshaded tiles = %@", arr);
	[self setNeedsDisplay:YES];
}

-(void) adjustBoard	{
	PP;
//	NSLog(@"tradeRoutes = %@", tradeRoutes);
//	NSLog(@"count = %d", [tradeRoutes count]);
	NSPoint verts[54];
	[self calculateLayout:verts];
	
	int i, j;
	NSMutableArray* junkVerts = [NSMutableArray array];
	for (i = 0; i < 54; i++)	{
		[junkVerts addObject:[[[Vertex alloc] init] autorelease]];
		[[junkVerts objectAtIndex:i] setLocation:verts[i]];
//		[[theVertices objectAtIndex:i] setLocation:verts[i]];
	}
	
	[junkVerts sortUsingSelector:@selector(compare:)];
	
	
	NSArray* theVertices = [theBoard tileIntersections];
	NSArray* tradeRoutes = [theBoard tradeRoutes];
	NSArray* edges = [theBoard tileEdges];
	
	for (i = 0; i < [junkVerts count]; i++)	{
		[[theVertices objectAtIndex:i] setLocation:[(Vertex*)[junkVerts objectAtIndex:i] location]];
	}
	
	NSSize sz = [self tileSize];
	NSPoint p1;
	NSPoint p2;
	TradeRoute* tr;
//	NSLog(@"got to here");
//	NSLog(@"coiunt = %d", [tradeRoutes count]);
	for (i = 0; i < [tradeRoutes count]; i++)	{
//		NSLog(@"i = %d", i);
//		NSLog(@"%@", [tradeRoutes objectAtIndex:i]);
		tr = [tradeRoutes objectAtIndex:i];

//		NSLog(@"i = %d, route vertex count = %d", i, [[tr vertices] count]);
//		NSLog(@"got tr");
//		NSLog(@"tr = %@", tr);
		p1 = [(Vertex*)[[tr vertices] objectAtIndex:0] location];
		p2 = [(Vertex*)[[tr vertices] objectAtIndex:1] location];
		[[tradeRoutes objectAtIndex:i] setLocation:
			NSMakePoint(0.5 * sz.width * [tr offset].x + (p1.x + p2.x) / 2.0, 0.5 * sz.height * [tr offset].y + (p1.y + p2.y) / 2.0)];
	}
	
	Edge* e;
	for (i = 0; i < [edges count]; i++)	{
		if ([(Edge*)[edges objectAtIndex:i] item])	{
			e = [edges objectAtIndex:i];
			[e orientToken];
		}
	}
	
	if (robberRect.size.width > 0 && robberRect.size.height > 0)	{
		robberRect.origin.x = robberOriginPercentOfFrame.x * [self frame].size.width;
		robberRect.origin.y = robberOriginPercentOfFrame.y * [self frame].size.height;
	}
	
	NSArray* waterHexes = [self waterHexagonsForRect:[self bounds]];
//	int i;
	NSArray* realVs;
	NSPoint newVs[6];
//	NSLog(@"counts = %d, %d", [waterTiles count], [waterHexes count]);
	for (i = 0; i < [waterTiles count]; i++)	{
//		NSLog(@"i = %d", i);
//		NSLog(@"copying");
		[[waterHexes objectAtIndex:i] copyVertices:newVs];
	//	NSLog(@"getting");	
	//	NSLog(@"%@", waterTiles);
	//	NSLog(@"from %@", [waterTiles objectAtIndex:i]);
		realVs = [(BoardHexagon*)[waterTiles objectAtIndex:i] vertices];
	//	NSLog(@"got");
	//	NSLog(@"vertices = %@", realVs);
		for (j = 0; j < 6; j++)	{
	//		NSLog(@"setting j = %d", j);
	//		NSLog(@"new point = %@", NSStringFromPoint(newVs[j]));
	//		NSLog(@"old vertex = %@", [realVs objectAtIndex:j]);
			[(Vertex*)[realVs objectAtIndex:j] setLocation:newVs[j]];
		}
	}
}

-(void) adjustBoardImage	{
	NSImage* image = [[[NSImage alloc] initWithSize:[self frame].size] autorelease];
	[image lockFocus];
	[self drawBoardTiles:[self bounds]];
	[self drawTradeRoutes:[self bounds]];
	[image unlockFocus];
//	[[image TIFFRepresentation] writeToFile:@"/aBoardImage.tiff" atomically:NO];
	[imageView setImage:image];
	shouldAdjustImage = NO;
}
#pragma mark -	LAYOUT

-(NSSize) tileSize	{
//	return NSMakeSize( ([self bounds].size.width - 50) / 5.0, ([self bounds].size.height - 50) / 5.0);
//	return NSMakeSize(([self bounds].size.width - 50) / 5.0, [self bounds].size.height / 7.0);
	return NSMakeSize([self bounds].size.width / 5.5, [self bounds].size.height / 7.0);
//	return NSMakeSize(0, 0);
}


-(NSSize) tradeRouteSize	{
	NSSize tileSize = [self tileSize];
	return NSMakeSize(tileSize.width / 2, tileSize.height / 2);
}

-(void) calculateLayout:(NSPoint[54])ptsRef	{
	NSRect bRect = [self bounds];
//	bRect.size.width -= 100;
//	bRect.size.height -= 100;
//	bRect.origin.x += 50;
//	bRect.origin.y += 50;
	NSArray* hexagons = [self hexagonsForRect:bRect];
//	[[NSColor grayColor] set];
	Hexagon* hex;
	NSPoint tmpVerts[6];
	int i, j, k;
	int counter = 0;
	NSPoint tmpVert;
	BOOL tmpFlag;
	for (i = 0; i < [hexagons count]; i++)	{
		hex = [hexagons objectAtIndex:i];
		[hex copyVertices:tmpVerts];
		for (j = 0; j < 6; j++)	{
			tmpVert = tmpVerts[j];
			tmpFlag = NO;
			for (k = 0; k < counter && k < 54 && tmpFlag == NO; k++)	{
				if (ptsRef[k].x - 1 < tmpVert.x && ptsRef[k].x + 1 > tmpVert.x &&  ptsRef[k].y - 1 < tmpVert.y && ptsRef[k].y + 1 > tmpVert.y)
					tmpFlag = YES;
			}
			if (tmpFlag == NO)	{
				ptsRef[counter] = tmpVert;
				counter++;
			}
		}
	}

}


-(void) setBoard:(Board*)b	{
	[theBoard release];
	theBoard = [b retain];
	[self adjustBoard];
//	[imageView setImage:[[[NSImage alloc] initWithSize:NSMakeSize(1, 1)] autorelease]];
	[imageView removeFromSuperview];
	[imageView release];
	imageView = [[NSImageView alloc] initWithFrame:[self frame]];
	[imageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	[imageView setImageScaling:NSScaleToFit];
	[[self superview] addSubview:imageView positioned:NSWindowBelow relativeTo:self];

	[self adjustBoardImage];
	robberRect = NSMakeRect(0, 0, ROBBER_SIZE.width, ROBBER_SIZE.height);

	NSRect desRect = [[[theBoard tiles] objectAtIndex:0] bounds];
	robberRect.origin.x = desRect.origin.x + ((desRect.size.width - robberRect.size.width) / 2);
	robberRect.origin.y = desRect.origin.y + (desRect.size.height / 10);

	robberOriginPercentOfFrame.x = robberRect.origin.x / [self bounds].size.width;
	robberOriginPercentOfFrame.y = robberRect.origin.y / [self bounds].size.height;

/*
	NSImage* image = [[NSImage alloc] initWithSize:[self frame].size];
	[image lockFocus];
	[self drawBoardTiles:[self bounds]];
	[self drawTradeRoutes:[self bounds]];
	[image unlockFocus];
	[imageView setImage:image];
*/	
//	[imageView setImage:[NSImage imageNamed:@"city1Building.png"]];
	
//	NSRect frame = [self frame];
//	frame.origin.x = 0;
//	frame.origin.y = 0;
//	NSLog(@"CREATING RBV, frame = %@", NSStringFromRect(frame));
//	RealBoardView* rbv = [[RealBoardView alloc] initWithFrame:frame];
//	[rbv setBoard:theBoard];
//	[[self superview] addSubview:rbv];
//	[theBoar
}

/*
-(void) boundsChanged:(NSNotification*)note	{
	PP;
}
*/


#pragma mark DRAWING METHODS

-(void) drawRect:(NSRect)rect	{
    

//	NSLog(@"drawing board");

	if ([self inLiveResize] || drawingLocked)
		return;
		
//	NSLog(@"drawRect:%@", NSStringFromRect(rect));
//	if (shouldAdjustImage && [self inLiveResize] == NO)
//		[self adjustBoardImage];
//	NSLog(@"drawRect:");
//	[[NSColor whiteColor] set];
//	[NSBezierPath fillRect:[self bounds]];
//	[[NSColor blackColor] set];
//	[NSBezierPath strokeRect:[self bounds]];

//	NSDate* startTime;
	if (theBoard == nil)
		return;

//	startTime = [NSDate date];		
//	[self drawBoardOutline];
//	NSLog(@"DRAW TIME: drawBoardOutline took %f", -[startTime timeIntervalSinceNow]);

//	startTime = [NSDate date];
//	[self drawBoardTiles:rect];
//	NSLog(@"DRAW TIME: drawBoardTiles took %f", -[startTime timeIntervalSinceNow]);

//	startTime = [NSDate date];
//	NSLog(@"DRAW TIME: drawTradeRoutes took %f", -[startTime timeIntervalSinceNow]);
//	[self drawTradeRoutePaths];
  //  [self drawTradeRoutes:rect];

//	startTime = [NSDate date];
	[self highlightDragPart:rect];
//	NSLog(@"DRAW TIME: highlightDragPart took %f", -[startTime timeIntervalSinceNow]);
	
//	startTime = [NSDate date];	
	[self drawTokens:rect];
//	NSLog(@"DRAW TIME: drawTokens took %f", -[startTime timeIntervalSinceNow]);

//	startTime = [NSDate date];
	[self drawRobber:rect];
//	NSLog(@"DRAW TIME: drawRobber took %f", -[startTime timeIntervalSinceNow]);
	
	

//	[[NSColor blueColor] set];
//	[NSBezierPath strokeRect:rect];
//	[super drawRect:rect];
	
//	[self drawShade];
}

-(void) drawShade	{
//	PP;
	if (unshadedTiles == nil)
		return;
	
//	NSLog(@"drawing shade");
	NSImage* shadeImage = [[[NSImage alloc] initWithSize:[self bounds].size] autorelease];
	NSImage* maskImage = [[[NSImage alloc] initWithSize:[self bounds].size] autorelease];
	int i;
//	[[[NSColor blackColor] colorWithAlphaComponent:0.6] set];
//	[NSBezierPath fillRect:[self bounds]];
//	[[NSColor clearColor] set];
	[maskImage lockFocus];
	[[NSColor blackColor] set];
	for (i = 0; i < [unshadedTiles count]; i++)	{
		[[[unshadedTiles objectAtIndex:i] bezierPath] fill];
	}
	[maskImage unlockFocus];
	
	NSRect rect = NSMakeRect(0, 0, [self bounds].size.width, [self bounds].size.height);
	[shadeImage lockFocus];
	[[[NSColor blackColor] colorWithAlphaComponent:0.4] set];
	[NSBezierPath fillRect:rect];
//	[[NSColor blackColor] set];
	[maskImage drawInRect:rect fromRect:rect operation:NSCompositeDestinationOut fraction:1.0];
	[shadeImage unlockFocus];
	
	
//	[[shadeImage TIFFRepresentation] writeToFile:@"/shade.tiff" atomically:NO];
//	[[maskImage TIFFRepresentation] writeToFile:@"/shadeMask.tiff" atomically:NO];
	[shadeImage drawInRect:[self bounds] fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
}

-(void) drawBoardOutline	{
	[[NSColor grayColor] set];
	int i;
	NSArray* theHexagons = [theBoard tiles];
//	NSLog(@"drawBoardOutline");
	for (i = 0; i < [theHexagons count]; i++)	{
//		NSLog(@"i = %d, hex = %@", i, [theHexagons objectAtIndex:i]);
		[[(BoardHexagon*)[theHexagons objectAtIndex:i] bezierPath] stroke];
	}
}

-(void) drawBackground	{
//	[bgColor set];
//	[NSBezierPath fillRect:[self bounds]];

}

-(void) drawBoardTiles:(NSRect)inRect	{
//	[self drawBackground];

	int i;
	BoardHexagon* hex;
//	NSAttributedString* resString;
//	NSAttributedString* numString;
//	NSDictionary* atts;
//	NSPoint p;
	NSImage* image;
//	NSRect rect;
	
	NSArray* theHexagons = [theBoard tiles];
	int chipSize = 25;
	for (i = 0; i < [theHexagons count]; i++)	{
		hex = [theHexagons objectAtIndex:i];
		
//		if ([hex resource] == nil)
//			image = [NSImage imageNamed:@"Desert.png"];
//		else
//			image = [NSImage imageNamed:[NSString stringWithFormat:@"%@.png", [hex resource]]];
	//	image = [hex image];	
		if (NSIntersectsRect([hex bounds], inRect))	{
			image = [hex image];
			[image drawInRect:[hex bounds] fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
		
			image = [DiceValueChips imageForValue:[hex diceValue] size:NSMakeSize(chipSize, chipSize) letter:[hex letter]];
			[image drawInRect:NSMakeRect([hex center].x - (chipSize / 2), [hex center].y - (chipSize / 2), chipSize, chipSize) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
			
		//	[[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", i] attributes:[NSDictionary dictionaryWithObject:[NSFont fontWithName:@"Helvetica" size:20] forKey:NSFontAttributeName]] autorelease] drawAtPoint:[hex center]];
		}
	/*
		atts = nil;
		if ([hex diceValue] == 6 || [hex diceValue] == 8)
			atts = [NSDictionary dictionaryWithObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
		resString = [[[NSAttributedString alloc] initWithString:[hex resource] attributes:atts] autorelease];
		numString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", [hex diceValue]] attributes:atts] autorelease];
		p = [hex center];
		[resString drawAtPoint:NSMakePoint(p.x - [resString size].width / 2, p.y)];
		[numString drawAtPoint:NSMakePoint(p.x - [numString size].width / 2, p.y - [numString size].height)];*/
	}
	
	for (i = 0; i < [waterTiles count]; i++)	{
		hex = [waterTiles objectAtIndex:i];
		image = [hex image];
		[image drawInRect:[hex bounds] fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
	}
	
//	NSBitmapImageRep* rep = [image 
//	NSArray* colors 
}

-(void) drawTokens:(NSRect)inRect	{
	int i;
	NSImage* image;
	Vertex* v1;
//	Vertex* v2;
	Edge* e;
	NSArray* theVertices = [theBoard tileIntersections];
	NSArray* edges = [theBoard tileEdges];
	
//	NSPoint p1;
//	NSPoint p2;
//	float hold;
//	NSSize sz;
	for (i = 0; i < [edges count]; i++)	{
		e = [edges objectAtIndex:i];
		if ([e item])	{
			image = [[e item] image];
//			NSImage* 
			//[image compositeToPoint:[e imageRect].origin operation:NSCompositeSourceOver];
			//[image drawAtPoint:[e imageRect].origin fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];

			[image drawInRect:[e imageRect] fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
		}
	}
	NSPoint p1;
	NSSize sz;
	NSSize vSize;
	for (i = 0; i < [theVertices count]; i++)	{
		if ([[theVertices objectAtIndex:i] item])	{
			v1 = [theVertices objectAtIndex:i];
			image = [[v1 item] image];
			p1 = [v1 location];
			sz = [image size];
			vSize = [[v1 item] size];
		//	[image compositeToPoint:NSMakePoint(p1.x - sz.width / 2, p1.y - sz.height / 2) operation:NSCompositeSourceOver];
		//	[image drawAtPoint:NSMakePoint([v1 location].x - [image size].width / 2, [v1 location].y - [image size].height / 2) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
//			[image drawInRect:NSMakeRect(p1.x - vSize.width / 2, p1.y - vSize.height / 2, vSize.width, vSize.height) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
			[image drawInRect:[v1 imageRect] fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];

		}
	}
	

}

-(void) drawTradeRoutePaths	{
	int i, j;
	NSPoint p;
	NSPoint controlPoint;
	NSPoint trVerts[2];
	CGFloat dashes[2] = {3.0, 3.0};
	NSRect rect;
	NSBezierPath* tmpPath;
	NSPoint loc;
	NSString* res;
	NSArray* tradeRoutes = [theBoard tradeRoutes];
	NSAttributedString* attStr;
	NSSize imageSize = [self tileSize];
	NSImage* pathImage = [[[NSImage alloc] initWithSize:[self bounds].size] autorelease];
	NSImage* blockImage = [[[NSImage alloc] initWithSize:[self bounds].size] autorelease];
	for (i = 0; i < [tradeRoutes count]; i++)	{
//		pathImage = [[[NSImage alloc] initWithSize:imageSize] autorelease];
		trVerts[0] = [(Vertex*)[[(TradeRoute*)[tradeRoutes objectAtIndex:i] vertices] objectAtIndex:0] location];
		trVerts[1] = [(Vertex*)[[(TradeRoute*)[tradeRoutes objectAtIndex:i] vertices] objectAtIndex:1] location];
		controlPoint = NSMakePoint( (trVerts[0].x + trVerts[1].x) / 2, (trVerts[0].y + trVerts[1].y) / 2);
		loc = [(TradeRoute*)[tradeRoutes objectAtIndex:i] location];
		[pathImage lockFocus];
		for (j = 0; j < 2; j++)	{
			tmpPath = [NSBezierPath bezierPath];
//			[tmpPath moveToPoint:trVerts[0]];
			[tmpPath moveToPoint:[(Vertex*)[[(TradeRoute*)[tradeRoutes objectAtIndex:i] vertices] objectAtIndex:j] location]];
			[tmpPath curveToPoint:loc controlPoint1:controlPoint controlPoint2:loc];
			[tmpPath setLineDash:dashes count:2 phase:2.0];
			if ([(Vertex*)[[(TradeRoute*)[tradeRoutes objectAtIndex:i] vertices] objectAtIndex:j] item] != nil)
				[[NSColor greenColor] set];
			else
				[[NSColor redColor] set];
			
			[tmpPath setLineWidth:2];
			[tmpPath stroke];
//			NSPoint hold = trVerts[0];
//			trVerts[0] = trVerts[1];
//			trVerts[1] = hold;
		}
		[pathImage unlockFocus];
		
		[blockImage lockFocus];
		[[NSColor blackColor] set];
		[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(loc.x - [self tradeRouteSize].width / 2, loc.y - [self tradeRouteSize].height / 2, [self tradeRouteSize].width, [self tradeRouteSize].height)] fill];
		[blockImage unlockFocus];
		/*
		rect = NSMakeRect(loc.x - [self tradeRouteSize].width / 2, loc.y - [self tradeRouteSize].height / 2, [self tradeRouteSize].width, [self tradeRouteSize].height);
		tmpPath = [NSBezierPath bezierPathWithOvalInRect:rect];
		[[NSColor whiteColor] set];
		[tmpPath fill];
		[[NSColor grayColor] set];
		[tmpPath stroke];
		res = [(TradeRoute*)[tradeRoutes objectAtIndex:i] resource];
		if (res)	{
			attStr = [[[NSAttributedString alloc] initWithString:res attributes:nil] autorelease];
			[attStr drawAtPoint:NSMakePoint(loc.x - [attStr size].width / 2, loc.y)];
			
			attStr = [[[NSAttributedString alloc] initWithString:@"2:1" attributes:nil] autorelease];
			[attStr drawAtPoint:NSMakePoint(loc.x - [attStr size].width / 2, loc.y - [attStr size].height)];
		}	
		else	{
			attStr = [[[NSAttributedString alloc] initWithString:@"3:1" attributes:nil] autorelease];
			[attStr drawAtPoint:NSMakePoint(loc.x - [attStr size].width / 2, loc.y - [attStr size].height / 2)];
		}*/
		
	}
	
	NSImage* resultImage = [[[NSImage alloc] initWithSize:[self bounds].size] autorelease];
	[resultImage lockFocus];
	[blockImage drawInRect:[self bounds] fromRect:[self bounds] operation:NSCompositeSourceOver fraction:1.0];
	[pathImage drawInRect:[self bounds] fromRect:[self bounds] operation:NSCompositeSourceOut fraction:1.0];
	[resultImage unlockFocus];
	
		
//	[blockImage drawInRect:[self bounds] fromRect:[self bounds] operation:NSCompositeSourceOver fraction:1.0];
	[resultImage drawInRect:[self bounds] fromRect:[self bounds] operation:NSCompositeSourceOver fraction:1.0];

}


-(void) drawTradeRoutes:(NSRect)inRect	{

	int i, j;
	NSPoint controlPoint;
	NSPoint trVerts[2];
	CGFloat dashes[2] = {4.0, 2.0};
	NSRect rect;
	NSBezierPath* tmpPath;
	NSPoint loc;
	NSString* res;
	NSArray* tradeRoutes = [theBoard tradeRoutes];
	NSAttributedString* attStr;
	NSImage* image;
	for (i = 0; i < [tradeRoutes count]; i++)	{
		trVerts[0] = [(Vertex*)[[(TradeRoute*)[tradeRoutes objectAtIndex:i] vertices] objectAtIndex:0] location];
		trVerts[1] = [(Vertex*)[[(TradeRoute*)[tradeRoutes objectAtIndex:i] vertices] objectAtIndex:1] location];
		controlPoint = NSMakePoint( (trVerts[0].x + trVerts[1].x) / 2, (trVerts[0].y + trVerts[1].y) / 2);
		loc = [(TradeRoute*)[tradeRoutes objectAtIndex:i] location];
		if ([[tradeRoutes objectAtIndex:i] resource])
			attStr = [[[NSAttributedString alloc] initWithString:@"2:1" attributes:nil] autorelease];
		else
			attStr = [[[NSAttributedString alloc] initWithString:@"3:1" attributes:nil] autorelease];
		for (j = 0; j < 2; j++)	{
			tmpPath = [NSBezierPath bezierPath];
//			[tmpPath moveToPoint:trVerts[0]];
			[tmpPath moveToPoint:[(Vertex*)[[(TradeRoute*)[tradeRoutes objectAtIndex:i] vertices] objectAtIndex:j] location]];
			[tmpPath curveToPoint:loc controlPoint1:controlPoint controlPoint2:loc];
			[tmpPath setLineDash:dashes count:2 phase:4.0];
			if ([(Vertex*)[[(TradeRoute*)[tradeRoutes objectAtIndex:i] vertices] objectAtIndex:j] item] != nil)
				[[NSColor greenColor] set];
			else
				[[NSColor redColor] set];
			
			[tmpPath setLineWidth:2];
			[tmpPath stroke];
//			NSPoint hold = trVerts[0];
//			trVerts[0] = trVerts[1];
//			trVerts[1] = hold;
		}
		rect = NSMakeRect(loc.x - [self tradeRouteSize].width / 2, loc.y - [self tradeRouteSize].height / 2, [self tradeRouteSize].width, [self tradeRouteSize].height);
		image = [(TradeRoute*)[tradeRoutes objectAtIndex:i] image];
		[image drawInRect:rect fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
//		[attStr drawAtPoint:NSMakePoint(rect.origin.x + (rect.size.width / 2) - ([attStr size].width / 2), rect.origin.y + (rect.size.height / 2) - ([attStr size].height/ 2))];
/*		tmpPath = [NSBezierPath bezierPathWithOvalInRect:rect];
		[[NSColor whiteColor] set];
		[tmpPath fill];
		[[NSColor grayColor] set];
		[tmpPath stroke];
		res = [(TradeRoute*)[tradeRoutes objectAtIndex:i] resource];
		if (res)	{
			attStr = [[[NSAttributedString alloc] initWithString:res attributes:nil] autorelease];
			[attStr drawAtPoint:NSMakePoint(loc.x - [attStr size].width / 2, loc.y)];
			
			attStr = [[[NSAttributedString alloc] initWithString:@"2:1" attributes:nil] autorelease];
			[attStr drawAtPoint:NSMakePoint(loc.x - [attStr size].width / 2, loc.y - [attStr size].height)];
		}	
		else	{
			attStr = [[[NSAttributedString alloc] initWithString:@"3:1" attributes:nil] autorelease];
			[attStr drawAtPoint:NSMakePoint(loc.x - [attStr size].width / 2, loc.y - [attStr size].height / 2)];
		}
		*/
	}

}

-(void) highlightDragPart:(NSRect)inRect	{
	[[NSColor redColor] set];
//	NSRect tmpRect;
	NSBezierPath* tmpPath;
	if (vertexToHighlight)	{
		tmpPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect([vertexToHighlight location].x - vertexHighlightSize.width / 2, [vertexToHighlight location].y - vertexHighlightSize.height / 2, vertexHighlightSize.width, vertexHighlightSize.height)];
		[tmpPath setLineWidth:2];
		[tmpPath stroke];
		//tmpRect = NSMakeRect([vertexToHighlight location].x - vertexHighlightSize.width / 2, [vertexToHighlight location].y - vertexHighlightSize.height / 2, vertexHighlightSize.width, vertexHighlightSize.height);
//		[[NSBezierPath bezierPathWithOvalInRect:tmpRect] stroke];
	}
	else if (edgeToHighlight)	{
		tmpPath = [NSBezierPath bezierPath];
		[tmpPath moveToPoint:[(Vertex*)[[edgeToHighlight vertices] objectAtIndex:0] location]];
		[tmpPath lineToPoint:[(Vertex*)[[edgeToHighlight vertices] objectAtIndex:1] location]];
		[tmpPath setLineWidth:highlightWidth];
		[tmpPath stroke];
	
	} else if (hexToHighlight)	{
		tmpPath = [hexToHighlight bezierPath];
		[[[NSColor redColor] colorWithAlphaComponent:0.5] set];

		[tmpPath fill];
//		[tmpPath setLineWidth:highlightWidth];
//		[tmpPath stroke];
	}

}

-(void) drawRobber:(NSRect)inRect	{
//	NSLog(@"DRAWING ROBBER");
	if (robberIsMoving)
		return;
	int i;
	BoardHexagon* hex = nil;
	NSArray* hexagons = [theBoard tiles];
	for (i = 0; i < [hexagons count]; i++)	{
		if ([[hexagons objectAtIndex:i] robber])
			hex = [hexagons objectAtIndex:i];
	}
	NSImage* rImage = [NSImage imageNamed:@"robberImage.png"];
//	[rImage autorelease];
	if (NSContainsRect([hex bounds], robberRect) == NO)	{
//		NSLog(@"CHANGING ROBBER RECT, FROM %@", NSStringFromRect(robberRect));
		robberRect.origin.x = [hex bounds].origin.x + ([hex bounds].size.width - ROBBER_SIZE.width) / 2;
		robberRect.origin.y = [hex bounds].origin.y + ([hex bounds].size.height / 10);
		
		robberOriginPercentOfFrame.x = robberRect.origin.x / [self frame].size.width;
		robberOriginPercentOfFrame.y = robberRect.origin.y / [self frame].size.height;
	}
//	NSLog(@"ROBBER RECT = %@", NSStringFromRect(robberRect));
//	NSLog(@"image = %@", rImage);
	robberRect.origin.x = (int)robberRect.origin.x;
	robberRect.origin.y = (int)robberRect.origin.y;
	[rImage drawInRect:robberRect fromRect:NSMakeRect(0, 0, [rImage size].width, [rImage size].height) operation:NSCompositeSourceOver fraction:1.0];

}

//-(NSImage*) setBoardImage
/*
-(void) highlightDragPart	{
	[[NSColor redColor] set];
	NSRect tmpRect;
	NSBezierPath* tmpPath;
	if (vertexToHighlight)	{
		tmpRect = NSMakeRect([vertexToHighlight location].x - vertexHighlightSize.width / 2, [vertexToHighlight location].y - vertexHighlightSize.height / 2, vertexHighlightSize.width, vertexHighlightSize.height);
		[[NSBezierPath bezierPathWithOvalInRect:tmpRect] stroke];
	}
	else if (edgeToHighlight)	{
		tmpPath = [NSBezierPath bezierPath];
		[tmpPath moveToPoint:[(Vertex*)[[edgeToHighlight vertices] objectAtIndex:0] location]];
		[tmpPath lineToPoint:[(Vertex*)[[edgeToHighlight vertices] objectAtIndex:1] location]];
		[tmpPath setLineWidth:highlightWidth];
		[tmpPath stroke];
	
	} else if (hexToHighlight)	{
		tmpPath = [hexToHighlight bezierPath];
		[tmpPath setLineWidth:highlightWidth];
		[tmpPath stroke];
	}

}*/


/*
-(void) buildBoard	{
	myHexagons = [[NSMutableArray alloc] init];
	
}
*/
/*
-(void) calculateLayout:(NSPoint[54])	{
	
}
*/
//-(void) buildBoard	{
/*
-(NSArray*) boardVerticesForRect:(NSRect)r	{
	NSMutableArray* arr = [NSMutableArray array];
}*/

-(NSArray*) oldhexagonsForRect:(NSRect)r	{
//	PP;
	NSMutableArray* hexagons = [NSMutableArray array];
//	hexagons = [[NSMutableArray alloc] init];
	float w = (r.size.width) / 4;
	float th = (r.size.height) / 5;
	NSSize sz = NSMakeSize(w, th);
	NSPoint center = NSMakePoint(r.origin.x + (r.size.width / 2.0), r.origin.y +  (r.size.height / 2.0));
	float col1x = center.x - 1.5 * sz.width;
	float col2x = center.x - 0.75 * sz.width;
	float col3x = center.x;
	float col4x = center.x + 0.75* sz.width;
	float col5x = center.x + 1.5 * sz.width;
	
	
	float h;
	int i, j;
	h = r.origin.y + sz.height / 2 + 20;
	for (i = 0; i < 5; i++)	{
		[hexagons addObject:[Hexagon hexagonWithCenter:NSMakePoint(col3x, h) size:sz]];
		h += sz.height;
	}
	h -= sz.height;
	h -= sz.height / 2;
	for	(i = 0; i < 4; i++)	{
//		[[self hexagonWithCenter:NSMakePoint(col2x, h) size:sz] stroke];
//		[[self hexagonWithCenter:NSMakePoint(col4x, h) size:sz] stroke];
		[hexagons addObject:[Hexagon hexagonWithCenter:NSMakePoint(col2x, h) size:sz]];
		[hexagons addObject:[Hexagon hexagonWithCenter:NSMakePoint(col4x, h) size:sz]];

		h -= sz.height;
	}
	h += sz.height;
	h += sz.height / 2;
	
	for (i = 0; i < 3; i++)	{
//		[[self hexagonWithCenter:NSMakePoint(col1x, h) size:sz] stroke];
//		[[self hexagonWithCenter:NSMakePoint(col5x, h) size:sz] stroke];
		[hexagons addObject:[Hexagon hexagonWithCenter:NSMakePoint(col1x, h) size:sz]];
		[hexagons addObject:[Hexagon hexagonWithCenter:NSMakePoint(col5x, h) size:sz]];

		h += sz.height;
	}
	
	[hexagons sortUsingSelector:@selector(compareByCenter:)];
//	NSLog(@"got hexagons");
	return hexagons;

}
-(void) createBoard	{
	[self setBoard:[[Board alloc] init]];

//	[rbv display];
//	[theBoard createBoard];
}




-(Vertex*) closestVertexToPoint:(NSPoint)p	{
	int i;
	NSPoint q;
	NSArray* theVertices = [theBoard tileIntersections];
	q = [(Vertex*)[theVertices objectAtIndex:0] location];
	float minDist = (q.x - p.x) * (q.x - p.x) + (q.y - p.y) * (q.y - p.y);
	Vertex* closestVertex = [theVertices objectAtIndex:0];
	float dist;
	for (i = 1; i < [theVertices count]; i++)	{
		q = [(Vertex*)[theVertices objectAtIndex:i] location];
		dist = (q.x - p.x) * (q.x - p.x) + (q.y - p.y) * (q.y - p.y);
		if (dist < minDist)	{
			minDist = dist;
			closestVertex = [theVertices objectAtIndex:i];
		}
	}
	return closestVertex;
}

//-(BOOL) setPointToHighlightForDragLocation:(NSPoint)p	{
-(Vertex*) vertexForLocation:(NSPoint)p	{
	int i;
	NSPoint vLoc;
	NSArray* theVertices = [theBoard tileIntersections];
	vLoc = [(Vertex*)[theVertices objectAtIndex:0] location];
	float minDist = (vLoc.x - p.x) * (vLoc.x - p.x) + (vLoc.y - p.y) * (vLoc.y - p.y);
	int minIndex = 0;
	for (i = 1; i < [theVertices count]; i++)	{
		vLoc = [(Vertex*)[theVertices objectAtIndex:i] location];
		if ((vLoc.x - p.x) * (vLoc.x - p.x) + (vLoc.y - p.y) * (vLoc.y - p.y) < minDist)	{
			minDist = (vLoc.x - p.x) * (vLoc.x - p.x) + (vLoc.y - p.y) * (vLoc.y - p.y);
			minIndex = i;
		}
	}
	
	return [theVertices objectAtIndex:minIndex];
}

-(BOOL) setVertexToHighlightForDragLocation:(NSPoint)p		{
	int i;
//	NSPoint arr[7];
	NSPoint v;
	NSArray* theVertices = [theBoard tileIntersections];
//	for (i = 0; i < [myHexagons count]; i++)	{
	for (i = 0; i < [theVertices count]; i++)	{
	//	[[myHexagons objectAtIndex:i] copyVertices:arr];
	//	for (j = 0; j < 7; j++)	{
	//		v = arr[j];
			v = [(Vertex*)[theVertices objectAtIndex:i] location];
			if (((p.x - v.x) * (p.x - v.x) + (p.y - v.y) * (p.y - v.y)) <= 144)	{
					vertexToHighlight = [theVertices objectAtIndex:i];
					return YES;
			}

//				pointToHighlight = v;
//				if ([[GameController gameController] canDragSettlementTo:[theVertices objectAtIndex:i]])	{
//				}
//			}
		
	}
	vertexToHighlight = nil;
//	pointToHighlight = nilPoint;
	return NO;
	
}

-(BOOL) setHexToHighlightForDragLocation:(NSPoint)p	{
	hexToHighlight = [self hexagonForLocation:p];
//	NSLog(@"hexToHighlight = %@", hexToHighlight);
	if (hexToHighlight == nil)	{
		return NO;
	}
	
	return YES;
}

-(BOOL) setEdgeToHighlightForDragLocation:(NSPoint)p	{
	Vertex* v1 = [self closestVertexToPoint:p];
	NSArray* neighbors = [v1 neighbors];
	Vertex* v2 = [neighbors objectAtIndex:0];
	
	NSPoint l1 = [v1 location];
	NSPoint l2 = [v2 location]; 
	int i;
	float minDist = (p.x - l2.x) * (p.x - l2.x) + (p.y - l2.y) * (p.y - l2.y);
	for (i = 0; i < [neighbors count]; i++)	{
		l2 = [(Vertex*)[neighbors objectAtIndex:i] location];
		if ((p.x - l2.x) * (p.x - l2.x) + (p.y - l2.y) * (p.y - l2.y) < minDist)	{
			minDist = (p.x - l2.x) * (p.x - l2.x) + (p.y - l2.y) * (p.y - l2.y);
			v2 = [neighbors objectAtIndex:i];
		}
	}
	
	l2 = [v2 location];
	float triangularDistance = sqrt((p.x - l1.x) * (p.x - l1.x) + (p.y - l1.y) * (p.y - l1.y)) + sqrt((p.x - l2.x) * (p.x - l2.x)  + (p.y - l2.y) * (p.y - l2.y));
	float lineDistance = sqrt( (l1.x - l2.x) * (l1.x - l2.x) + (l1.y - l2.y) * (l1.y - l2.y));
//	NSPoint c = 
//	minDist = sqrt(minDist);
//	NSLog(@"p = %@, v1 = %@, v2 = %@, dist = %f", NSStringFromPoint(p), v1, v2, lineDistance);
	if (triangularDistance < 1.10 * lineDistance)	{
	//	if ([[GameController gameController] canDragRoadTo:[v1 edgeForNeighbor:v2]])	{
		edgeToHighlight = [v1 edgeForNeighbor:v2];
//		lineToHighlight[0] = l1;
//		lineToHighlight[1] = l2;
		return YES;
//	}
//		else
//			edgeToHighlight = nil;
	}
	edgeToHighlight = nil;
//	lineToHighlight[0] = nilPoint;
//	lineToHighlight = 0;
	return NO;
}


/*
-(NSPoint) isValidDropLocation:(NSPoint)p	{
	
	return nilPoint;
	
	int i, j;
	NSPoint arr[7];
	NSPoint v;
	for (i = 0; i < [myHexagons count]; i++)	{
		[[myHexagons objectAtIndex:i] copyVertices:arr];
		for (j = 0; j < 7; j++)	{
			v = arr[j];
	//		NSLog(@"testing %@", NSStringFromPoint(v));
			if ( ( (p.x - v.x) * (p.x - v.x) + (p.y - v.y) * (p.y - v.y)) <= 144)
				return v;
		}
	}
	
	return nilPoint;
}*/


#pragma mark DRAGGING DESTINATION METHODS

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender	{
//	PP;
	NSPoint p = [sender draggingLocation];
	p = [self convertPoint:p fromView:[[self window] contentView]];
//	p.x -= [self frame].origin.x;
//	p.y -= [self frame].origin.y;
	if ([[[sender draggingPasteboard] types] indexOfObject:@"CATAN_BOARD_VERTEX_TYPE"] != NSNotFound)
		return [self handleVertexDrag:sender location:p];
	else if ([[[sender draggingPasteboard] types] indexOfObject:@"CATAN_BOARD_EDGE_TYPE"] != NSNotFound)
		return [self handleEdgeDrag:sender location:p];
	else if ([[[sender draggingPasteboard] types] indexOfObject:@"CATAN_ROBBER_TYPE"] != NSNotFound)
		return [self handleRobberDrag:sender location:p];
		
	return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender	{
//	PP;
//	NSLog(@"%@", NSStringFromPoint([sender draggingLocation]));
	return [self draggingEntered:sender];
	/*
	NSPoint p;

	
	p = [sender draggingLocation];
	p.x -= [self frame].origin.x;
	p.y -= [self frame].origin.y;
	
	NSPoint q = [self isValidDropLocation:p];
//	if ([self isValidDropLocation:p] != nilPoint)	{
	if (q.x > -1)	{
		pointToHighlight = q;
		[self setNeedsDisplay:YES];
		return NSDragOperationCopy;
	}
	
	pointToHighlight = nilPoint;
	[self setNeedsDisplay:YES];
	return NSDragOperationNone;*/
}

-(void) draggingExited:(id <NSDraggingInfo>)sender	{
	vertexToHighlight = nil;
	edgeToHighlight = nil;
	hexToHighlight = nil;
	[self setNeedsDisplay:YES];
}	



-(NSDragOperation) handleRobberDrag:(id <NSDraggingInfo>)sender location:(NSPoint)p	{
//	NSLog(@"handling robber drag");
//	NSLog(@"hexToHighlight = %@", hexToHighlight);
//	[self setHexT
	id previouslyExists = hexToHighlight;
	BOOL flag = [self setHexToHighlightForDragLocation:p];
	if (hexToHighlight && [hexToHighlight robber] == YES)	{
		hexToHighlight = nil;
		flag = NO;
	}
	
	if (previouslyExists != hexToHighlight)	{
		[self setNeedsDisplay:YES];
//		if (hexToHighlight)
//			[self setNeedsDisplayInRect:[hexToHighlight bounds]];
//		if (previouslyExists)
//			[self setNeedsDisplayInRect:[previouslyExists bounds]];
	}
	
	if (flag)
		return NSDragOperationCopy;
	return NSDragOperationNone;
}
-(NSDragOperation) handleEdgeDrag:(id <NSDraggingInfo>)sender location:(NSPoint)p	{
	Edge* previous = edgeToHighlight;
	BOOL flag = [self setEdgeToHighlightForDragLocation:p];
//	PP;
//	NSLog(@"flag = %d", flag);
	if (edgeToHighlight && [[GameController gameController] canDragRoadTo:edgeToHighlight] == NO)	{
		edgeToHighlight = nil;
		flag = NO;
	}
	if (previous != edgeToHighlight)	{
		[self setNeedsDisplay:YES];
//		if (edgeToHighlight)
//			[self setNeedsDisplayInRect:[edgeToHighlight bounds]];
//		if (previous)
//			[self setNeedsDisplayInRect:[previous bounds]];

	}
//		[self setNeedsDisplay:YES];
	
	if (flag)
		return NSDragOperationCopy;
	return NSDragOperationNone;
}

-(NSDragOperation) handleVertexDrag:(id <NSDraggingInfo>)sender location:(NSPoint)p	{
//	PP;
//	BOOL flag = [self setPointToHighlightForDragLocation:p];
	id previousItem = vertexToHighlight;
	BOOL flag = [self setVertexToHighlightForDragLocation:p];
	if (vertexToHighlight)	{
		if ([[[sender draggingPasteboard] stringForType:@"CATAN_BOARD_VERTEX_TYPE"] isEqualToString:@"Settlement"] &&
			[[GameController gameController] canDragSettlementTo:vertexToHighlight] == NO)	{
				vertexToHighlight = nil;
				flag = NO;
			}
		else if ([[[sender draggingPasteboard] stringForType:@"CATAN_BOARD_VERTEX_TYPE"] isEqualToString:@"City"] &&
			[[GameController gameController] canDragCityTo:vertexToHighlight] == NO)	{
				vertexToHighlight = nil;
				flag = NO;
		}
			
	}
	
	
	if (previousItem != vertexToHighlight)	{
		[self setNeedsDisplay:YES];
	/*
		int i;
		NSRect dispRect = NSMakeRect(0, 0, 0, 0);
		NSArray* tmpArr;
		if (vertexToHighlight)	{
			tmpArr = [vertexToHighlight hexagons];
			for (i = 0; i < [tmpArr count]; i++)	{
				[self setNeedsDisplayInRect:[[tmpArr objectAtIndex:i] bounds]];
				//dispRect = NSUnionRect(dispRect, [[tmpArr objectAtIndex:i] bounds]);
			}
		}
		if (previousItem)	{
			tmpArr = [previousItem hexagons];
			for (i = 0; i < [tmpArr count]; i++)	{
				[self setNeedsDisplayInRect:[[tmpArr objectAtIndex:i] bounds]];
//				dispRect = NSUnionRect(dispRect, [[tmpArr objectAtIndex:i] bounds]);
			}	
		}
		[self setNeedsDisplayInRect:dispRect];*/
	}
	
	if (flag)
		return NSDragOperationCopy;
	return NSDragOperationNone;
	
/*
	NSPoint q = [self isValidDropLocation:p];
	if (q.x > -1)	{
	//if ([self isValidDropLocation:p] != nilPoint)	{
		pointToHighlight = q;
		[self setNeedsDisplay:YES];
		return NSDragOperationCopy;
	}
	pointToHighlight = nilPoint;
	[self setNeedsDisplay:YES];
	return NSDragOperationNone;*/
}



/*
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender	{
	PP;
	if (vertexToHighlight)	{
	}
	return YES;
}

*/

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender	{
	PP;
//	if ([[sender draggingPasteboard] stringForType:@"CATAN_BOARD_VERTEX_TYPE"])
	NSArray* blah;
	if (vertexToHighlight)	{
		blah = [theBoard tileIntersections];
		[[GameController gameController] addItem:[[sender draggingPasteboard] stringForType:@"CATAN_BOARD_VERTEX_TYPE"] toVertex:[NSNumber numberWithInt:[blah indexOfObject:vertexToHighlight]]];
//		if ([[[sender draggingPasteboard] stringForType:@"CATAN_BOARD_VERTEX_TYPE"] isEqualToString:@"City"])
//			[vertexToHighlight setItem:[[[CityToken alloc] initWithOwner:[[GameController gameController] localPlayer]] autorelease]];
//		else if ([[[sender draggingPasteboard] stringForType:@"CATAN_BOARD_VERTEX_TYPE"] isEqualToString:@"Settlement"])
//			[vertexToHighlight setItem:[[[SettlementToken alloc] initWithOwner:[[GameController gameController] localPlayer]] autorelease]];
			
	//	[vertexToHighlight setItem:[[sender draggingPasteboard] stringForType:@"CATAN_BOARD_VERTEX_TYPE"]];
//		[[GameController gameController] addVertexItem:vertexToHighlight];
	}
	else if (edgeToHighlight)	{
		blah = [theBoard tileEdges];
		[[GameController gameController] addRoadToEdge:[NSNumber numberWithInt:[blah indexOfObject:edgeToHighlight]]];
//		NSLog(@"setting road token");
//		[edgeToHighlight setItem:@"Road"];
//		[edgeToHighlight setItem:[[[RoadToken alloc] initWithOwner:[[GameController gameController] localPlayer]] autorelease]];
		//[edgeToHighlight setItem:[[sender draggingPasteboard] stringForType:@"CATAN_BOARD_EDGE_TYPE"]];
//		[[GameController gameController] addEdgeItem:edgeToHighlight];
	}
	else if (hexToHighlight)	{
	//	int i;
	//	for (i = 0; i < [theHexagons count]; i++)	{
	//		[[theHexagons objectAtIndex:i] setRobber:NO];
	//	}
	//	[hexToHighlight setRobber:YES];
		blah = [theBoard tiles];
		[[GameController gameController] moveRobberToTile:[NSNumber numberWithInt:[blah indexOfObject:hexToHighlight]]];// rect:NSStringFromRect(robberRect)];
//		[theBoard moveRobberToTile:hexToHighlight];
//		[[GameController gameController] robberMoved];
		NSPoint p = [self convertPoint:[sender draggedImageLocation] fromView:[[self window] contentView]];
		robberRect.origin.x = p.x;
		robberRect.origin.y = p.y;

		robberOriginPercentOfFrame.x = robberRect.origin.x / [self frame].size.width;
		robberOriginPercentOfFrame.y = robberRect.origin.y / [self frame].size.height;

		robberIsMoving = NO;
	}
	vertexToHighlight = nil;
	edgeToHighlight = nil;
	hexToHighlight = nil;
//	NSLog(@"DRAG ALMOST PERFORMED");
	[self setNeedsDisplay:YES];
//	if ([[GameController gameController] phase] == 0)
//		[[GameController gameController] setPhase:1];
	return YES;
}




/*
-(void) mouseDown:(NSEvent*)event	{
	[[[self window] contentView] step];
}*/


#pragma mark DRAGGING SOURCE METHODS
-(void) mouseDown:(NSEvent*)event	{
	NSPoint p = [event locationInWindow];
	p = [self convertPoint:p fromView:[[self window] contentView]];
	if (NSMouseInRect(p, robberRect, NO) == NO)
		return;
//	NSLog(@"%@ (%@ - window)", NSStringFromPoint(p),  NSStringFromPoint([event locationInWindow]));

	if ([[GameController gameController] canMoveRobber] == NO)
		return;
	
//	p.x -= [self frame].origin.x;
//	p.y -= [self frame].origin.y;
	
	if ([[self hexagonForLocation:p] robber])	{
		robberIsMoving = YES;
		NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
		[pboard declareTypes:[NSArray arrayWithObject:@"CATAN_ROBBER_TYPE"] owner:self];
		[pboard setString:@"Robber" forType:@"CATAN_ROBBER_TYPE"];
		NSImage* base = [NSImage imageNamed:@"robberImage.png"];
//		[base autorelease];
		NSImage* image = [[[NSImage alloc] initWithSize:ROBBER_SIZE] autorelease];
		[image lockFocus];
		[base drawInRect:NSMakeRect(0, 0, ROBBER_SIZE.width, ROBBER_SIZE.height) fromRect:NSMakeRect(0, 0, [base size].width, [base size].height) operation:NSCompositeSourceOver fraction:0.7];
		[image unlockFocus];
	//	[[[NSColor blackColor] colorWithAlphaComponent:0.65] set];
	//	[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, 0, 16, 16)] fill];
	//	[image unlockFocus];
		[self setNeedsDisplay:YES];
//		p = NSMakePoint(0, 0);
		p.x -= 8;
		p.y -= 8;
		[self dragImage:image at:p offset:NSMakeSize(0, 0) event:event pasteboard:pboard source:self slideBack:YES];
	}
}
//- (void)dragImage:(NSImage *)anImage at:(NSPoint)imageLoc offset:(NSSize)mouseOffset event:(NSEvent *)theEvent pasteboard:(NSPasteboard *)pboard source:(id)sourceObject slideBack:(BOOL)slideBack
-(BoardHexagon*) hexagonForLocation:(NSPoint)p	{
	int i;
//	int count = 0;
//	int index = 0;
	Vertex* v = [self vertexForLocation:p];
	NSArray* vHexes = [v hexagons];
	NSPoint left;
	NSPoint right;
	NSPoint top;
	NSPoint bottom;
	BoardHexagon* hex;
	NSMutableArray* potential = [NSMutableArray array];
	for (i = 0; i < [vHexes count]; i++)	{
		hex = [vHexes objectAtIndex:i];
		left = [(Vertex*)[[hex vertices] objectAtIndex:0] location];
		right = [(Vertex*)[[hex vertices] objectAtIndex:3] location];
		top = [(Vertex*)[[hex vertices] objectAtIndex:1] location];
		bottom = [(Vertex*)[[hex vertices] objectAtIndex:4] location];
		if (p.x > left.x && p.x < right.x && p.y < top.y && p.y > bottom.y)	{
			[potential addObject:hex];
			//return hex;
		//	count++;
		//	index = i;
		}			
	}
	
//	NSLog(@"potential = %d", [potential count]);
	if ([potential count] == 0)
		return nil;
	else if ([potential count] == 1)
		return [potential objectAtIndex:0];
		
	else	{
		float min = -1;
		int index = -1;
		float val;
		int j;
		NSPoint q;
		for (i = 0; i < [potential count]; i++)	{
			val = 0;
			for (j = 0; j < [[[potential objectAtIndex:i] vertices] count]; j++)	{
				q = [(Vertex*) [[[potential objectAtIndex:i] vertices] objectAtIndex:j] location];
				val += ((p.x - q.x) * (p.x - q.x) + (p.y - q.y) * (p.y - q.y));
			}
			if (val < min || min < 0)		{
				min = val;
				index = i;
			}
		}
		if (index > -1)
			return [potential objectAtIndex:index];
//		else
//			NSLog(@"index = %d", index);
	}
//	return nil;
//	NSLog(@"%s returning nil", __FUNCTION__);
	return nil;
}


- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation	{
	robberIsMoving = NO;
	[self setNeedsDisplay:YES];
}



#pragma mark OLD METHODS
- (void)olddrawRect:(NSRect)rect	{
//	PP;
	NSArray* theVertices;
	NSArray* theHexagons;
	NSArray* edges;
	
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:[self bounds]];
	[[NSColor blackColor] set];
	[NSBezierPath strokeRect:[self bounds]];
	

//	return;

		
	[self drawBoard];
	
	[[NSColor redColor] set];
//	if (pointToHighlight.x > -1)	{
	if (vertexToHighlight)	{
		NSRect r;
	//	r.origin.x = pointToHighlight.x - 5;
	//	r.origin.y = pointToHighlight.y - 5;
		r.origin.x = [vertexToHighlight location].x - 6;
		r.origin.y = [vertexToHighlight location].y - 6;
		r.size.width = 12;
		r.size.height = 12;
		[[NSBezierPath bezierPathWithOvalInRect:r] stroke];
	}
	
//	else if (lineToHighlight[0].x > -1)	{
	else if (edgeToHighlight)	{
	//	NSLog(@"drawing edge");
		NSArray* verts = [edgeToHighlight vertices];
		NSBezierPath* line = [NSBezierPath bezierPath];
//		[line moveToPoint:lineToHighlight[0]];
//		[line lineToPoint:lineToHighlight[1]];
		[line moveToPoint:[(Vertex*)[verts objectAtIndex:0] location]];
		[line lineToPoint:[(Vertex*)[verts objectAtIndex:1] location]];
		[line setLineWidth:3];
	//	NSLog(@"%@", line);
		[line stroke];
//		[NSBezierPath strokeLineFromPoint:lineToHighlight[0] toPoint:lineToHighlight[1]];
	}
	
	
	int i;
	NSImage* image;
	NSRect vRect;
	NSPoint vLoc;
	Vertex* theVert;
	PurchaseTableView* ptv = [[[PurchaseTableView alloc] init] autorelease];
	for (i = 0; i < [theVertices count]; i++)	{
		theVert = [theVertices objectAtIndex:i];
		if ([theVert item] != nil)	{	
			vLoc = [theVert location];
			vRect = NSMakeRect(vLoc.x - 9, vLoc.y - 9, 18, 18);
			if ([[theVert item] isEqualToString:@"Settlement"])
				[[ptv settlementImage] drawInRect:vRect fromRect:NSMakeRect(0, 0, 18, 18) operation:NSCompositeSourceOver fraction:1.0];
			else if ([[theVert item] isEqualToString:@"City"])
				[[ptv cityImage] drawInRect:vRect fromRect:NSMakeRect(0, 0, 18, 18) operation:NSCompositeSourceOver fraction:1.0];
		}
//		[[NSString stringWithFormat:@"%d", i] drawAtPoint:[theVert location] withAttributes:nil];
	}
	
	Edge* theEdge;
	NSPoint p1;
	NSPoint p2;
	NSBezierPath* roadPath;
	for (i = 0; i < [edges count]; i++)	{
		theEdge = [edges objectAtIndex:i];
		if ([theEdge item] != nil)	{
			roadPath = [NSBezierPath bezierPath];
			[roadPath setLineWidth:5];
			p1 = [(Vertex*)[[theEdge vertices] objectAtIndex:0] location];
			p2 = [(Vertex*)[[theEdge vertices] objectAtIndex:1] location];
			if (p1.x > p2.x + 1)	{
				p1.x -= 5;
				p2.x += 5;
			}
			else if (p1.x < p2.y - 1)	{
				p1.x += 5;
				p2.x -= 5;
			}
			
			if (p1.y > p2.y + 1)	{
				p1.y -= 5;
				p2.y += 5;
			}
			else if (p1.y < p2.y - 1)	{
				p1.y += 5;
				p2.y -= 5;
			}
			[roadPath moveToPoint:p1];
			[roadPath lineToPoint:p2];
			[[NSColor blueColor] set];
			[roadPath stroke];
		}
	}
	
//	NSDictionary* tmpAtts = [NSD
	NSAttributedString* str1;
	NSAttributedString* str2;
	BoardHexagon* hex;
	float height;
	float yMarg;
	float xMarg;
	NSDictionary* tmpAtts;
	for (i =0; i < [theHexagons count]; i++)	{
		
		hex = [theHexagons objectAtIndex:i];

		if ([hex diceValue] == 6 || [hex diceValue] == 8)
			tmpAtts = [NSDictionary dictionaryWithObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
		else
			tmpAtts = nil;
//		NSLog(@"hex size = %@", NSStringFromSize(NSMakeSize([hex width], [hex height])));
		str1 = [[[NSAttributedString alloc] initWithString:[hex resource] attributes:nil] autorelease];
		str2 = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", [hex diceValue]] attributes:tmpAtts] autorelease];
		height = [str1 size].height + [str2 size].height;
//		xMarg = ([hex width] - [str1 size].width) / 2.0;
//		yMarg = ([hex height] - height) / 2.0;
		[str1 drawAtPoint:NSMakePoint([hex center].x - ([str1 size].width / 2.0), [hex center].y - (height / 2.0))];
//		xMarg = ([hex width] - [str2 size].width) / 2.0;
		[str2 drawAtPoint:NSMakePoint([hex center].x - ([str2 size].width / 2.0), [hex center].y - (height / 2.0) + [str1 size].height)];
	//	[[NSString stringWithFormat:@"%d", i] drawAtPoint:[(BoardHexagon*)[theHexagons objectAtIndex:i] center] withAttributes:nil];
		if ([hex robber] && robberIsMoving == NO)	{
			[[NSColor blackColor] set];
			NSBezierPath* robberPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect([hex center].x - 8, [hex center].y - (8 + height / 2), 16, 16)];
			[robberPath fill];
		}	
	
	}
	
	
	if (hexToHighlight)	{
		[[NSColor redColor] set];
		NSBezierPath* path = [hexToHighlight bezierPath];
		[path setLineWidth:4];
		[path stroke];
//		[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect([hexToHighlight center].x, [hexToHighlight center].y, 12, 12)] fill];
	}
	
}

-(void) oldDrawBoard	{
	int i;
	[[NSColor blueColor] set];
//	float whiteVal = 0;
//	NSColor* tmpColor = [NSColor colorWithCalibratedWhite:whiteVal alpha:1.0];
	
	
	NSArray* myHexagons = [self hexagonsForRect:[self bounds]];
	for (i = 0; i < [myHexagons count]; i++)	{
//		[tmpColor set];
		[[[myHexagons objectAtIndex:i] bezierPath] stroke];
//		whiteVal += 1.0 / [myHexagons count];
//		tmpColor = [NSColor colorWithCalibratedWhite:whiteVal alpha:1.0];
	}
}

-(void) newOlddrawBoard	{
    

	[[NSColor grayColor] set];
	int i, j;
	NSArray* theVertices;
	NSArray* tradeRoutes;
	
	NSArray* neighbors;
	for (i = 0; i < [theVertices count]; i++)	{
//		[[NSString stringWithFormat:@"%d", i] drawAtPoint:[(Vertex*)[theVertices objectAtIndex:i] location] withAttributes:nil];
//		[[NSColor redColor] set];
		neighbors = [[theVertices objectAtIndex:i] neighbors];
		for (j = 0; j < [neighbors count]; j++)	{
//			if ([[theVertices objectAtIndex:i] compare:[neighbors objectAtIndex:j]] == NSOrderedAscending)
				[NSBezierPath strokeLineFromPoint:[(Vertex*)[theVertices objectAtIndex:i] location]
					toPoint:[(Vertex*)[neighbors objectAtIndex:j] location]];
		}
	}
	
	NSPoint trLoc;
	NSPoint trv1;
	NSPoint trv2;
	NSPoint c1;
	NSPoint c2;
	TradeRoute* tr;
	NSSize trSize = [self tradeRouteSize];
	NSRect trRect;
	NSAttributedString* ratioString;
	NSAttributedString* resString;
	
	NSBezierPath* trPath1;
	NSBezierPath* trPath2;
	CGFloat dashes[2] = {3.0, 3.0};
	for (i = 0; i < [tradeRoutes count]; i++)	{
		tr = [tradeRoutes objectAtIndex:i];
		trLoc = [tr location];
		trv1 = [(Vertex*)[[tr vertices] objectAtIndex:0] location];
		trv2 = [(Vertex*)[[tr vertices] objectAtIndex:1] location];
		c1 = NSMakePoint( (trv1.x + trv2.x) / 2.0, (trv1.y + trv2.y) / 2.0);
		trPath1 = [NSBezierPath bezierPath];
		[trPath1 moveToPoint:trv1];
//		[trPath1 lineToPoint:trLoc];
		[trPath1 curveToPoint:trLoc controlPoint1:c1 controlPoint2:trLoc];
		trPath2 = [NSBezierPath bezierPath];
		[trPath2 moveToPoint:trv2];
//		[trPath2 lineToPoint:trLoc];
		[trPath2 curveToPoint:trLoc controlPoint1:c1 controlPoint2:trLoc];
		[[NSColor redColor] set];
		[trPath1 setLineDash:dashes count:2 phase:2.0];
		[trPath2 setLineDash:dashes count:2 phase:2.0];
		if ([(Vertex*)[[tr vertices] objectAtIndex:0] item] != nil)	
			[[NSColor greenColor] set];
		else
			[[NSColor redColor] set];
		[trPath1 stroke];
		if ([(Vertex*)[[tr vertices] objectAtIndex:1] item] != nil)	
			[[NSColor greenColor] set];
		else
			[[NSColor redColor] set];
		[trPath2 stroke];
//		[NSBezierPath strokeLineFromPoint:trv1 toPoint:trLoc];
//		[NSBezierPath strokeLineFromPoint:trv2 toPoint:trLoc];
		trRect = NSMakeRect(trLoc.x - trSize.width / 2, trLoc.y - trSize.height / 2, trSize.width, trSize.height);
		NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect:trRect];
		[[NSColor whiteColor] set];
		[path fill];
		[[NSColor blackColor] set];
		[path stroke];
		
		if ([tr resource])	{
			resString = [[[NSAttributedString alloc] initWithString:[tr resource] attributes:nil] autorelease];
			ratioString = [[[NSAttributedString alloc] initWithString:@"2:1" attributes:nil] autorelease];
		}
		else	{
			resString = nil;
			ratioString = [[[NSAttributedString alloc] initWithString:@"3:1" attributes:nil] autorelease];
		}
		
		float trTextHeight = [resString size].height + [ratioString size].height;
		[resString drawAtPoint:NSMakePoint(trLoc.x - [resString size].width / 2, trLoc.y - trTextHeight / 2)];
		[ratioString drawAtPoint:NSMakePoint(trLoc.x - [ratioString size].width / 2, trLoc.y )];
//		if ([[tradeRoutes objectAtIndex:i] resource])
//			[[NSString stringWithFormat:@"2:1, %@", [tr resource]] drawAtPoint:trLoc withAttributes:nil];
//		else
//			[@"3:1" drawAtPoint:trLoc withAttributes:nil];
//		[[NSColor greenColor] set];
//		[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(trLoc.x - 2, trLoc.y - 2, 4, 4)] fill];
	}
/*
		height = [str1 size].height + [str2 size].height;
//		xMarg = ([hex width] - [str1 size].width) / 2.0;
//		yMarg = ([hex height] - height) / 2.0;
		[str1 drawAtPoint:NSMakePoint([hex center].x - ([str1 size].width / 2.0), [hex center].y - (height / 2.0))];
//		xMarg = ([hex width] - [str2 size].width) / 2.0;
		[str2 drawAtPoint:NSMakePoint([hex center].x - ([str2 size].width / 2.0), [hex center].y - (height / 2.0) + [str1 size].height)];
*/

}

-(void) oldcreateBoard	{
	PP;
	NSArray* theHexagons;
	NSArray* theVertices;
	NSArray* edges;
	NSArray* tradeRoutes;
	
	NSArray* hexagons  = [self hexagonsForRect:NSMakeRect(0, 0, 500, 500)];
	NSMutableArray* newVerts = [NSMutableArray array];
	NSMutableArray* newEdges = [NSMutableArray array];
	NSMutableArray* newHexes = [NSMutableArray array];
	int i, j, k;
	NSPoint tmpVerts[6];
	NSPoint tmpVert;
	NSPoint vertLoc;
	NSMutableArray* hexVerts;
	Edge* newEdge;
	BoardHexagon* newHex;
	BOOL flag;
	for (i = 0; i < [hexagons count]; i++)	{
		hexVerts = [NSMutableArray array];
		[[hexagons objectAtIndex:i] copyVertices:tmpVerts];
		for (j = 0; j < 6; j++)	{
			tmpVert = tmpVerts[j];
			flag = NO;
			for (k = 0; k < [newVerts count] && flag == NO; k++)	{
				vertLoc = [(Vertex*)[newVerts objectAtIndex:k] location];
				if (vertLoc.x - 1 < tmpVert.x && vertLoc.x + 1 > tmpVert.x && 
					vertLoc.y - 1 < tmpVert.y && vertLoc.y + 1 > tmpVert.y)	{
					[hexVerts addObject:[newVerts objectAtIndex:k]];
					flag = YES;
				}
			}
			if (flag == NO)	{
				[hexVerts addObject:[Vertex vertexWithLocation:tmpVert]];
			}
		}
		
		newHex = [[[BoardHexagon alloc] init] autorelease];
		[newHex setTag:i + 1];
//		NSLog(@"hexagon %d, vertex count = %d", i, [hexVerts count]);
		for (j = 0; j < 5; j++)	{
			[[hexVerts objectAtIndex:j] addHexagon:newHex];
			[newHex addVertex:[hexVerts objectAtIndex:j]];
//			NSLog(@"\t%@", [hexVerts objectAtIndex:j]);
			newEdge = [[hexVerts objectAtIndex:j] addNeighbor:[hexVerts objectAtIndex:j + 1]];
			if (newEdge)
				[newEdges addObject:newEdge];
				
			[newHex addEdge:[[hexVerts objectAtIndex:j] edgeForNeighbor:[hexVerts objectAtIndex:j + 1]]];
	
			if ([newVerts indexOfObject:[hexVerts objectAtIndex:j]] == NSNotFound)
				[newVerts addObject:[hexVerts objectAtIndex:j]];
		}
//		NSLog(@"\t%@", [hexVerts objectAtIndex:5]);
		[newHex addVertex:[hexVerts objectAtIndex:5]];
		[[hexVerts objectAtIndex:5] addHexagon:newHex];
		newEdge = [[hexVerts objectAtIndex:5] addNeighbor:[hexVerts objectAtIndex:0]];
		
		if (newEdge)
			[newEdges addObject:newEdge];
		
		[newHex addEdge:[[hexVerts objectAtIndex:5] edgeForNeighbor:[hexVerts objectAtIndex:0]]];
		if ([newVerts indexOfObject:[hexVerts objectAtIndex:5]] == NSNotFound)
			[newVerts addObject:[hexVerts objectAtIndex:5]];
			
		[newHexes addObject:newHex];
	}
	
	[newVerts sortUsingSelector:@selector(compare:)];
	
	theVertices = [NSArray arrayWithArray:newVerts];
	[theVertices retain];
	for (i = 0; i < [theVertices count]; i++)
		[[theVertices objectAtIndex:i] setTag:i + 1];
		
	edges = [NSArray arrayWithArray:newEdges];
	[edges retain];
	
	[[newHexes objectAtIndex:0] setRobber:YES];
	theHexagons = [NSArray arrayWithArray:newHexes];
	[theHexagons retain];
	int diceValues[18] = {5, 2,  6,  3,  8, 10,  9, 12, 11, 4, 8, 10, 9,  4, 5,   6, 3, 11};
	int hexIndices[18] = {2, 5, 10, 15, 17, 18, 16, 13,  8, 3, 1,  4, 7, 12, 14, 11, 6, 9};
	NSMutableArray* resourceArray = [NSMutableArray arrayWithObjects:
		@"Grain", @"Grain", @"Grain", @"Grain", 
		@"Wood", @"Wood", @"Wood", @"Wood",
		@"Sheep", @"Sheep", @"Sheep", @"Sheep",
		@"Ore", @"Ore", @"Ore", 
		@"Brick", @"Brick", @"Brick",
		nil];
	[resourceArray shuffle];
	for (i = 0; i < 18; i++)	{
		[[theHexagons objectAtIndex:hexIndices[i]] setDiceValue:diceValues[i]];
		[[theHexagons objectAtIndex:hexIndices[i]] setResource:[resourceArray objectAtIndex:i]];
	}
	
	
	NSMutableArray* tmpRoutes = [NSMutableArray arrayWithObjects:[TradeRoute tradeRouteWithResource:nil], [TradeRoute tradeRouteWithResource:nil],
		[TradeRoute tradeRouteWithResource:nil], [TradeRoute tradeRouteWithResource:nil], 
		[TradeRoute tradeRouteWithResource:@"Wood"], [TradeRoute tradeRouteWithResource:@"Brick"], 
		[TradeRoute tradeRouteWithResource:@"Sheep"], [TradeRoute tradeRouteWithResource:@"Ore"],
		[TradeRoute tradeRouteWithResource:@"Grain"], nil];
	[tmpRoutes shuffle];
	tradeRoutes = [NSArray arrayWithArray:tmpRoutes];
	[tradeRoutes retain];
	//	(4, 5)    (11, 17), (29, 35), (46, 51)   (52, 53)            (48, 43), (30, 24) (12, 6)         (2, 3)

	int vertexTradeRouteIndices[18] = {4, 5, 11, 17, 29, 35, 46, 51, 52, 53, 48, 43, 30, 24, 12, 6, 2, 3};
	NSPoint tradeRouteOffsets[9] = {NSMakePoint(0, 0.75), NSMakePoint(0.75, 0.40), NSMakePoint(0.75, -0.40), NSMakePoint(0.75, -0.40),
		NSMakePoint(0, -0.75), NSMakePoint(-0.75, -0.40), NSMakePoint(-0.75, -0.40), NSMakePoint(-0.75, 0.40), NSMakePoint(0, 0.75)};
	Vertex* trV1;
	Vertex* trV2;
	for (i = 0; i < 9; i++)	{
		trV1 = [theVertices objectAtIndex:vertexTradeRouteIndices[2 * i]];
		trV2 = [theVertices objectAtIndex:vertexTradeRouteIndices[1 + 2 * i]];
		[trV1 setTradeRoute:[tradeRoutes objectAtIndex:i]];
		[trV2 setTradeRoute:[tradeRoutes objectAtIndex:i]];
		[[tradeRoutes objectAtIndex:i] addVertex:trV1];
		[[tradeRoutes objectAtIndex:i] addVertex:trV2];
		[[tradeRoutes objectAtIndex:i] setOffset:tradeRouteOffsets[i]];
	}
	
	
	[theVertices retain];
	[theHexagons retain];
	[edges retain];
	[tradeRoutes retain];
//	NSLog(@"created board, there's %d vertices", [theVertices count]);
//	NSLog(@"there are %d tradeRoutes, retainCount = %d", [tradeRoutes count], [tradeRoutes retainCount]);
//	NSLog(@"edge count = %d", [newEdges count]);
//	for (i = 0; i < [theVertices count]; i++)	{
//		NSLog(@"neighbor count = %d", [[[theVertices objectAtIndex:i] neighbors] count]);
//	}
}	


//-(void) buildHexagons	{

-(NSArray*) hexagonsForRect:(NSRect)rect	{
	return [[self allHexagonsForRect:rect] objectAtIndex:0];
}
-(NSArray*) waterHexagonsForRect:(NSRect)rect	{
	return [[self allHexagonsForRect:rect] objectAtIndex:1];
}
-(NSArray*) allHexagonsForRect:(NSRect)rect	{
	
//	NSLog(@"build");
	NSSize hexSize = NSMakeSize(rect.size.width / 5.5, rect.size.height / 7);
//	NSLog(@"building, size = %@", NSStringFromSize(hexSize));
	NSPoint center = NSMakePoint(NSMidX([self bounds]), NSMidY([self bounds]));
//	NSLog(@"center = %@", NSStringFromPoint(center));
	int i;
	NSMutableArray* inner = [NSMutableArray array];
	NSMutableArray* outer = [NSMutableArray array];
	
//	float col1x = center.x - 1.5 * hexSize.width;
//	float col2x = center.x - 0.75 * hexSize.width;
//	float col3x = center.x;
//	float col4x = center.x + 0.75* hexSize.width;
//	float col5x = center.x + 1.5 * hexSize.width;
	
	float h = 0;
	float w = 0;
	[inner addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x + w, center.y + h) size:hexSize]];
	h += hexSize.height;
	for (i = 0; i < 2; i++)	{
		[inner addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x, center.y + h) size:hexSize]];
		[inner addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x, center.y - h) size:hexSize]];
		
		h += hexSize.height;
	}
	
	[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x, center.y + h) size:hexSize]];
	[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x, center.y - h) size:hexSize]];
	
	w += 0.75 * hexSize.width;
	h = hexSize.height / 2;
	for (i = 0; i < 2; i++)	{
		[inner addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x + w, center.y + h) size:hexSize]];
		[inner addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x + w, center.y - h) size:hexSize]];
		[inner addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x - w, center.y + h) size:hexSize]];
		[inner addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x - w, center.y - h) size:hexSize]];
		h += hexSize.height;
	}
	
	[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x + w, center.y + h) size:hexSize]];
	[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x + w, center.y - h) size:hexSize]];
	[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x - w, center.y + h) size:hexSize]];
	[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x - w, center.y - h) size:hexSize]];
	
	
	w += 0.75 * hexSize.width;
	h = 0;
	[inner addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x + w, center.y + h) size:hexSize]];
	[inner addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x - w, center.y + h) size:hexSize]];
	h += hexSize.height;
	
	for (i = 0; i < 1; i++)	{
		[inner addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x + w, center.y + h) size:hexSize]];
		[inner addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x + w, center.y - h) size:hexSize]];
		[inner addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x - w, center.y + h) size:hexSize]];
		[inner addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x - w, center.y - h) size:hexSize]];
		h += hexSize.height;
	}
	
	[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x + w, center.y + h) size:hexSize]];
	[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x + w, center.y - h) size:hexSize]];
	[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x - w, center.y + h) size:hexSize]];
	[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x - w, center.y - h) size:hexSize]];

	w += 0.75 * hexSize.width;
	h = hexSize.height / 2;
	
//	[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x + w, center.y + h) size:hexSize]];
//	[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x - w, center.y + h) size:hexSize]];

//	h += hexSize.height;
	for (i = 0; i < 2; i++)	{
		[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x + w, center.y + h) size:hexSize]];
		[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x + w, center.y - h) size:hexSize]];
		[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x - w, center.y + h) size:hexSize]];
		[outer addObject:[Hexagon hexagonWithCenter:NSMakePoint(center.x - w, center.y - h) size:hexSize]];
		h += hexSize.height;
	}
	
//	NSLog(@"inner = %@, outer = %@", inner, outer);
	
//	[innerHexagons release];
//	[outerHexagons release];
//	innerHexagons = [[NSArray arrayWithArray:inner] retain];
//	outerHexagons = [[NSArray arrayWithArray:outer] retain];

//	NSLog(@"inner = %@, outer = %@", innerHexagons, outerHexagons);
	
//	[waterTiles release];
//	waterTiles = [[NSArray arrayWithArray:outer] retain];
	[inner sortUsingSelector:@selector(compareByCenter:)];
	[outer sortUsingSelector:@selector(compareByCenter:)];
	return [NSArray arrayWithObjects:inner, outer, nil];
}



-(NSBezierPath*) cornerPath	{
    

	NSBezierPath* path = [NSBezierPath bezierPath];
	NSSize tileSize = [self tileSize];
	NSSize netSize = [self bounds].size;
	[path moveToPoint:NSMakePoint(0, 0)];
	[path lineToPoint:NSMakePoint( (netSize.width / 2) - tileSize.width / 4, 0)];
	
	int i;
	for (i = 0; i < 3; i++)	{
		[path relativeLineToPoint:NSMakePoint(-tileSize.width / 4.0, tileSize.height / 2.0)];
		[path relativeLineToPoint:NSMakePoint(-tileSize.width / 2.0, 0)];
	}
	  
	[path lineToPoint:NSMakePoint(0, ( netSize.height / 2) - (1.5 * tileSize.height))];	[path lineToPoint:NSMakePoint(0, 0)];
	
	return path;
}
@end

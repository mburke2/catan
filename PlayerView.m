#import "PlayerView.h"
#import "Player.h"
#import "GameController.h"
#import "BoardView.h"
#import "NSBezierPath-Additions.h"

@implementation PlayerView

- (id)initWithFrame:(NSRect)frameRect	{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		myPlayer = nil;
		highlight = NO;
		robberableFlag = NO;
		[self registerForDraggedTypes:[NSArray arrayWithObject:@"CATAN_RESOURCE_TYPE"]];
		
		outlinePath = [NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, frameRect.size.width / 2, frameRect.size.height / 2)];
		[outlinePath retain];
	}
	return self;
}

-(void) viewDidMoveToSuperview	{
//	NSLog(@"MOVED TO SUPERVIEW, self = %@, superview = %@", self, [self superview]);
	if ([[self superview] class] == [BoardView class])	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(superviewFrameChanged:) name:NSViewFrameDidChangeNotification object:[self superview]];
//		[self buildOutlinePath];
//		[outlinePath release];
//		outlinePath = [[self superview] cornerPath];
//		[outlinePath retain];
	}
}

-(void) superviewFrameChanged:(NSNotification*)note	{
//	[outlinePath release];
//	outlinePath = [[self superview] cornerPath];
//	[outlinePath retain];
	[self buildOutlinePath];
}

-(NSView*) hitTest:(NSPoint)p	{
//	return NO;
//	NSLog(@"hitTesting %@", NSStringFromPoint(p));
	p = [self convertPoint:p fromView:[self superview]];
	if ([outlinePath containsPoint:p])
		return self;
	return nil;
	
//	return NO;
}

-(int) loction	{
	return myLocation;
}
-(void) setLocation:(int)loc	{
//	NSLog(@"setting location");
	myLocation = loc;
//	[self getPath];
	[self buildOutlinePath];
}

//-(void) getPath	{

-(void) buildOutlinePath	{
	NSBezierPath* tmpPath = [NSBezierPath bezierPath];
	[tmpPath appendBezierPath:[(BoardView*)[self superview] cornerPath]];
	if (myLocation == TopLeft || myLocation == BottomRight)	{
//		NSLog(@"flipping path");
		
		tmpPath = [tmpPath bezierPathByFlippingHorizontally];
//		NSLog(@"got new path, it's %@", newPath);
//		[outlinePath release];
//		outlinePath = [newPath retain];
		
	}
	
	NSAffineTransform* transform = [self transformForOutlinePath:tmpPath];
//	NSBezierPath* newPath = [NSBezierPath bezierPath];
//	[newPath appendBezierPath:outlinePath];
	[tmpPath transformUsingAffineTransform:transform];
	
	[outlinePath release];
	outlinePath = [NSBezierPath bezierPath];
	[outlinePath appendBezierPath:tmpPath];
	[outlinePath retain];
//	outlinePath = [newPath retain];
	
}	
/*
- (void)viewDidMoveToWindow	{
	NSLog(@"player view  %@ moved to window, %@", self, [self window]);

}
*/


-(void) setRobberable:(BOOL)flag	{
	robberableFlag = flag;
	[self setNeedsDisplay:YES];
}
- (void)drawRect:(NSRect)rect	{
//	NSLog(@"Drawing player view");
			
		

//	[[NSColor redColor] set];
//	[[colors objectAtIndex:rand() % [colors count]] set];
//	[NSBezierPath fillRect:[self bounds]];
	NSColor* color;
	if (myPlayer == nil)	{
		color = [[NSColor grayColor] colorWithAlphaComponent:0.6];
	}
	else	{
		color = [myPlayer color];
	//	if (highlight == NO)
		color = [color colorWithAlphaComponent:0.25];
	}
	
//	NSBezierPath* rectPath = [NSBezierPath bezierPathWithRect:[self bounds]];
	[color set];
//	[NSBezierPath fillRect:[self bounds]];
	[outlinePath fill];
//	[[NSColor blackColor] set];
//	[NSBezierPath strokeRect:[self bounds]];
	[outlinePath stroke];
	
	NSImage* image = nil;
//	BOOL lRoad = NO;
//	BOOL lArmy = NO;
	if ([[GameController gameController] playerHasLongestRoad:myPlayer])	{
//		lRoad = YES;
		image = [NSImage imageNamed:@"LongestRoadIcon.png"];	
		[image drawInRect:[self rectForFirstIcon] fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
	}
	if ([[GameController gameController] playerHasLargestArmy:myPlayer])	{
//		lArmy = YES;
		image = [NSImage imageNamed:@"LargestArmyIcon.png"];
		[image drawInRect:[self rectForSecondIcon] fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
	}
/*	if (lRoad && lArmy)	{
		image = [NSImage imageNamed:@"LongestRoadIcon.tiff"];
		[image drawInRect:[self rectForFirstIcon] fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
		image = [NSImage imageNamed:@"LargestArmyIcon.tiff"];
		[image drawInRect:[self rectForSecondIcon] fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
		image = nil;
	}
	else if (lRoad)
		image = [NSImage imageNamed:@"LongestRoadIcon.tiff"];
	else if (lArmy)
		image = [NSImage imageNamed:@"LargestArmyIcon.tiff"];
	
	if (image)
		[image drawInRect:[self rectForFirstIcon] fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
*/

	if (highlight)	{
		[[myPlayer color] set];
		[outlinePath setLineWidth:2];
		[outlinePath stroke];
	}
	if (myPlayer == nil)
		return;

	NSMutableArray* topStrings = [NSMutableArray array];
	
//	[topStrings addObject:[myPlayer name]];
	[topStrings addObject:[NSString stringWithFormat:@"%@ - %d", [myPlayer name], [myPlayer score]]];
	if ([[GameController gameController] phase] == RollPhase)	{
		if ([myPlayer active] == NO)	{
			[topStrings addObject:@"Waiting for player..."];
		}
		else	{
			int rVal = [[GameController gameController] rollPhaseRollForPlayer:myPlayer];
			if (rVal > 0)
				[topStrings addObject:[NSString stringWithFormat:@"Rolled: %d", rVal]];
		}
	}
	else	{
		[topStrings addObject:[NSString stringWithFormat:@"Resources: %d", [[myPlayer resources] count]]];
		[topStrings addObject:[NSString stringWithFormat:@"Development Cards: %d", [[myPlayer developmentCards] count]]];
		[topStrings addObject:[NSString stringWithFormat:@"Army Size: %d", [myPlayer armySize]]];
	}
	NSDictionary* fontAtt = [NSDictionary dictionaryWithObject:[NSFont fontWithName:@"Helvetica" size:10] forKey:NSFontAttributeName];
	int i;
	float yVal = 0;
	NSAttributedString* attStr;
	for (i = 0; i < [topStrings count]; i++)	{
		attStr = [[[NSAttributedString alloc] initWithString:[topStrings objectAtIndex:i] attributes:fontAtt] autorelease];
	//	yVal += (0 + [attStr size].height);
		[topStrings replaceObjectAtIndex:i withObject:attStr];
	//	[attStr drawAtPoint:NSMakePoint(3, [self bounds].size.height - yVal)];
	}
	
	NSArray* rects = [self rectsForStrings:topStrings];
	for (i = 0; i < [topStrings count]; i++)	{
		[[topStrings objectAtIndex:i] drawInRect:[[rects objectAtIndex:i] rectValue]];
	}
	
	NSAttributedString* junk;
	if ([myPlayer discardCount] > 0)	{
		junk = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Must discard %d resources", [myPlayer discardCount]] attributes:fontAtt] autorelease];
		[junk drawInRect:[self rectForDiscardString:junk]];
	}
	
	if (robberableFlag)	{
		junk = [[[NSAttributedString alloc] initWithString:@"Click to steal." attributes:fontAtt] autorelease];
		[junk drawInRect:[self rectForStealString:junk]];
	}
	/*NSMutableArray* bottomStrings  = [NSMutableArray array];
	if ([myPlayer discardCount] > 0)
		[bottomStrings addObject:[NSString stringWithFormat:@"Must discard %d resources.", [myPlayer discardCount]]];
	if (robberableFlag)
		[bottomStrings addObject:@"Click to steal."];
	
	yVal = 0;
	for (i = 0; i < [bottomStrings count]; i++)	{
		yVal += 3;
		attStr = [[[NSAttributedString alloc] initWithString:[bottomStrings objectAtIndex:i] attributes:fontAtt] autorelease];
		[attStr drawAtPoint:NSMakePoint(3, yVal)];
		yVal += [attStr size].height;
	}*/
	/*
	NSAttributedString* nameString = [[[NSAttributedString alloc] initWithString:[myPlayer name] attributes:nil] autorelease];
	[nameString drawAtPoint:NSMakePoint(3, [self bounds].size.height - ([nameString size].height + 3))];
	
	if ([[GameController gameController] phase] == RollPhase)	{
		int rVal = [[GameController gameController] rollPhaseRollForPlayer:myPlayer];
		if (rVal > 0)	{
			NSAttributedString* rollString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rolled: %d", rVal] attributes:nil] autorelease];
			[rollString drawAtPoint:NSMakePoint(3, [self bounds].size.height - ([nameString size].height + [rollString size].height + 6))];
		}
	}
	else	{
		NSAttributedString* resString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Resources: %d", [[myPlayer resources] count]] attributes:nil] autorelease];
		[resString drawAtPoint:NSMakePoint(3, [self bounds].size.height - ([nameString size].height + [resString size].height + 6))];
		
		if ([myPlayer discardCount] > 0)	{
			NSAttributedString* noteString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Must discard %d", [myPlayer discardCount]] attributes:nil] autorelease];
			[noteString drawAtPoint:NSMakePoint(3, [self bounds].size.height - ([nameString size].height + [resString size].height + [noteString size].height + 9))];
		}
			
		if (robberableFlag)	{
			NSAttributedString* stealString = [[[NSAttributedString alloc] initWithString:@"Click To Steal" attributes:nil] autorelease];
			[stealString drawAtPoint:NSMakePoint(3, 3)];
		}
	}*/
}


-(BOOL) shouldAcceptTrade:(id <NSDraggingInfo>) sender	{
	if (myPlayer == nil || [[GameController gameController] localPlayer] == myPlayer)
		return NO;
	if ([[GameController gameController] currentPlayer] != myPlayer && [[GameController gameController] localPlayer] != [[GameController gameController] currentPlayer])
		return NO;
		
	NSPoint p =  [sender draggingLocation];
	p = [self convertPoint:p fromView:[[self window] contentView]];

	if ([outlinePath containsPoint:p])
		return YES;
		
	return NO;
}

-(NSDragOperation) draggingUpdated:(id <NSDraggingInfo>) sender	{
	if ([[GameController gameController] localPlayerMustDiscard])	{
		if ([self shouldAcceptTrade:sender] == NO)
			return NSDragOperationLink;
		else
			return NSDragOperationNone;
	//	[[GameController gameController] player:[[GameController gameController] localPlayer] discarded:[[sender draggingPasteboard] propertyListForType:@"CATAN_RESOURCE_TYPE"]];
	//	return YES;
	}
	
	if ([self shouldAcceptTrade:sender])
		return NSDragOperationCopy;
		
	return NSDragOperationNone;

/*

	if (myPlayer == nil || [[GameController gameController] localPlayer] == myPlayer)
		return NSDragOperationNone;
	
	if ([[GameController gameController] currentPlayer] != myPlayer && [[GameController gameController] localPlayer] != [[GameController gameController] currentPlayer])
		return NSDragOperationNone;

	NSPoint p =  [sender draggingLocation];
	p = [self convertPoint:p fromView:[[self window] contentView]];

	if ([outlinePath containsPoint:p])
		return NSDragOperationCopy;
	
	return NSDragOperationNone;	
	*/
}
/*
-(NSDragOperation) draggingEntered:(id <NSDraggingInfo>)sender	{
	if (myPlayer == nil || [[GameController gameController] localPlayer] == myPlayer)
		return NSDragOperationNone;
	
	if ([[GameController gameController] currentPlayer] != myPlayer && [[GameController gameController] localPlayer] != [[GameController gameController] currentPlayer])
		return NSDragOperationNone;
		
	return NSDragOperationCopy;
//	return NSDragOperationCopy;
}*/

-(BOOL) performDragOperation:(id <NSDraggingInfo>)sender	{
	if ([[GameController gameController] localPlayerMustDiscard])	{
		[[GameController gameController] player:[[GameController gameController] localPlayer] discarded:[[sender draggingPasteboard] propertyListForType:@"CATAN_RESOURCE_TYPE"]];
		return YES;
	}
	NSArray* res = [[sender draggingPasteboard] propertyListForType:@"CATAN_RESOURCE_TYPE"];
//	[[GameController gameController] trade:res toFrom:[NSArray arrayWithObjects:[[GameController gameController] localPlayer], myPlayer, nil]];
	if ([[GameController gameController] trade:res from:[[GameController gameController] localPlayer] to:myPlayer])
		return YES;
	return NO;
}

-(Player*)player	{
	return myPlayer;
}

-(void) setPlayer:(Player*)p	{
	[myPlayer release];
	myPlayer = [p retain];
	[self setNeedsDisplay:YES];
}

-(NSRect) resRect	{
	NSPoint p;
	NSSize sz = [[NSImage imageNamed:@"BrickRes.tiff"] size];
	sz.width = (int) (sz.width / 6.0);
	sz.height = (int) (sz.height / 6.0);
	if (myLocation == TopLeft || myLocation == TopRight)
		p.y = [self bounds].size.height - (sz.height + 2);
	else
		p.y = 2;
	
	if (myLocation == TopLeft || myLocation == BottomLeft)
		p.x = [outlinePath bounds].size.width - (sz.width + 2);
	else
		p.x = [outlinePath bounds].origin.x + 2;
		
	return NSMakeRect(p.x, p.y, sz.width, sz.height);
}

-(NSArray*) reserveFramesForResources:(NSArray*)arr	{
	int i;
	NSMutableArray* result = [NSMutableArray array];
	for (i = 0; i < [arr count]; i++)	{
		[result addObject:[NSValue valueWithRect:[self resRect]]];
//		[result addObject:[NSValue valueWithRect:[self bounds]]];
	}
	return result;
}

-(void) addResource:(NSString*)str inRect:(NSRect)r	{
	
}

-(NSViewAnimation*) animationToMakeRoomForNewResourcesOfType:(NSArray*)newTypes	{
	NSViewAnimation* ani =  [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray array]] autorelease];
	[ani setDuration:0.0];
	return ani;
}

-(void) setHighlight:(BOOL)flag	{
	highlight = flag;
	[self setNeedsDisplay:YES];
}

-(void) mouseDown:(NSEvent*)event	{
//	NSLog(@"mouse down");
	if (robberableFlag == YES)	{
		[[GameController gameController] stealFrom:myPlayer];
		return;
	}
	
	NSPoint p = [event locationInWindow];
	p = [self convertPoint:p fromView:[[self window] contentView]];
	
	if (NSMouseInRect(p, [self rectForFirstIcon], NO) && [[GameController gameController] playerHasLongestRoad:myPlayer])
		[[GameController gameController] highlightLongestRoad];
}	


-(NSAffineTransform*) transformForOutlinePath:(NSBezierPath*)path	{
	NSAffineTransform* transform = [NSAffineTransform transform];
	
	if (myLocation == TopLeft || myLocation == TopRight)	{
		[transform translateXBy:[path bounds].size.width yBy:[self bounds].size.height];
		[transform rotateByDegrees:180];
	}
	if (myLocation == BottomRight)	{//|| myLocation == TopRight)	{
		[transform translateXBy:[self bounds].size.width - [path bounds].size.width yBy:0];
	}
	if (myLocation == TopRight)	{
		[transform translateXBy:-([self bounds].size.width - [path bounds].size.width) yBy:0];
	}	
	
	return transform;
}	


-(NSArray*) rectsForStrings:(NSArray*)strings	{
	int i;
	NSMutableArray* rects = [NSMutableArray array];
	NSPoint p;
	float netHeight = 0;
	NSRect rect;
	for (i = 0; i < [strings count]; i++)	{
		if (myLocation == TopLeft || myLocation == TopRight)
			p.y = [self bounds].size.height - (3 + netHeight + [[strings objectAtIndex:i] size].height);
		else
			p.y = 3 + netHeight;// + [[strings objectAtIndex:i] size].height;
		
		if (myLocation == TopLeft || myLocation == BottomLeft)
			p.x = 3;
		else
			p.x = [self bounds].size.width - (3 + [[strings objectAtIndex:i] size].width);
			
		netHeight += [[strings objectAtIndex:i] size].height;
		rect = NSMakeRect(p.x, p.y, [[strings objectAtIndex:i] size].width, [[strings objectAtIndex:i] size].height);
		[rects addObject:[NSValue valueWithRect:rect]];
	}
	
	return rects;
}


-(NSSize) iconSize	{
	NSRect bounds = [outlinePath bounds];
	float h = bounds.size.height / 4.0;
	h -= 8;
	
	return NSMakeSize(h, h);
}
-(NSRect) rectForFirstIcon	{
	NSPoint p;
	if (myLocation == TopLeft || myLocation == BottomLeft)
		p.x = 3.0;
	else
		p.x = ([outlinePath bounds].origin.x + [outlinePath bounds].size.width) - (3.0 + [self iconSize].width);
	
//	float h = [outlinePath bounds].size.width / 4.0;
	
	if (myLocation == TopLeft || myLocation == TopRight)	{
		p.y = [self bounds].size.height - (3  * [outlinePath bounds].size.height / 4.0) + 4.0;
		//p.y = [self bounds].size.height - ([outlinePath bounds].size.height / 2.0) + 4.0;
	}
	else
		p.y = (2 * [outlinePath bounds].size.height) / 4.0 + 4.0;
		
	
	return NSMakeRect(p.x, p.y, [self iconSize].width, [self iconSize].height);
		
}

-(NSRect) rectForSecondIcon	{
	NSRect r = [self rectForFirstIcon];
	if (myLocation == TopLeft || myLocation == BottomLeft)
		r.origin.x += (3 + [self iconSize].width);
	else
		r.origin.x -= (3 + [self iconSize].width);
	return r;
}

-(NSRect) rectForStealString:(NSAttributedString*)str	{
	NSSize sz = [str size];
	NSPoint p;
	if (myLocation == TopLeft || myLocation == TopRight)
		p.y = [self bounds].size.height - 2 * (sz.height + 2);
	else
		p.y = 4 + sz.height;
		
	if (myLocation == TopLeft || myLocation == BottomLeft)
		p.x = [outlinePath bounds].size.width - (sz.width + 2);
	else
		p.x = [outlinePath bounds].origin.x + 2;
		
	return NSMakeRect(p.x, p.y, sz.width, sz.height);
}

-(NSRect) rectForDiscardString:(NSAttributedString*)str	{
	NSSize sz = [str size];
	NSPoint p;
	if (myLocation == TopLeft || myLocation == TopRight)	{
		p.y = [self bounds].size.height - (sz.height + 2);
	}
	else
		p.y = 2;

	if (myLocation == BottomLeft || myLocation == TopLeft)
		p.x = [outlinePath bounds].size.width - (sz.width + 2);
	else
		p.x = [outlinePath bounds].origin.x + 2;
	
	return NSMakeRect(p.x, p.y, sz.width, sz.height);
}

@end

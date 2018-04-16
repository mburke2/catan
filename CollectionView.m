#import "CollectionView.h"

#define PP  //NSLog(@"%s", __FUNCTION__);
//#define NSLog //
@implementation CollectionView

- (id)initWithFrame:(NSRect)frameRect
{
//	srand(time(0));
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		selecting = NO;
		scaleFactor = 6.0;
		xMargin = 5;
		yMargin = 3;
		verticalOverlap = 11;
		cornerOne = NSMakePoint(0, 0);
		cornerTwo = NSMakePoint(0,0);
		selectionView = [[SelectionView alloc] initWithFrame:[self bounds]];
		[selectionView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[self addSubview:selectionView];
		resViews = [[NSMutableArray alloc] init];
		previouslySelected = [[NSMutableArray alloc] init];
		animationLength = 0.25;
		reservedViews = [[NSMutableArray alloc] init];
		[self registerForDraggedTypes:[NSArray arrayWithObject:@"CATAN_RESOURCE_TYPE"]];
//		tmpRectToDraw = NSMakeRect(-1, -1, 0, 0);
	}
	return self;
}

-(NSDragOperation) draggingEntered:(id <NSDraggingInfo>)sender	{
	return NSDragOperationNone;
}


-(NSArray*) indicesForNewResources:(NSArray*)newRes inTotalResources:(NSArray*)total	{
	NSArray* types = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	NSMutableDictionary* newCounts = [NSMutableDictionary dictionary];
	NSMutableDictionary* totalCounts = [NSMutableDictionary dictionary];
	int i;
	for (i = 0; i < [types count]; i++)	{
		[newCounts setObject:[NSNumber numberWithInt:0] forKey:[types objectAtIndex:i]];
		[totalCounts setObject:[NSNumber numberWithInt:0] forKey:[types objectAtIndex:i]];
	}
	
	int c;
	for (i = 0; i < [newRes count]; i++)	{
		c = [[newCounts objectForKey:[newRes objectAtIndex:i]] intValue];
		c = c + 1;
		[newCounts setObject:[NSNumber numberWithInt:c] forKey:[newRes objectAtIndex:i]];
	}
	for (i = 0; i < [total count]; i++)	{
		c = [[totalCounts objectForKey:[total objectAtIndex:i]] intValue];
		c = c + 1;
		[totalCounts setObject:[NSNumber numberWithInt:c] forKey:[total objectAtIndex:i]];
	}
	NSMutableArray* indices = [NSMutableArray array];
    NSLog(@"going to sort res");
	total = [self sortResources:total];
    NSLog(@"sorted res");
	
	int j;
	int c2;
	int index;
	for (i = 0; i < [types count]; i++)	{
//		c = [[newCounts objectAtIndex:i] intValue];	
		c = [[newCounts objectForKey:[types objectAtIndex:i]] intValue];
		c2 = [[totalCounts objectForKey:[types objectAtIndex:i]] intValue];
		if (c > 0)	{
			index = [total indexOfObject:[types objectAtIndex:i]] + (c2 - c);
			for (j = 0; j < c; j++)	{
				[indices addObject:[NSNumber numberWithInt:j + index]];
			}
		}
//		c2 = [[newCounts objectAtIndex:i] intValue];
	}
	
	return indices;
}
-(NSArray*) reserveFramesForResources:(NSArray*)newRes	{
	NSMutableArray* theRes = [NSMutableArray array];
	int i;
	for (i = 0; i < [resViews count]; i++)
		[theRes addObject:[[resViews objectAtIndex:i] type]];
	for (i = 0; i < [newRes count];i++)
		[theRes addObject:[newRes objectAtIndex:i]];
	theRes = [self sortResources:theRes];
	NSArray* frames = [self rectsForResources:theRes];
//	NSLog(@"frames = %@", frames);
	NSMutableArray* newFrames = [NSMutableArray array];
	NSArray* indices = [self indicesForNewResources:newRes inTotalResources:theRes];
//	NSLog(@"indices = %@", indices);
//	int index;
	for (i = 0; i < [indices count]; i++)	{
		//index = [theRes indexOfObject:[newRes objectAtIndex:i]];
		[newFrames addObject:[frames objectAtIndex:[[indices objectAtIndex:i] intValue]]];
//		if (index != NSNotFound)	{
//			[newFrames addObject:[frames objectAtIndex:index]];
//			NSLog(@"index = %d", index);
//		}
	}
	
	return newFrames;
}



-(NSArray*) oldreserveFramesForResources:(NSArray*)res	{
//	res = [self sortResources:res];
	NSLog(@"reserving for %@\n%@", NSStringFromClass([res class]), res);
	NSMutableArray* tmp = [NSMutableArray array];
	NSMutableArray* result = [NSMutableArray array];
//	ResViewRep* rv;
	ResView* rv;
	int i;
	for (i = 0; i < [res count]; i++)	{
//		rv = [[[ResViewRep alloc] init] autorelease];
		rv = [[[ResView alloc] init] autorelease];
		[rv setType:[res objectAtIndex:i]];
		[rv setFrame:[self frameForNewResourceOfType:[res objectAtIndex:i]]];
		[result addObject:[NSValue valueWithRect:[rv frame]]];
		[tmp addObject:rv];
		[reservedViews addObject:rv];
	}
	
	for (i = 0; i < [tmp count]; i++)	{
		[reservedViews removeObject:[tmp objectAtIndex:i]];
	}
	
	NSLog(@"reserved");
	return result;
//	return nil;
}

-(BOOL) animating	{
	return animating;
}







-(void) setDataSource:(id)obj	{
	dataSource = [obj retain];
}

-(void) reloadData	{
//	NSLog(@"reloading");

	int i;
	for (i = 0; i < [resViews count]; i++)	{
		[[resViews objectAtIndex:i] removeFromSuperview];
	}
	[resViews removeAllObjects];
	NSArray* res = [dataSource resources];
//	int i;
	for (i = 0; i < [res count]; i++)	{
//		NSLog(@"going to add %@, %@", [res objectAtIndex:i], NSStringFromClass([[res objectAtIndex:i] class]));
		[self addResource:[res objectAtIndex:i]];
	}
}

-(NSArray*) sortResources:(NSArray*)res	{
//	NSLog(@"sorting %@", res);
	NSMutableArray* arr = [NSMutableArray arrayWithArray:res];
	NSArray* base = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	int i, j;
	for (i = 0; i < [arr count]; i++)	{
		if ([base indexOfObject:[arr objectAtIndex:i]] == NSNotFound)	{
			NSLog(@"couldn't find %@", [arr objectAtIndex:i]);
		}
		for (j = i + 1; j < [arr count]; j++)	{
			if ([base indexOfObject:[arr objectAtIndex:j]] < [base indexOfObject:[arr objectAtIndex:i]])
				[arr exchangeObjectAtIndex:i withObjectAtIndex:j];
		}
	}
//	NSLog(@"sorted, %@", arr);
	return [NSArray arrayWithArray:arr];
}


-(NSArray*) rectsForResources:(NSArray*)res	{
	int i;
	NSSize sz = [[NSImage imageNamed:@"BrickRes"] size];
	sz.width = (int)(sz.width / scaleFactor);
	sz.height = (int)(sz.height / scaleFactor);

	res = [self sortResources:res];
	NSRect rect = NSMakeRect(0, 0, 0, 0);
	rect = NSMakeRect(xMargin, [self bounds].origin.y + [self bounds].size.height - (sz.height + yMargin), sz.width, sz.height);
	NSMutableArray* rects = [NSMutableArray array];
	for (i = 0; i < [res count]; i++)	{
		if (i > 0)	{
			if ([[res objectAtIndex:i - 1] isEqualToString:[res objectAtIndex:i]] == NO)	{
			rect.origin.y = [self bounds].origin.y + ([self bounds].size.height - (yMargin + rect.size.height));
			rect.origin.x += rect.size.width + xMargin;
			}
			else	
				rect.origin.y -= verticalOverlap;
		}
		
//		NSLog(@"adding rect %@", NSStringFromRect(rect));
		[rects addObject:[NSValue valueWithRect:rect]];
	}
	
	return rects;
}

-(void) testaddResource:(NSString*)str inRect:(NSRect)rect	{
	NSImageView* view = [[[NSImageView alloc] initWithFrame:rect] autorelease];
//	[view setImage:[NSImage imageNamed:@"BrickRes.tiff"]];
	[view setImage:[NSImage imageNamed:@"BrickRes"]];
	[self addSubview:view];
}
-(void) addResource:(NSString*)str inRect:(NSRect)rect	{
//	ResViewRep* rvr = [[[ResViewRep alloc] init] autorelease];
	ResView* rvr = [[[ResView alloc] initWithFrame:rect] autorelease];
	[rvr setType:str];
	[resViews addObject:rvr];
	[rvr setFrame:rect];
	
	[self addSubview:rvr positioned:NSWindowBelow relativeTo:selectionView];
	[self setNeedsDisplay:YES];
}

-(void) addResource:(NSString*)str	{
//	ResViewRep* res = [[[ResViewRep alloc] init] autorelease];
	ResView* res = [[[ResView alloc] init] autorelease];
	[res setType:str];
	[resViews addObject:res];
	[self addSubview:res positioned:NSWindowBelow relativeTo:selectionView];
	[self arrangeViews];
	
	[self setNeedsDisplay:YES];
}

\
-(NSRect) frameForNewResourceOfType:(NSString*)str	{
	NSRect frame = NSMakeRect(0, 0, 0, 0);// = NSMakeRect(xMargin, 
//	NSMutableArray* arr = [NSMutableArray array];
	int i;
	NSArray* types = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	NSMutableArray* preTypes = [NSMutableArray array];
	int count = 0;
	for (i = 0; i < [resViews count]; i++)	{
		if ([str isEqualToString:[[resViews objectAtIndex:i] type]])
			frame = [[resViews objectAtIndex:i] frame];
		
		if ([types indexOfObject:str] > [types indexOfObject:[[resViews objectAtIndex:i] type]] && [preTypes indexOfObject:[[resViews objectAtIndex:i] type]] == NSNotFound)	{
			count++;
			[preTypes addObject:[[resViews objectAtIndex:i] type]];
		}
	}

	for (i = 0; i < [reservedViews count]; i++)	{
		if ([str isEqualToString:[[reservedViews objectAtIndex:i] type]])
			frame = [[reservedViews objectAtIndex:i] frame];
		
		if ([types indexOfObject:str] > [types indexOfObject:[[reservedViews objectAtIndex:i] type]] && [preTypes indexOfObject:[[reservedViews objectAtIndex:i] type]] == NSNotFound)	{
			count++;
			[preTypes addObject:[[reservedViews objectAtIndex:i] type]];
		}
	}
	if (frame.size.width > 0 && frame.size.height > 0)	{
		frame.origin.y -= verticalOverlap;
		return frame;
	}
	
//	NSSize sz = [[[NSImage imageNamed:@"BrickRes.tiff"] autorelease] size];
//	NSSize sz = [[NSImage imageNamed:@"BrickRes.tiff"] size];
	NSSize sz = [[NSImage imageNamed:@"BrickRes"] size];
	
	sz.width = (int)(sz.width / scaleFactor);
	sz.height = (int)(sz.height / scaleFactor);
	
	frame = NSMakeRect(xMargin, [self bounds].size.height - (yMargin + sz.height), sz.width, sz.height);
	for (i = 0; i < count; i++)
		frame.origin.x += (xMargin + sz.width);
		
	return frame;
}

-(void) arrangeViews	{
//	float scaleFactor = 3.0;
	NSArray* types = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	
	int i;
	for (i = 0; i < [types count]; i++)	{
		[dict setObject:[NSMutableArray array] forKey:[types objectAtIndex:i]];
	}
	
	NSMutableArray* arr;
	for (i = 0; i < [resViews count]; i++)	{
		arr = [dict objectForKey:[[resViews objectAtIndex:i] type]];
		[arr addObject:[resViews objectAtIndex:i]];
	}
	
//	NSArray* keys = [dict allKeys];
	NSRect frame;
//	NSSize sz = [[[NSImage imageNamed:@"BrickRes.tiff"] autorelease] size];
//	NSSize sz = [[NSImage imageNamed:@"BrickRes.tiff"] size];
	NSSize sz = [[NSImage imageNamed:@"BrickRes"] size];
	sz.width = (int)(sz.width / scaleFactor);
	sz.height = (int)(sz.height / scaleFactor);
	int j;
	NSPoint p = NSMakePoint(xMargin, [self bounds].size.height);
	NSRect curFrame;
	for (i = 0; i < [types count]; i++)	{
		//p.x = xMargin;
		p.y = [self bounds].size.height - (yMargin + sz.height);
		arr = [dict objectForKey:[types objectAtIndex:i]];

		for (j = 0; j < [arr count]; j++)	{
			frame = NSMakeRect(p.x + rand() % 3 - 1, p.y + rand() % 3 - 1, sz.width, sz.height);
			curFrame = [[arr objectAtIndex:j] frame];
//			NSLog(@"curFrame = %@", NSStringFromRect
	//		if (curFrame.size.width < 1 || curFrame.size.height < 1 || curFrame.origin.x < 0 || curFrame.origin.y < 0)
				[[arr objectAtIndex:j] setFrame:frame];
			p.y -= verticalOverlap;
		}
		if ([arr count] > 0)
			p.x += (xMargin +  sz.width);

	}
	
	[self setNeedsDisplay:YES];
}

-(float) makeRoomForResourceOfType:(NSString*)type	{
	NSArray* types = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	
//	int targetCount = 0;
	NSMutableArray* needMoved = [NSMutableArray array];
	int targetIndex = [types indexOfObject:type];
	int index;
	int i;
	for (i = 0; i < [resViews count]; i++)	{
		if ([type isEqualToString:[[resViews objectAtIndex:i] type]])
			return 0;
		index = [types indexOfObject:[[resViews objectAtIndex:i] type]];
		if (index > targetIndex)	{
			[needMoved addObject:[resViews objectAtIndex:i]];
		}
	}
	
	NSLog(@"needMoved = %@", needMoved);
	if ([needMoved count] == 0)
		return 0;
	NSMutableArray* targetFrames = [NSMutableArray array];
	NSMutableArray* startFrames = [NSMutableArray array];
	NSRect tmp;
//	NSSize sz = [[[NSImage imageNamed:@"BrickRes.tiff"] autorelease] size];
//	NSSize sz = [[NSImage imageNamed:@"BrickRes.tiff"] size];
	NSSize sz = [[NSImage imageNamed:@"BrickRes"] size];

	sz.width = (int)(sz.width / scaleFactor);
	sz.height = (int)(sz.height / scaleFactor);
	for (i = 0; i < [needMoved count]; i++)	{
		tmp = [[needMoved objectAtIndex:i] frame];
		[startFrames addObject:[NSValue valueWithRect:tmp]];
		tmp.origin.x += (xMargin + sz.width);
		[targetFrames addObject:[NSValue valueWithRect:tmp]];
	}

	float tLength = 0.2;
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		startFrames, @"StartFrames",
		targetFrames, @"EndFrames",
		needMoved, @"ObjectsToMove",
		[NSNumber numberWithFloat:tLength], @"Duration",
		[NSDate date], @"StartTime", nil];
//	animationStartTime = [[NSDate date] retain];
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(slideHorizontal:) userInfo:userInfo repeats:YES];
	
	return tLength;
}

-(NSArray*) stripDuplicates:(NSArray*)arr	{
	NSMutableArray* newArray = [NSMutableArray array];
	int i;
	id item;
	for (i = 0; i < [arr count]; i++)	{
		item = [arr objectAtIndex:i];
		if ([newArray indexOfObject:item] == NSNotFound)
			[newArray addObject:item];
	}
	
	return [NSArray arrayWithArray:newArray];
}

-(NSViewAnimation*) animationToMakeRoomForNewResourcesOfType:(NSArray*)newTypes	{
	NSArray* types = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
//	NSLog(@"making room for %@", newTypes);
	newTypes = [self stripDuplicates:newTypes];
//	NSLog(@"removed duplicates, %@", newTypes);
//	int targetCount = 0;
	NSMutableArray* needMoved = [NSMutableArray array];
//	int targetIndex = [types indexOfObject:type];
	NSInteger targetIndex;
	int index;
	int i, j;
	NSString* type;
	BOOL shouldMove;
	NSMutableArray* tmpMove;
	for (j = 0; j < [newTypes count]; j++)	{
		type = [newTypes objectAtIndex:j];
//		NSLog(@"type = %@", type);

		targetIndex = [types indexOfObject:type];
		shouldMove = YES;
		tmpMove = [NSMutableArray array];
		for (i = 0; i < [resViews count]; i++)	{
			if ([type isEqualToString:[[resViews objectAtIndex:i] type]])
				shouldMove = NO;
			else	{
				index = [types indexOfObject:[[resViews objectAtIndex:i] type]];
				if (index > targetIndex)	{
//					NSLog(@"adding to tmpMove:%@", [[resViews objectAtIndex:i] type]);
					[tmpMove addObject:[resViews objectAtIndex:i]];
					//[needMoved addObject:[resViews objectAtIndex:i]];
				}
			}
		}
		if (shouldMove == YES)	{
//			NSLog(@"adding to needMoved, %@", tmpMove);
			[needMoved addObjectsFromArray:tmpMove];
		}
	}
	
//	NSLog(@"needMoved = %@", needMoved);
	if ([needMoved count] == 0)	{
		NSViewAnimation* junk = [[NSViewAnimation alloc] initWithDuration:0 animationCurve:NSAnimationLinear];
		return junk;
	}	
	
//	NSLog(@"needMoved = %@", needMoved);
		//return 0;
	NSMutableArray* targetFrames = [NSMutableArray array];
	NSMutableArray* startFrames = [NSMutableArray array];
	NSMutableArray* views = [NSMutableArray array];

	NSRect tmp;
//	NSSize sz = [[[NSImage imageNamed:@"BrickRes.tiff"] autorelease] size];
//	NSSize sz = [[NSImage imageNamed:@"BrickRes.tiff"] size];
	NSSize sz = [[NSImage imageNamed:@"BrickRes"] size];
	NSView* aView;
	sz.width = (int)(sz.width / scaleFactor);
	sz.height = (int)(sz.height / scaleFactor);
	
//	NSMutableArray* views = [NSMutableArray array];
	NSInteger junkIndex;
//	NSLog(@"building views etc");
	for (i = 0; i < [needMoved count]; i++)	{
		aView = [needMoved objectAtIndex:i];
		junkIndex = [views indexOfObject:aView];
		if (junkIndex == NSNotFound)	{
			[views addObject:aView];
			tmp = [aView frame];
			[startFrames addObject:[NSValue valueWithRect:tmp]];
			tmp.origin.x += (xMargin + sz.width);
			[targetFrames addObject:[NSValue valueWithRect:tmp]];
//			NSLog(@"added to each");
//			NSLog(@"views = %@, startFrames = %@, targetFrames = %@", views, startFrames, targetFrames);
		}
		else	{
//			NSLog(@"moving frame at index, %d in %@", junkIndex, targetFrames);
			tmp = [[targetFrames objectAtIndex:junkIndex] rectValue];
			tmp.origin.x += (xMargin + sz.width);
			[targetFrames replaceObjectAtIndex:junkIndex withObject:[NSValue valueWithRect:tmp]];
		}
//		tmp = [[needMoved objectAtIndex:i] frame];
//		[startFrames addObject:[NSValue valueWithRect:tmp]];
//		tmp.origin.x += (xMargin + sz.width);
//		[targetFrames addObject:[NSValue valueWithRect:tmp]];
	}
//	NSLog(@"got them...");
//	NSLog(@"views = %@, startFrames = %@, targetFrames = %@", views, startFrames, targetFrames);
	NSMutableArray* vas = [NSMutableArray array];
	for (i = 0; i < [views count]; i++)	{
		[vas addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			[views objectAtIndex:i], NSViewAnimationTargetKey,
			[startFrames objectAtIndex:i], NSViewAnimationStartFrameKey,
			[targetFrames objectAtIndex:i], NSViewAnimationEndFrameKey, 
			nil]];
	}
//	for (i = 0; i < [needMoved count]; i++)	{
//		[vas addObject:[NSDictionary dictionaryWithObjectsAndKeys:
//			[needMoved objectAtIndex:i], NSViewAnimationTargetKey,
//			[startFrames objectAtIndex:i], NSViewAnimationStartFrameKey,
//			[targetFrames objectAtIndex:i], NSViewAnimationEndFrameKey, nil]];
//	}
	
	NSViewAnimation* ani = [[[NSViewAnimation alloc] initWithViewAnimations:vas] autorelease];
	if ([vas count] > 0)
		[ani setDuration:0.2];
	else
		[ani setDuration:0.0];
	
	return ani;
	/*
	float tLength = 0.2;
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		startFrames, @"StartFrames",
		targetFrames, @"EndFrames",
		needMoved, @"ObjectsToMove",
		[NSNumber numberWithFloat:tLength], @"Duration",
		[NSDate date], @"StartTime", nil];
//	animationStartTime = [[NSDate date] retain];
	animating = YES;
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(slideHorizontal:) userInfo:userInfo repeats:YES];
	
	return tLength;
*/
}
-(float) makeRoomForResourcesOfType:(NSArray*)newTypes	{
	NSArray* types = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
//	NSLog(@"making room for %@", newTypes);
	newTypes = [self stripDuplicates:newTypes];
//	NSLog(@"removed duplicates, %@", newTypes);
//	int targetCount = 0;
	NSMutableArray* needMoved = [NSMutableArray array];
//	int targetIndex = [types indexOfObject:type];
	int targetIndex;
	int index;
	int i, j;
	NSString* type;
	BOOL shouldMove;
	NSMutableArray* tmpMove;
	for (j = 0; j < [newTypes count]; j++)	{
		type = [newTypes objectAtIndex:j];
		targetIndex = [types indexOfObject:type];
		shouldMove = YES;
		tmpMove = [NSMutableArray array];
		for (i = 0; i < [resViews count]; i++)	{
			if ([type isEqualToString:[[resViews objectAtIndex:i] type]])
				shouldMove = NO;
			else	{
				index = [types indexOfObject:[[resViews objectAtIndex:i] type]];
				if (index > targetIndex)	{
					[tmpMove addObject:[resViews objectAtIndex:i]];
					//[needMoved addObject:[resViews objectAtIndex:i]];
				}
			}
		}
		if (shouldMove == YES)
			[needMoved addObjectsFromArray:tmpMove];
	}
	
//	NSLog(@"needMoved = %@", needMoved);
	if ([needMoved count] == 0)
		return 0;
	NSMutableArray* targetFrames = [NSMutableArray array];
	NSMutableArray* startFrames = [NSMutableArray array];
	NSRect tmp;
//	NSSize sz = [[[NSImage imageNamed:@"BrickRes.tiff"] autorelease] size];
//	NSSize sz = [[NSImage imageNamed:@"BrickRes.tiff"] size];
	NSSize sz = [[NSImage imageNamed:@"BrickRes"] size];

	sz.width = (int)(sz.width / scaleFactor);
	sz.height = (int)(sz.height / scaleFactor);
	for (i = 0; i < [needMoved count]; i++)	{
		tmp = [[needMoved objectAtIndex:i] frame];
		[startFrames addObject:[NSValue valueWithRect:tmp]];
		tmp.origin.x += (xMargin + sz.width);
		[targetFrames addObject:[NSValue valueWithRect:tmp]];
	}

	float tLength = 0.2;
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		startFrames, @"StartFrames",
		targetFrames, @"EndFrames",
		needMoved, @"ObjectsToMove",
		[NSNumber numberWithFloat:tLength], @"Duration",
		[NSDate date], @"StartTime", nil];
//	animationStartTime = [[NSDate date] retain];
	animating = YES;
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(slideHorizontal:) userInfo:userInfo repeats:YES];
	
	return tLength;
}

-(void) removeSelected	{
	PP;
	NSMutableArray* selected = [NSMutableArray array];
	int i;
	for (i = 0; i < [resViews count]; i++)	{
		if ([[resViews objectAtIndex:i] selected])
			[selected addObject:[resViews objectAtIndex:i]];
	}
	
	NSMutableArray* needMovedVertically = [NSMutableArray array];
//	int i;
	int j;
//	ResViewRep* res1;
//	ResViewRep* res2;
	ResView* res1;
	ResView* res2;
	
	for (i = 0; i < [selected count]; i++)	{
		res1 = [selected objectAtIndex:i];
		for (j = 0; j < [resViews count]; j++)	{
			res2 = [resViews objectAtIndex:j];
			if ([[res1 type] isEqualToString:[res2 type]] && [resViews indexOfObject:res2] > [resViews indexOfObject:res1])
				[needMovedVertically addObject:res2];
		}
	}
	
	NSMutableArray* objectsToMove = [NSMutableArray array];
	NSMutableArray* startFrames = [NSMutableArray array];
	NSMutableArray* endFrames = [NSMutableArray array];
	NSRect tmp;
	int index;
	for (i = 0; i < [needMovedVertically count];  i++)	{
		index = [objectsToMove indexOfObject:[needMovedVertically objectAtIndex:i]];
		if (index == NSNotFound)	{
			[objectsToMove addObject:[needMovedVertically objectAtIndex:i]];
			[startFrames addObject:[NSValue valueWithRect:[[needMovedVertically objectAtIndex:i] frame]]];
			[endFrames addObject:[NSValue valueWithRect:[[needMovedVertically objectAtIndex:i] frame]]];
			index = [objectsToMove count] - 1;
		}
		tmp = [[endFrames objectAtIndex:index] rectValue];
		tmp.origin.y += verticalOverlap;
		[endFrames replaceObjectAtIndex:index withObject:[NSValue valueWithRect:tmp]];
	}
	
//	NSLog(@"removing %@", selected);
	[resViews removeObjectsInArray:selected];
//	NSLog(@"removed");
	[self setNeedsDisplay:YES];
	NSDate* d = [NSDate date];
	while (-[d timeIntervalSinceNow] < 0.1)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	float duration = 0;
	if ([objectsToMove count] > 0)	{
		duration = 0.1;
		NSDictionary* aniDict = [NSDictionary dictionaryWithObjectsAndKeys:
			startFrames, @"StartFrames", endFrames, @"EndFrames", [NSNumber numberWithFloat:duration], @"Duration",
			objectsToMove, @"ObjectsToMove", [NSDate date], @"StartTime", nil];
			
		animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(slideHorizontal:) userInfo:aniDict repeats:YES];
	}
	
	[self performSelector:@selector(doHorizontalRemoveAnimation:) withObject:selected afterDelay:0.1 + duration];
	
}

-(void) doHorizontalRemoveAnimation:(NSArray*)removedObjects	{
	PP;
	
//	NSLog(@"removed objects = %@", removedObjects);
	NSArray* types = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	NSMutableDictionary* removedDict = [NSMutableDictionary dictionary];
	int i;
	NSMutableArray* arr;
	for (i = 0; i < [types count]; i++)	{
		[dict setValue:[NSMutableArray array] forKey:[types objectAtIndex:i]];
		[removedDict setValue:[NSMutableArray array] forKey:[types objectAtIndex:i]];
	}
	
	for (i = 0; i < [resViews count]; i++)	{
		arr = [dict objectForKey:[[resViews objectAtIndex:i] type]];
		[arr addObject:[resViews objectAtIndex:i]];
	}
	for (i = 0; i < [removedObjects count]; i++)	{
		arr = [removedDict objectForKey:[[removedObjects objectAtIndex:i] type]];
		[arr addObject:[removedObjects objectAtIndex:i]];
	}
//	NSLog(@"removedDict = %@", removedDict);
	
	NSMutableArray* needsShifted = [NSMutableArray array];
	NSMutableArray* leftoverForRes;
	NSString* typeToTest;
	int j;
	NSInteger index;

	for (i = 0; i < [resViews count]; i++)	{
		typeToTest = [[resViews objectAtIndex:i] type];
		index = [types indexOfObject:typeToTest];
		for (j = 0; j < index; j++)	{
			leftoverForRes = [dict objectForKey:[types objectAtIndex:j]];
			arr = [removedDict objectForKey:[types objectAtIndex:j]];
			if ([leftoverForRes count] == 0 && [arr count] > 0)
					[needsShifted addObject:[resViews objectAtIndex:i]];
		}
	//	NSLog(@"leftover = %@, removed = %@", leftoverForRes, arr);
	}
	/*
	for (i = 0; i < [needsShifted count]; i++)	{
		NSLog(@"NEEDS SHIFTED: %@", [[needsShifted objectAtIndex:i] type]);
	}*/
	
	NSMutableArray* objectsToShift = [NSMutableArray array];
	NSMutableArray* startFrames = [NSMutableArray array];
	NSMutableArray* endFrames = [NSMutableArray array];
	NSRect tmp;
//	NSSize size = [[[NSImage imageNamed:@"BrickRes.tiff"] autorelease] size];
//	NSSize size = [[NSImage imageNamed:@"BrickRes.tiff"] size];
	NSSize size = [[NSImage imageNamed:@"BrickRes"] size];

	size.width = (int)(size.width / scaleFactor);
	size.height = (int)(size.height / scaleFactor);
	for (i = 0; i < [needsShifted count]; i++)	{
		index = [objectsToShift indexOfObject:[needsShifted objectAtIndex:i]];
		if (index == NSNotFound)	{
			[objectsToShift addObject:[needsShifted objectAtIndex:i]];
			[startFrames addObject:[NSValue valueWithRect:[[needsShifted objectAtIndex:i] frame]]];
			[endFrames addObject:[NSValue valueWithRect:[[needsShifted objectAtIndex:i] frame]]];
			index = [objectsToShift count] - 1;
		}
		tmp = [[endFrames objectAtIndex:index] rectValue];
		tmp.origin.x -= (xMargin + size.width);
		[endFrames replaceObjectAtIndex:index withObject:[NSValue valueWithRect:tmp]];
	}
	
	NSDictionary* aniDict = [NSDictionary dictionaryWithObjectsAndKeys:
		startFrames, @"StartFrames", endFrames, @"EndFrames", objectsToShift, @"ObjectsToMove",
		[NSNumber numberWithFloat:0.1], @"Duration", [NSDate date], @"StartTime", nil];

	if ([objectsToShift count] > 0)	
		animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(slideHorizontal:) userInfo:aniDict repeats:YES];
}	
	
-(void) slideHorizontal:(NSTimer*)timer	{
//	NSLog(@"sliding");
	[self setNeedsDisplay:YES];
	animating = YES;

	NSDictionary* info = [timer userInfo];
	NSArray* endFrames = [info objectForKey:@"EndFrames"];
	float duration = [[info objectForKey:@"Duration"] floatValue];
	NSDate* startTime = [info objectForKey:@"StartTime"];
	NSArray* objects = [info objectForKey:@"ObjectsToMove"];
	int i;
	if (-[startTime timeIntervalSinceNow] > duration)	{
		for (i = 0; i < [objects count]; i++)	{
			[[objects objectAtIndex:i] setFrame:[[endFrames objectAtIndex:i] rectValue]];
		}
		animating = NO;
		[timer invalidate];
		animationTimer = nil;
		return;
	}
	
	NSArray* startFrames = [info objectForKey:@"StartFrames"];
	NSRect sFrame;
	NSRect eFrame;
	NSRect frame;
	float percent = -[startTime timeIntervalSinceNow] / duration;
	for (i = 0; i < [objects count]; i++)	{
		sFrame = [[startFrames objectAtIndex:i] rectValue];
		eFrame = [[endFrames objectAtIndex:i] rectValue];
		
		frame.origin.x = sFrame.origin.x + percent * (eFrame.origin.x - sFrame.origin.x);
		frame.origin.y = sFrame.origin.y + percent * (eFrame.origin.y - sFrame.origin.y);
		frame.size.width = sFrame.size.width + percent * (eFrame.size.width - sFrame.size.width);
		frame.size.height = sFrame.size.height + percent * (eFrame.size.height - sFrame.size.height);
		
		[[objects objectAtIndex:i] setFrame:frame];
	}
}

- (void)drawRect:(NSRect)rect	{
	NSColor* bg = [NSColor purpleColor];
	bg = [bg blendedColorWithFraction:0.6 ofColor:[NSColor blueColor]];
	bg = [bg blendedColorWithFraction:0.5 ofColor:[NSColor whiteColor]];

	[bg set];
	[NSBezierPath fillRect:[self bounds]];
	
	[[NSColor blackColor] set];
	[NSBezierPath strokeRect:[self bounds]];
	
/*	[self drawCards];
	
	if (selecting)	{
		NSRect r = [self selectionRect];
	
		[[[NSColor lightGrayColor] colorWithAlphaComponent:0.5] set];
		[NSBezierPath fillRect:r];
		[[NSColor whiteColor] set];
		//[NSBezierPath strokeRect:r];
		[[self thinRect:r] fill];
	}*/
	
//	[[NSColor redColor] set];
//	[NSBezierPath strokeRect:tmpRectToDraw];
}

-(void) drawCards	{
	int i;
	NSImage* image;
	NSRect rect;
	for (i = 0; i < [resViews count]; i++)	{
		rect = [[resViews objectAtIndex:i] frame];
		image = [[resViews objectAtIndex:i] image];
		
		[image drawInRect:rect fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
	}
}

-(NSBezierPath*) thinRect:(NSRect)rect	{
	NSPoint p = rect.origin;
	NSSize sz = rect.size;
	NSBezierPath* path = [NSBezierPath bezierPath];
	[path appendBezierPathWithRect:NSMakeRect(p.x, p.y, sz.width, 1)];
	[path appendBezierPathWithRect:NSMakeRect(p.x + sz.width, p.y, 1, sz.height)];
	[path appendBezierPathWithRect:NSMakeRect(p.x, p.y + sz.height, sz.width, 1)];
	[path appendBezierPathWithRect:NSMakeRect(p.x, p.y, 1, sz.height)];
	
	return path;
}

-(NSPoint) locationForItem:(int)i	{
	return NSMakePoint(20 * i + 5, 50);
}
-(NSSize) itemSize	{
	return NSMakeSize(20, 20);
}


-(NSImage*) imageForItem:(NSString*)str	{
	NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(20, 20)];
	[image setScalesWhenResized:YES];
	
	[image lockFocus];
	[[NSColor redColor] set];
	[NSBezierPath fillRect:NSMakeRect(0, 0, 20, 20)];
	[str drawAtPoint:NSMakePoint(0, 0) withAttributes:nil];
	[[NSColor blackColor] set];
	[NSBezierPath strokeRect:NSMakeRect(0, 0, 20, 20)];
	[image unlockFocus];
	
	return image;
}





-(NSRect) selectionRect	{
	NSRect r;
	NSPoint bl;
	NSPoint tr;
	if (cornerOne.x <= 0 || cornerTwo.x <= 0 || cornerOne.y <= 0 || cornerTwo.y <= 0)
		return NSMakeRect(0, 0, 0, 0);
	if (cornerOne.x < cornerTwo.x)	{
		bl.x = cornerOne.x;
		tr.x = cornerTwo.x;
	}
	else	{
		bl.x = cornerTwo.x;
		tr.x = cornerOne.x;
	}
	
	if (cornerOne.y < cornerTwo.y)	{
		bl.y = cornerOne.y;
		tr.y = cornerTwo.y;
	}
	else	{
		bl.y = cornerTwo.y;
		tr.y = cornerOne.y;
	}
		
		
	NSSize sz = NSMakeSize(tr.x - bl.x, tr.y - bl.y);
	r = NSMakeRect(bl.x, bl.y, sz.width, sz.height);

	return r;
}

-(void) deselectAll	{
	PP;
	int i;
	for (i = 0; i < [resViews count]; i++)	{
		[[resViews objectAtIndex:i] setSelected:NO];
	}
}
-(void) mouseDown:(NSEvent*)event	{
	PP;
	int i;
	NSPoint p = [event locationInWindow];
	downPoint = p;
	p = [self convertPoint:p fromView:[[self window] contentView]];
	

	BOOL shift = ([event modifierFlags] & (NSShiftKeyMask | NSCommandKeyMask)) !=0;
	BOOL inCardRect = NO;
//	ResViewRep* clickedCard = [self viewForLocation:p];
	ResView* clickedCard = [self viewForLocation:p];
	/*
	for (i = 0; i < [resViews count]; i++)	{
		if (NSMouseInRect(p, [[resViews objectAtIndex:i] frame], NO))	{
			inCardRect = YES;
			if ([[resViews objectAtIndex:i] selected] == NO && shift == NO)
				[self deselectAll];
			if (shift)
				[[resViews objectAtIndex:i] toggleSelected];
			else
				[[resViews objectAtIndex:i] setSelected:YES];

		}			
	}
	*/
	if (clickedCard)	{
		if ([clickedCard selected] == NO && shift == NO)
			[self deselectAll];
		if (shift)
			[clickedCard toggleSelected];
		else
			[clickedCard setSelected:YES];
	}
	if (clickedCard == nil && shift == NO)
		[self deselectAll];
	
	[self setNeedsDisplay:YES];
	
}	

-(void) mouseDragged:(NSEvent*)event	{
//	PP;
	BOOL shift = ([event modifierFlags] & (NSShiftKeyMask | NSCommandKeyMask)) != 0;
	NSPoint p = [event locationInWindow];
	p = [self convertPoint:p fromView:[[self window] contentView]];
	
	BOOL inSelectedCardBounds = NO;
	int i;
	if (selecting == NO)	{
		for (i = 0; i < [resViews count]; i++)	{
			//if (NSMouseInRect(p, [[resViews objectAtIndex:i] frame], NO) && [[resViews objectAtIndex:i] selected])
			if (NSMouseInRect(p, [self visibleRectForItem:[resViews objectAtIndex:i]], NO) && [[resViews objectAtIndex:i] selected])
				inSelectedCardBounds = YES;
		}
	}
	
	if (inSelectedCardBounds == YES)	{
		[self beginDrag:event];
		return;
	}
	else	{
		if (selecting == YES)	{
			cornerTwo = p;
		}
		else	{
			cornerOne = p;
			selecting = YES;
		}
	}	
	
	NSRect rect = [self selectionRect];
	[selectionView setRect:rect];
	[selectionView setShouldDraw:YES];
	NSRect iSect;
	for (i = 0; i < [resViews count]; i++)	{
		//iSect = NSIntersectionRect(rect, [[resViews objectAtIndex:i] frame]);
		iSect = NSIntersectionRect(rect, [self visibleRectForItem:[resViews objectAtIndex:i]]);
		if (iSect.size.width > 0 ||  iSect.size.height > 0)	{
//			tmpRectToDraw = [self visibleRectForItem:[resViews objectAtIndex:i]];
//			[self setNeedsDisplay:YES];
			[[resViews objectAtIndex:i] setSelected:YES];
		}
		else	{
			if (shift == NO || [previouslySelected indexOfObject:[resViews objectAtIndex:i]] == NSNotFound)
				[[resViews objectAtIndex:i] setSelected:NO];
		}
	}
	[self setNeedsDisplay:YES];
/*
	check to see if it's a selectioin drag, or a drag to move stuff to another view
	*/
}

-(void) mouseUp:(NSEvent*)event		{
	PP;
	NSPoint p = [event locationInWindow];
	p = [self convertPoint:p fromView:[[self window] contentView]];
	[selectionView setShouldDraw:NO];
//	p.x -= [self frame].origin.x;
//	p.y -= [self frame].origin.y;
	
	selecting = NO;
	[self setNeedsDisplay:YES];
	int i;
	[previouslySelected removeAllObjects];
	for (i = 0; i < [resViews count]; i++)	{
		if ([[resViews objectAtIndex:i] selected])
			[previouslySelected addObject:[resViews objectAtIndex:i]];
	}
	
	cornerOne = NSMakePoint(0, 0);
}


-(void) beginDrag:(NSEvent*)event	{
	float w = 20;
	float h = 20;
	int i;
	[previouslySelected removeAllObjects];
	int count = 0;

	NSMutableArray* thingsToDrag = [NSMutableArray array];
	for (i = 0; i < [resViews count]; i++)	{
		if ([[resViews objectAtIndex:i] selected])	{
			count++;
			[previouslySelected addObject:[resViews objectAtIndex:i]];
			[thingsToDrag addObject:[[resViews objectAtIndex:i] type]];
		}
	}

//	NSImage* image = [self buildDragImage];
	NSPoint p = [event locationInWindow];
	p = [self convertPoint:p fromView:[[self window] contentView]];
//	ResViewRep* v = [self viewForLocation:p];
	ResView*v = [self viewForLocation:p];
	NSPoint translation = NSMakePoint(p.x - [v frame].origin.x, p.y - [v frame].origin.y);
//	NSLog(@"translation = %@", NSStringFromPoint(translation));
	NSSize offset = NSMakeSize(p.x - downPoint.x, p.y - downPoint.y);
//	NSSize offset = NSMakeSize(-200, -200);
	NSImage* image = [self buildDragImageAndTranslatePoint:&translation forResource:[v type]];
//-(NSImage*) buildDragImageAndTranslatePoint:(NSPoint*)pointToTranslate forResource:(NSString*)theRes	{
//	NSLog(@"now, translation = %@", NSStringFromPoint(translation));
//	p.x -= [image size].width / 2;
//	p.y -= [image size].height / 2;
//	p.x -= [image size].width;
//	p.y -= [image size].height;
	p.x -= translation.x;
	p.y -= translation.y;
    NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	[pboard declareTypes:[NSArray arrayWithObject:@"CATAN_RESOURCE_TYPE"] owner:self];
//	int i;
	
	[pboard setPropertyList:thingsToDrag forType:@"CATAN_RESOURCE_TYPE"];
//	[pboard setString:@"Blah" forType:@"Blah"];
	[self dragImage:image at:p offset:offset event:event pasteboard:pboard source:self slideBack:YES];
}

//-(ResViewRep*) viewForLocation:(NSPoint)p	{
-(ResView*) viewForLocation:(NSPoint)p	{
	int i;
	for (i = [resViews count] - 1; i >= 0; i--)	{
		if (NSMouseInRect(p, [[resViews objectAtIndex:i] frame], NO))
			return [resViews objectAtIndex:i];
	}
	
	return nil;
}

//-(NSRect) visibleRectForItem:(ResViewRep*)rep	{
-(NSRect) visibleRectForItem:(ResView*)rep	{
	NSString* type = [rep type];
	NSMutableArray* arr = [NSMutableArray array];
	int i;
	for (i = 0; i < [resViews count]; i++)	{
		if ([type isEqualToString:[[resViews objectAtIndex:i] type]])	{
	//		NSLog(@"frame %d = %@", [arr count] + 1, NSStringFromRect([[resViews objectAtIndex:i] frame]));
			[arr addObject:[resViews objectAtIndex:i]];
		}
	}
	
	i = [arr indexOfObject:rep];
	if (i == [arr count] - 1)
		return [rep frame];
		
	NSRect cardFrame = [rep frame];
	NSRect overlappingFrame = [[arr objectAtIndex:i + 1] frame];
	NSRect vRect = NSMakeRect(cardFrame.origin.x, overlappingFrame.origin.y + overlappingFrame.size.height, cardFrame.size.width, (cardFrame.origin.y + cardFrame.size.height) - (overlappingFrame.origin.y + overlappingFrame.size.height));
//	NSLog(@"vRect = %@", NSStringFromRect(vRect));
	return vRect;
}	


- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation	{
	PP;
	if (operation == NSDragOperationNone)	{
		int i;
		for (i = 0; i < [resViews count]; i++)	{
			if ([previouslySelected indexOfObject:[resViews objectAtIndex:i]] != NSNotFound)
				[[resViews objectAtIndex:i] setSelected:YES];
			else
				[[resViews objectAtIndex:i] setSelected:NO];
		}
	}
	
	else 
		[self removeSelected];
		
}


-(NSImage*) buildDragImageAndTranslatePoint:(NSPoint*)pointToTranslate forResource:(NSString*)theRes	{
	PP;
	int i;
	int counts[5] = {0};
	NSArray* types = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	
	int index;
	for (i = 0; i < [resViews count]; i++)	{
		if ([[resViews objectAtIndex:i] selected])	{
			index = [types indexOfObject:[[resViews objectAtIndex:i] type]];
			if (index == NSNotFound)	{
				NSLog(@"no type named %@", [[resViews objectAtIndex:i] type]);
			}
			else	{
				counts[index]++;
			}
		}
	}
	int resCount = 0;
	for (i = 0; i < 5; i++)	{
		if (counts[i] > 0)
			resCount++;
	}
	float margin = 0;
//	NSImage* badge = [[NSImage imageNamed:@"dragBadge.tiff"] autorelease];
//	NSImage* badge = [NSImage imageNamed:@"dragBadge.tiff"];
	NSImage* badge = [NSImage imageNamed:@"dragBadge.png"];
	NSSize badgeSize = [badge size];

//	NSSize sz = [[[NSImage imageNamed:@"BrickRes.tiff"] autorelease] size];
	NSSize sz = [[NSImage imageNamed:@"BrickRes"] size];

	sz.width = (int)(sz.width / scaleFactor);
	sz.height = (int)(sz.height / scaleFactor);
	NSImage* newImage = [[[NSImage alloc] initWithSize:NSMakeSize((sz.width + badgeSize.width  / 2) * resCount + margin * (resCount - 1), sz.height + badgeSize.height / 2)] autorelease];
//	NSSize badgeSize = [[NSImage imageNamed:@"dragBadge.tiff"] size];
	[newImage setScalesWhenResized:YES];
	NSPoint p = NSMakePoint(0, 0);
	NSImage* image;
//	NSLog(@"drawing");
	[newImage lockFocus];
	NSDictionary* atts = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont boldSystemFontOfSize:12], NSFontAttributeName,
		[NSColor whiteColor], NSForegroundColorAttributeName, nil];
	NSAttributedString* attStr;
	NSRect badgeRect;
	for (i = 0; i < 5; i++)	{
		if (counts[i] > 0)	{
			if ([[types objectAtIndex:i] isEqualToString:theRes])	{
//				NSLog(@"changing translation point");
				pointToTranslate->x += p.x;
				pointToTranslate->y += badgeSize.height / 2;
			}
			image = [self imageForType:[types objectAtIndex:i]];
			[image drawInRect:NSMakeRect(p.x, p.y + badgeSize.height / 2, sz.width, sz.height) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:0.6];
			badgeRect = NSMakeRect(p.x + sz.width - (badgeSize.width / 2), 0, badgeSize.width, badgeSize.height);
			[badge drawInRect:badgeRect fromRect:NSMakeRect(0, 0, badgeSize.width, badgeSize.height) operation:NSCompositeSourceOver fraction:1.0];
			attStr = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", counts[i]] attributes:atts] autorelease];
			[attStr drawAtPoint:NSMakePoint( badgeRect.origin.x + (badgeRect.size.width - [attStr size].width) / 2, badgeRect.origin.y + (badgeRect.size.height - [attStr size].height) / 2)];
			p.x += (sz.width + margin + badgeSize.width / 2);
		}
	}
//	[[NSColor blackColor] set];
//	[NSBezierPath strokeRect:NSMakeRect(0, 0, [newImage size].width - 1, [newImage size].height - 1)];
	[newImage unlockFocus];
	return newImage;
//	NSImage* realImage = [[[NSImage alloc] initWithSize:[newImage size]] autorelease];
//	[realImage lockFocus];
//	[newImage drawInRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height) fromRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height) operation:NSCompositeSourceOver fraction:0.6];
//	[realImage unlockFocus];
	
//	return realImage;
//	[newImage setSize:NSMakeSize([newImage size].width / 1.5, [newImage size].height / 1.5)];
//	return newImage;
	
}

-(NSImage*) imageForType:(NSString*)str	{
//	NSLog(@"type = %@", str);
	NSString* name = [NSString stringWithFormat:@"%@Res.tiff", str];
//	NSLog(@"name = %@", name);
//	NSImage* image = [[NSImage imageNamed:name] autorelease];
	NSImage* image = [NSImage imageNamed:name];
	
//	NSLog(@"image = %@", image);
	
	return image;
}



-(NSArray*) animationsToRemoveSelectedResources	{

}


-(NSArray*) animationsToRemoveResources:(NSArray*)arr	{

}


@end

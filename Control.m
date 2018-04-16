#import "Control.h"
#import "BoardView.h"
#import "AnimatedCardWindow.h"
#import "NSImage-Additions.h"
#import "NSBezierPath-Additions.h"
#define PP NSLog(@"%s", __FUNCTION__)
@implementation Control

static int cheat = 1;

-(id) init	{
	self = [super init];
	if (self)	{
		[self buildExtraImages];
		rollFrequencyController = [[RollFrequencyController alloc] init];
		[[GameController gameController] setInterface:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resChanged2:) name:@"RESOURCE_CHANGED_NOTIFICATION_FOR_ITEM_TABLE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resChanged:) name:@"RESOURCES_CHANGED_NOTIFICATION" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roadBuilderPlayed:) name:@"ROAD_BUILDER_PLAYED" object:nil];
		purchaseTableDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSArray arrayWithObjects:@"Road", @"Settlement", @"City", @"Dev. Card", nil], @"Item",
			[self purchaseTableImages], @"Cost", 
			//[NSArray arrayWithObjects:@"B W", @"B W G S", @"2G 3O", @"S G O", nil], @"Cost",
			[NSMutableArray arrayWithObjects:[NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], nil], @"Enabled", nil];
//		NSLog(@"here");
		[purchaseTableDictionary retain];
	//	[NSBundle loadNibNamed:@"GameControl.nib" owner:self];

//		NSLog(@"inited control");
//		buildingArray = [NSArray arrayWithObjects:@"Road", @"Settlement", @"City", @"Development Card", nil];
//		[buildingArray retain];
	}
	return self;
}

-(NSArray*) purchaseTableImages	{
	NSMutableArray* tmp = [NSMutableArray array];
	NSImage* image;
	float margin = 3.0;
	NSImage* brick = [NSImage imageNamed:@"BrickRes.tiff"];
	NSImage* grain = [NSImage imageNamed:@"GrainRes.tiff"];
	NSImage* ore = [NSImage imageNamed:@"OreRes.tiff"];
	NSImage* sheep = [NSImage imageNamed:@"SheepRes.tiff"];
	NSImage* wood = [NSImage imageNamed:@"WoodRes.tiff"];
	
	[tmp addObject:[self imageWithArrayOfImages:[NSArray arrayWithObjects:brick, wood, nil] margin:3.0]];
	[tmp addObject:[self imageWithArrayOfImages:[NSArray arrayWithObjects:brick, wood, sheep, grain, nil] margin:3.0]];
	[tmp addObject:[self imageWithArrayOfImages:[NSArray arrayWithObjects:grain, grain, ore, ore, ore, nil] margin:3.0]];
	[tmp addObject:[self imageWithArrayOfImages:[NSArray arrayWithObjects:sheep, grain, ore, nil] margin:3.0]];

	return tmp;
}

-(NSImage*) imageWithArrayOfImages:(NSArray*)arr margin:(float)margin	{
	float w = 0;
	int i;
	for (i = 0; i < [arr count]; i++)	{
		w += [[arr objectAtIndex:i] size].width;
	}
	w += margin * ([arr count] - 1);
	
	NSImage* newImage = [[[NSImage alloc] initWithSize:NSMakeSize(w, [[arr objectAtIndex:0] size].height)] autorelease];
	[newImage setScalesWhenResized:YES];
	NSPoint p = NSMakePoint(0, 0);
	[newImage lockFocus];
	for (i = 0; i < [arr count]; i++)	{
		[[arr objectAtIndex:i] compositeToPoint:p operation:NSCompositeSourceOver];
		p.x += ([[arr objectAtIndex:i] size].width + margin);
	}
	[newImage unlockFocus];
	
	return newImage;
}

-(void) roadBuilderPlayed:(NSNotification*)note	{
//	[self resChanged:[note object]];
	[self resChanged:note];
}

-(void) outlineViewItemWillExpand:(NSNotification*)note	{
//	NSLog(@"outlineViewItemWillExpand");
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item	{
//	NSLog(@"shouldExpandItem");
	return NO;
}


-(void) resChanged:(NSNotification*)note	{
	[self updateItemTable:note];
	[resourceView reloadData];

}

-(void) resChanged2:(NSNotification*)note	{
	[self updateItemTable:note];
}

//-(void) resChanged:(NSNotification*)note	{
-(void) updateItemTable:(NSNotification*)note	{
//	[resourceTable setDataSource:[note object]];
//	[resourceTable setDelegate:[note object]];

	
//	NSLog(@"resChanged:");
	if ([[GameController gameController] canBuildRoad])
		[[purchaseTableDictionary objectForKey:@"Enabled"] replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:YES]];
	else
		[[purchaseTableDictionary objectForKey:@"Enabled"] replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:NO]];
	
	if ([[GameController gameController] canBuildSettlement])	{
		//NSLog(@"sett = YES");
		[[purchaseTableDictionary objectForKey:@"Enabled"] replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:YES]];
	}
	else	{
		[[purchaseTableDictionary objectForKey:@"Enabled"] replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:NO]];
		//NSLog(@"sett = NO");
	}

	if ([[GameController gameController] canBuildCity])
		[[purchaseTableDictionary objectForKey:@"Enabled"] replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:YES]];
	else
		[[purchaseTableDictionary objectForKey:@"Enabled"] replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:NO]];
		

	if ([[GameController gameController] canBuildDevCard])
		[[purchaseTableDictionary objectForKey:@"Enabled"] replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:YES]];
	else
		[[purchaseTableDictionary objectForKey:@"Enabled"] replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:NO]];
		

	[purchaseTable reloadData];
//	[resourceTable reloadData];
//	[resourceOutline reloadData];

}

	



-(void) awakeFromNib	{
//	NSLog(@"waking from nib");
	[window setDisplaysWhenScreenProfileChanges:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowUpdated:) name:NSWindowDidUpdateNotification object:window];
//	[window useOptimizedDrawing:YES];
//	NSView* cView = [window contentView];
//	NSRect vRect = [cView bounds];
//	frameView = [[FrameView alloc] initWithFrame:vRect];
//	[cView addSubview:frameView];
//	[frameView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
//	[chatInputField makeF
//	[tableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
//	[tableView setVerticalMotionCanBeginDrag:YES];
	NSArray* cols = [purchaseTable tableColumns];
	int i;
	for (i = 0; i < [cols count]; i++)	{
		if ([[[cols objectAtIndex:i] identifier] isEqualToString:@"Item"])	{
//			[[cols objectAtIndex:i] setDataCell:[[[ImageAndTextCell alloc] init] autorelease]];
            [[cols objectAtIndex:i] setDataCell:[[[NSImageCell alloc] init] autorelease]];
            [[[cols objectAtIndex:i] dataCell] setImageAlignment:NSImageAlignLeft];

		}
		if ([[[cols objectAtIndex:i] identifier] isEqualToString:@"Cost"])	{
			[[cols objectAtIndex:i] setDataCell:[[[NSImageCell alloc] init] autorelease]];
			[[[cols objectAtIndex:i] dataCell] setImageAlignment:NSImageAlignLeft];
		}
			//[[cols objectAtIndex:i] setDataCell:[[[PurchaseTableItemCell alloc] init] autorelease]];
		
	}
	[purchaseTable setDraggingSourceOperationMask:NSDragOperationCopy forLocal:YES];
	[purchaseTable setVerticalMotionCanBeginDrag:YES];
	
//	[resourceTable setDraggingSourceOperationMask:NSDragOperationCopy forLocal:YES];
//	[resourceTable setVerticalMotionCanBeginDrag:YES];

//	[resourceOutline setDraggingSourceOperationMask:NSDragOperationCopy forLocal:YES];
//	[resourceOutline setVerticalMotionCanBeginDrag:YES];
	
		
	
	[boardView registerForDraggedTypes:[NSArray arrayWithObject:@"CATAN_BOARD_VERTEX_TYPE"]];
	[boardView registerForDraggedTypes:[NSArray arrayWithObject:@"CATAN_BOARD_EDGE_TYPE"]];

	[bankView registerForDraggedTypes:[NSArray arrayWithObject:@"CATAN_RESOURCE_TYPE"]];

	[devCardTable registerForDraggedTypes:[NSArray arrayWithObject:@"CATAN_PLAYER_DEV_CARD_TYPE"]];

	[[[[devCardTable tableColumns] objectAtIndex:0] dataCell] setEditable:NO];
//	[[[[resourceOutline tableColumns] objectAtIndex:0] dataCell] setEditable:NO];


	id obj = [[GameController gameController] localPlayer];
	[devCardTable setDataSource:obj];
	[devCardTable setDelegate:obj];
	[devCardTable setTarget:obj];
	[devCardTable setDoubleAction:@selector(tableViewDoubleClick:)];

//	[resourceOutline setDataSource:obj];
//	[resourceOutline setDelegate:obj];
//	[resourceOutline setTarget:obj];
//	[resourceOutline setDoubleAction:@selector(resourceTableDoubleClicked:)];
	[resourceView setDataSource:obj];
	[obj setResourceView:resourceView];
//	[NSApp setDelegate:self];
//	[frameView setFrameColor:[[[GameController gameController] localPlayer] color]]; 
	
	Player* localPlayer = [[GameController gameController] localPlayer];

	[playerView1 setLocation:TopLeft];
	[playerView2 setLocation:TopRight];
	[playerView3 setLocation:BottomRight];
	[playerView4 setLocation:BottomLeft];
	
	NSArray* tmpJunkArray = [NSArray arrayWithObjects:playerView1, playerView2, playerView3, playerView4, nil];
	NSArray* players = [[GameController gameController] players];
	int offset = [players indexOfObject:localPlayer];
	int index;
	//orange... offset = 2
	//
	NSMutableArray* tmpViewArray = [NSMutableArray array];
	for (i = 0; i < [players count]; i++)	{
		index = i - offset;
		if (index < 0)
			index += [players count];
//		if (index >= [players count])
//			index -= [players count];
		[tmpViewArray addObject:[tmpJunkArray objectAtIndex:index]];
		[[tmpJunkArray objectAtIndex:index] setPlayer:[players objectAtIndex:i]];
	}
	
	playerViews = [NSArray arrayWithArray:tmpViewArray];
	[playerViews retain];
	/*
	int counter = 0;
	for (i = 0; i < [players count]; i++)	{
		
	}
	while (counter < [players count])	{
	
	}*/
	
	[self update];
	[self resChanged:nil];
	[[chatInputField window] makeFirstResponder:chatInputField];

//	AnimatedCardView* acv = [[[AnimatedCardView alloc] initWithFrame:NSMakeRect(0, 0, [[window contentView] frame].size.width, [[window contentView] frame].size.height)] autorelease];
//	cardView = [acv retain];
//	NSArray* subs = [[window contentView] subviews];
//	[[window contentView] addSubview:acv positioned:NSWindowAbove relativeTo:[subs objectAtIndex:[subs count] - 1]];
//	NSLog(@"woke");

	NSMenuItem* item = [[NSMenuItem alloc] init];
	[item setTarget:self];
	[item setAction:@selector(openRollLog:)];
	[item setTitle:@"Roll Frequency"];
	
	NSMenu* menu = [NSApp mainMenu];
	NSMenu* windowsMenu = [[menu itemWithTitle:@"Window"] submenu];
//	NSLog(@"windowsMenu = %@", windowsMenu);
	[windowsMenu addItem:item];
	
	AnimatedCardWindow* acw = [[AnimatedCardWindow alloc] initWithWindow:window];
//-(id) initWithAnimationLayer:(AnimatedCardView*)acv playerViews:(NSArray*)arr bankView:(BankView*)bank boardView:(BoardView*)board resourceView:(CollectionView*)cv;

	ResourceManager* rm = [[ResourceManager alloc] initWithAnimationLayer:[acw contentView] playerViews:playerViews bankView:bankView boardView:boardView resourceView:resourceView];

	[[GameController gameController] setResourceManager:rm];
//	NSLog(@"control woke");
//	[animatedCardWindow orderFrontRegardless];
//	[animatedCardWindow orderWindow:NSWindowAbove relativeTo:[window windowNumber]];
//	[acw open];
	[[GameController gameController] interfaceBecameActive];

//	[NSApp updateWindows];
}


-(void) windowUpdated:(NSNotification*)note	{
//	NSLog(@"WINDOW UPDATED");
	if ([window isVisible])		{
//		NSLog(@"IT'S VISIBLE");
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidUpdateNotification object:window];
//		[[GameController gameController] interfaceBecameActive];
	}
}
-(void)windowDidBecomeMain:(NSNotification *)aNotification	{
//	NSLog(@"WINDOW BECAME MAIN");
//	[[GameController gameController] interfaceBecameActive];
}



- (void)windowDidBecomeKey:(NSNotification *)aNotification	{
//	NSLog(@"WINDOW BECAME KEY");
}


-(void)windowDidChangeScreen:(NSNotification *)aNotification	{
//	NSLog(@"WINDOW MOVED TO SCREEN");
}

-(void) windowDidChangeScreenProfile:(NSNotification*)note	{
//	NSLog(@"WINDOW CHANGED SCREEN PROFILE");
}

-(void) windowDidDeminiaturize:(NSNotification*)note	{
//	NSLog(@"WINDOW DEMINIATURIZED");
}

-(void) windowDidMove:(NSNotification*)Note	{
//	NSLog(@"WINDOW DID MOVE");
}

-(void) windowDidResize:(NSNotification*)note	{
//	NSLog(@"WINDOW DID RESIZE");
}	


- (void)windowDidExpose:(NSNotification *)aNotification	{
//	NSLog(@"window did expose");
}




-(AnimatedCardView*) animatedCardView	{
	return [animatedCardWindow contentView];
}

-(void) openRollLog:(id)sender	{
//	NSLog(@"opening roll log");
	BOOL flag = [NSBundle loadNibNamed:@"RollFrequency.nib" owner:rollFrequencyController];
//	NSLog(@"success = %d", flag);
}



-(int) numberOfRowsInTableView:(NSTableView*)tv	{
//	return [buildingArray count];
	if (tv == purchaseTable)
		return 4;
	
	return 0;
}
/*
-(id) tableView:(NSTableView*)tv objectValueForTableColumn:(NSTableColumn*)tc row:(int)r	{
//	return @"Thing to drag";
	
	return [[purchaseTableDictionary objectForKey:[tc identifier]] objectAtIndex:r];
//	return [buildingArray objectAtIndex:r];
}*/





- (void)tableView:(NSTableView *)tv willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tc row:(int)r	{
//	return;
//	NSLog(@"displaying %@, %d", [tc identifier], r);
	NSAttributedString* attString = nil;
	BOOL enabledFlag = NO;
	NSDictionary* atts = nil;
	NSString* string;
	if (tv == purchaseTable)	{
		if ([[tc identifier] isEqualToString:@"Item"])	{
			string = [[purchaseTableDictionary objectForKey:[tc identifier]] objectAtIndex:r];
			if ([string isEqualToString:@"Settlement"])
				string = [string stringByAppendingFormat:@" (%d)", [[GameController gameController] availableSettlementsForLocalPlayer]];
			else if ([string isEqualToString:@"City"])
				string = [string stringByAppendingFormat:@" (%d)", [[GameController gameController] availableCitiesForLocalPlayer]];
	
			enabledFlag = [[[purchaseTableDictionary objectForKey:@"Enabled"] objectAtIndex:r] boolValue];
			[cell setEnabled:enabledFlag];
			if (enabledFlag == NO)
				atts = [NSDictionary dictionaryWithObject:[NSColor grayColor] forKey:NSForegroundColorAttributeName];
		//	[cell setStringValue:[[purchaseTableDictionary objectForKey:[tc identifier]] objectAtIndex:r]];
//			attString = [[[NSAttributedString alloc] initWithString:[[purchaseTableDictionary objectForKey:[tc identifier]] objectAtIndex:r] attributes:atts] autorelease];
//			NSLog(@"ITEM TABLE STRING = '%@'", string);
			attString = [[[NSAttributedString alloc] initWithString:string attributes:atts] autorelease];

	//		[cell setAttributedString:attString];
	//		[cell setImage:[tv itemImageForRow:r]];
            
            //-(NSImage*) fullImageForItemColumnRow:(int)row text:(NSAttributedString*)string  {

            [cell setImage:[tv fullImageForItemColumnRow:r text:attString]];
		}
		else	{
//			[cell setStringValue:[[purchaseTableDictionary objectForKey:[tc identifier]] objectAtIndex:r]];
			[cell setImage:[[purchaseTableDictionary objectForKey:[tc identifier]] objectAtIndex:r]];
		}

	}
//	NSLog(@"displayed");
}







- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard	{
//    NSLog(@"%s", __FUNCTION__);
//	PP;
	int index = [rowIndexes firstIndex];
	if ([[[purchaseTableDictionary objectForKey:@"Enabled"] objectAtIndex:index] boolValue] == NO)
		return NO;
	NSString* type;
	if (tv == purchaseTable)	{
		if (index == 0)
			type = @"CATAN_BOARD_EDGE_TYPE";
		else if (index == 3)
			type = @"CATAN_PLAYER_DEV_CARD_TYPE";
		else
			type = @"CATAN_BOARD_VERTEX_TYPE";
	
		[pboard declareTypes:[NSArray arrayWithObject:type] owner:self];
		[pboard setString:[[purchaseTableDictionary objectForKey:@"Item"] objectAtIndex:[rowIndexes firstIndex]] forType:type];

		return YES;
	}
	return NO;
}

-(IBAction) rollDice:(id)sender	{
	int v1 = 1 + rand() % 6;
	int v2 = 1 + rand() % 6;
	if (cheat == 0)	{
		cheat = 1;
		v1 = 1;
		v2 = 1;
	}
	[[GameController gameController] performSelector:@selector(performRoll:) withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:v1], [NSNumber numberWithInt:v2], nil] afterDelay:0.02];

}

-(void) setRollValue1:(int)v1 value2:(int)v2	{
//	NSLog(@"setting roll value");
	NSColor* color = [[[GameController gameController] currentPlayer] color];
	[diceValueField setIntValue:v1 + v2];
	float tInt = [diceView animationLength];
	[diceView setValue1:v1 value2:v2 color:color];
	[rollFrequencyController addRoll:v1 + v2];
//	NSDate* d = [NSDate date];
//	NSDate* endDate = [NSDate dateWithTimeIntervalSinceNow:tInt];
//	while (-[d timeIntervalSinceNow] < tInt)	{
//		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
//	}	
}




-(int) outlineView:(NSOutlineView*)ov numberOfChildrenOfItem:(id)item	{
	PP;
//	NSLog(@"item = %@", item);
	return 0;
}

-(BOOL) outlineView:(NSOutlineView*)ov isItemExpandable:(id)item	{
	return NO;
}

-(id) outlineView:(NSOutlineView*)ov child:(int)index ofItem:(id)item	{
	return nil;
}

-(id) outlineView:(NSOutlineView*)ov objectValueForTableColumn:(NSTableColumn*)tc byItem:(id)item	{
	return @"Fart";
}


-(IBAction) endTurn:(id)sender	{
/*	NSString* str = [rollButton keyEquivalent];
	NSLog(@"KEY EQUIV = %@", str);
	int i;
	for (i = 0; i < [str length]; i++)	{
		NSLog(@"%c, %d", [str characterAtIndex:i], [str characterAtIndex:i]);
	}
	*/
	[[GameController gameController] endTurn];
}



-(void) update	{
	int i, j;
	
	

	for (i = 0; i < [playerViews count]; i++)	{
		[[playerViews objectAtIndex:i] setRobberable:NO];
		[[playerViews objectAtIndex:i] setHighlight:NO];
	}
	[[playerViews objectAtIndex:[[GameController gameController] turnIndex]] setHighlight:YES];
	if ([[GameController gameController] canSteal])	{
		NSArray* robberIndices = [[GameController gameController] robbablePlayerIndices];
		for (j = 0; j < [robberIndices count]; j++)	{
			[[playerViews objectAtIndex:[[robberIndices objectAtIndex:j] intValue]] setRobberable:YES];
		}
	}
	NSString* retKey = [NSString stringWithFormat:@"%c", 13];
	[rollButton setKeyEquivalent:@""];
	[endButton setKeyEquivalent:@""];
	[rollButton setEnabled:NO];
	[endButton setEnabled:NO];
	
	if ([[GameController gameController] localTurn] == NO)	{
		[rollButton setEnabled:NO];
		[endButton setEnabled:NO];
//		[frameView setFrameStyle:0];
	}	else	{
//		NSBeep();
		if ([[GameController gameController] phase] == RollPhase)	{
			[rollButton setEnabled:YES];
			[rollButton setKeyEquivalent:retKey];
//			[frameView setFrameStyle:2];
		} else if([[GameController gameController] phase] == SetupPhase || [[GameController gameController] phase] == ReverseSetupPhase)	{
//			NSLog(@"*** PHASE IS SETUP");
			if ([[GameController gameController] turnCanEnd])	{
//				NSLog(@"CAN END");
				[endButton setEnabled:YES];
				[endButton setKeyEquivalent:retKey];
//				[frameView setFrameStyle:1];
			}
			else	{
//				NSLog(@"CANNOT END");
//				[frameView setFrameStyle:2];
			}
		}	else if ([[GameController gameController] rolled] == NO)	{
			[rollButton setEnabled:YES];
			[rollButton setKeyEquivalent:retKey];
//			[frameView setFrameStyle:2];
		}	else if ([[GameController gameController] turnCanEnd])	{
			[endButton setEnabled:YES];
			[endButton setKeyEquivalent:retKey];
//			[frameView setFrameStyle:1];
		}
	
		else	{
//			PP;
//			NSLog(@"THIS SHOULD NOT HAVE HAPPENED");
		/*
			[rollButton setEnabled:YES];
			[endButton setEnabled:NO];
			[rollButton setKeyEquivalent:retKey];
			[frameView setFrameStyle:2];
		*/
		}
	}
		
}

-(float) diceRollAnimationDelay	{
	return [diceView animationLength] + 0.03;
}

-(void) updateBoardBackground:(BOOL)flag	{
//	[boardView setNeedsDisplay:YES];

	[boardView setNeedsDisplay:YES];
	if (flag)
		[boardView performSelector:@selector(updateBackground) withObject:nil afterDelay:0.01];

//		[boardView updateBackground];

}

-(BoardView*) boardView	{
	return boardView;
}


-(IBAction) sendChat:(id)sender	{
//	NSString* chatString = [NSString stringWithFormat:@"%@\n", [chatInputField stringValue]];
//	[chatInputField setStringValue:@""];
//	NSAttributedString* attStr = [[[NSAttributedString alloc] initWithString:chatString attributes:nil] autorelease];
//	[chatView setEditable:YES];
//	[chatView insertText:attStr];
//	[chatView setEditable:NO];
	if ([@"" isEqualToString:[chatInputField stringValue]])	{
		NSButtonCell* cell = [[chatInputField window] defaultButtonCell];
		[cell performClick:nil];
		
		[[chatInputField window] makeFirstResponder:chatInputField];
		return;
	}
	[[GameController gameController] player:[[GameController gameController] localPlayer] isChatting:[chatInputField stringValue]];
	[chatInputField setStringValue:@""];
	[[chatInputField window] makeFirstResponder:chatInputField];
//	[chatInputField makeFirst
}


-(void) player:(Player*)p chat:(NSString*)str	{
	NSDictionary* fontAtt = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont fontWithName:@"Courier" size:12], NSFontAttributeName,
		[NSColor blackColor], NSForegroundColorAttributeName, nil];
	NSDictionary* colorFontAtt = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont fontWithName:@"Courier" size:12], NSFontAttributeName,
		[p color], NSForegroundColorAttributeName, nil];
//	NSFontDescriptor* desc = [NSFontDescriptor fontDescriptorWithSymbolicTraits:NSFontBoldTrait];
//	NSFontDescriptor* desc = [NSFontDescriptor fontDescriptorWithName:@"Courier" size:12];//NSFontBoldTrait];
//	desc = [desc fontDescriptorWithSymbolicTraits:NSFontBoldTrait];
//	desc = [desc fontDescriptorByAddingAttributes:fontAtt];

//	NSDictionary* boldFontAndColorAtts = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithDescriptor:desc size:12], NSFontAttributeName, [p color], NSForegroundColorAttributeName, nil];

	NSMutableString* prepend = [NSMutableString stringWithFormat:@"%@: ", [p name]];
	while ([prepend length] < 16)
		[prepend insertString:@" " atIndex:0];
	
	NSAttributedString* nameAttStr = [[[NSAttributedString alloc] initWithString:prepend attributes:colorFontAtt] autorelease];
	NSAttributedString* textAttStr = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", str] attributes:fontAtt] autorelease];
	
	
	NSMutableAttributedString* attStr = [[[NSMutableAttributedString alloc] init] autorelease];
	[attStr appendAttributedString:nameAttStr];
	[attStr appendAttributedString:textAttStr];
	
	[self appendStringToChat:attStr];
	
//	[chatView setEditable:YES];
//	[chatView insertText:nameAttStr];
//	[chatView insertText:textAttStr];
//	[chatView insertText:attString];
//	[chatView setEditable:NO];
}


-(void) reloadDevCardTable	{
	[devCardTable reloadData];
}



-(void) monoplized:(NSString*)res	{
	[self playerWithName:[[[GameController gameController] currentPlayer] name] color:[[[GameController gameController] currentPlayer] color] performedAction:[NSString stringWithFormat:@"monopolized %@.", res]];
}
-(void) devCardPlayed:(NSString*)cardName	{
//	NSString* cardName = [card type];
	[self playerWithName:[[[GameController gameController] currentPlayer] name] color:[[[GameController gameController] currentPlayer] color] performedAction:[NSString stringWithFormat:@"played a %@ card.", cardName]];
}

-(void) playerWithName:(NSString*)playerName color:(NSColor*)playerColor performedAction:(NSString*)action	{

//	NSString* playerName = [[[GameController gameController] currentPlayer] name];
//	NSColor* playerColor = [[[GameController gameController] currentPlayer] color];
	
	NSDictionary* colorAtts = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Courier" size:12], NSFontAttributeName, playerColor, NSForegroundColorAttributeName, nil];
	NSAttributedString* colorString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"               %@", playerName] attributes:colorAtts] autorelease];
	NSDictionary* bwAtts = [NSDictionary dictionaryWithObject:[NSFont fontWithName:@"Courier" size:12] forKey:NSFontAttributeName];
	NSAttributedString* bwString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@\n", action] attributes:bwAtts] autorelease];
	
//	[chatView setEditable:YES];
//	[chatView insertText:colorString];
//	[chatView insertText:bwString];
//	[chatView setEditable:NO];
	NSMutableAttributedString* attStr = [[[NSMutableAttributedString alloc] init] autorelease];
	[attStr appendAttributedString:colorString];
	[attStr appendAttributedString:bwString];
	[self appendStringToChat:attStr];
}

-(void) appendStringToChat:(NSAttributedString*)str	{
	NSTextStorage* txtStore = [chatView textStorage];
//	[txtStore appendAttributedString:nameAttStr];
//	[txtStore appendAttributedString:textAttStr];
	[txtStore appendAttributedString:str];
	NSRange range = NSMakeRange([txtStore length] - 1, 1);
	
	[chatView scrollRangeToVisible:range];

}


- (BOOL)tableView:(NSTableView *)tv shouldSelectRow:(int)rowIndex	{
	if (tv == purchaseTable)
		return NO;
	return YES;
}



-(void) buildExtraImages	{
	[self buildTokenImages];
	[self buildResourceImages];
}


-(void) drawBackToken	{
	NSImage* backToken = [[[NSImage alloc] initWithSize:[[NSImage imageNamed:@"BrickTR.png"] size]] autorelease];
	
	NSDictionary* atts = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSColor greenColor], NSForegroundColorAttributeName,
		[NSFont boldSystemFontOfSize:56], NSFontAttributeName,
		nil];
	
	NSRect rect = NSMakeRect(0, 0, [backToken size].width, [backToken size].height);
	NSAttributedString* str = [[[NSAttributedString alloc] initWithString:@"$" attributes:atts] autorelease];
	[backToken lockFocus];
	[[NSColor whiteColor] set];
	[[NSBezierPath bezierPathWithOvalInRect:rect] fill];
	[str drawAtPoint:NSMakePoint((rect.size.width - [str size].width) / 2, (rect.size.height - [str size].height) / 2)];
	[backToken unlockFocus];
	
	[backToken setName:@"BackTR.png"];
	[backToken retain];
//	[[backToken TIFFRepresentation] writeToFile:@"/BackToken.tiff" atomically:NO];
}


-(void) buildResourceImages	{
	[self drawBackToken];
	NSArray* resources = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", @"Back", nil];
	NSImage* image;
	int i;
	NSSize bigSize = NSMakeSize(180, 291);
	NSSize smallSize = NSMakeSize(30, 48);
	NSString* tokenName;
	NSString* cardName;
	for (i = 0; i < [resources count]; i++)	{
		tokenName = [NSString stringWithFormat:@"%@TR.png", [resources objectAtIndex:i]];
		cardName = [NSString stringWithFormat:@"%@Res", [resources objectAtIndex:i]];
		image = [self cardImageWithToken:[NSImage imageNamed:tokenName] bgColor:[self colorForImageName:tokenName] size:bigSize];
		[image retain];
		[image setName:cardName];
		
		cardName = [NSString stringWithFormat:@"%@Small", cardName];
		image = [self cardImageWithToken:[NSImage imageNamed:tokenName] bgColor:[self colorForImageName:tokenName] size:smallSize];
		[image retain];
		[image setName:cardName];
	}
	
	image = [NSImage imageNamed:@"BrickRes"];
	
	NSImage* shadowCanvas = [[[NSImage alloc] initWithSize:NSMakeSize(2 * bigSize.width + 10, bigSize.height)] autorelease];
//	NSShadow* shadow = [[NSShadow standardShadow] autorelease];
	NSShadow* shadow = [NSShadow standardShadow];
	[shadow setShadowOffset:NSMakeSize(bigSize.width + 10, 0)];
	[shadowCanvas lockFocus];
	[shadow set];
	[image drawInRect:NSMakeRect(0, 0, bigSize.width, bigSize.height) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
	[shadowCanvas unlockFocus];
	
	NSImage* shadowImage = [[[NSImage alloc] initWithSize:bigSize] autorelease];
	[shadowImage lockFocus];
	[shadowCanvas drawInRect:NSMakeRect(0, 0, [shadowImage size].width, [shadowImage size].height) fromRect:
			NSMakeRect([shadowCanvas size].width - [shadowImage size].width,
						[shadowCanvas size].height - [shadowImage size].height, 
						[shadowImage size].width, 
						[shadowImage size].height)
						operation:NSCompositeSourceOver
						fraction:1.0];
	[shadowImage unlockFocus];
	[shadowImage setName:@"ShadowRes"];
	[shadowImage retain];
	
//	[[shadowImage TIFFRepresentation] writeToFile:@"/shadowRes.tiff" atomically:NO];
	
}	
-(void) oldbuildResourceImages	{
	int i;
	[self drawBackToken];
	NSArray* resources = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", @"Back", nil];
	NSImage* iconImage;
	NSImage* newImage;
	NSString* name;
	NSColor* color;
	NSSize sz = NSMakeSize(180, 291);
	NSBezierPath* path;
//	NSRect cardRect = NSMakeRect(2, 2, 176, 287);
//	int cardRectOffset
	NSRect cardRect = NSMakeRect(2, 2, sz.width - 4, sz.height - 4);
	NSBezierPath* cardRectPath = [NSBezierPath bezierPathWithRoundedRect:cardRect cornerRadius:18];
	[cardRectPath setLineWidth:3.0];
	NSSize pictureSize = NSMakeSize(135, 135);
	NSRect pictureRect = NSMakeRect( (sz.width - pictureSize.width) / 2, (sz.height - pictureSize.height) / 2, pictureSize.width, pictureSize.height);
	NSBezierPath* circlePath = [NSBezierPath bezierPathWithOvalInRect:pictureRect];
	[circlePath setLineWidth:2.0];
	for (i = 0; i < [resources count]; i++)	{
		name = [NSString stringWithFormat:@"%@TR.png", [resources objectAtIndex:i]];
		iconImage = [NSImage imageNamed:name];
//		iconImage = [NSImage imageNamed:name];
		color = [self colorForImageName:name];
		newImage = [[[NSImage alloc] initWithSize:sz] autorelease];
		[newImage lockFocus];
		[color set];
		[cardRectPath fill];
		[[NSColor whiteColor] set];
		[cardRectPath stroke];
		[iconImage drawInRect:pictureRect fromRect:NSMakeRect(0, 0, [iconImage size].width, [iconImage size].height) operation:NSCompositeSourceOver fraction:1.0];
		[[NSColor grayColor] set];
		[circlePath stroke];
		[newImage unlockFocus];
		
		[newImage retain];
		NSString* newImageName = [NSString stringWithFormat:@"%@Res", [resources objectAtIndex:i]];
		[newImage setName:newImageName];
//		[[newImage TIFFRepresentation] writeToFile:[NSString stringWithFormat:@"/%@.tiff", newImageName] atomically:NO];

	}
}


-(void) buildTokenImages	{

	NSImage* baseImage;
	NSImage* newImage;

	NSArray* prefixes = [NSArray arrayWithObjects:@"city", @"settlement",nil];
	NSArray* suffixes = [NSArray arrayWithObjects:@"Building", @"Shadow", nil];
	NSString* prefix;
	NSString* suffix;
	NSString* imageName;
	NSString* newImageName;
	int i, j, k;
	for (k = 0; k < [suffixes count]; k++)	{	
		suffix = [suffixes objectAtIndex:k];
		for (j = 0; j < [prefixes count]; j++)	{
			prefix = [prefixes objectAtIndex:j];
			for (i = 0; i < 2; i++)	{
				imageName = [NSString stringWithFormat:@"%@%dNew%@.png", prefix, 2 * i + 1, suffix];
				newImageName = [NSString stringWithFormat:@"%@%dNew%@.png", prefix, 2 * i + 2, suffix];
				baseImage = [NSImage imageNamed:imageName];
				if (baseImage)	{
					newImage = [baseImage imageByFlippingHorizontally];
					[newImage retain];
//					NSLog(@"setting image name, %@", newImageName);
					[newImage setName:newImageName];
				}
			}
		}
	}
	prefixes = [NSArray arrayWithObject:@"road"];
	suffixes = [NSArray arrayWithObjects:@"Road", @"Shadow", nil];
	for (k = 0; k < [suffixes count]; k++)	{	
		suffix = [suffixes objectAtIndex:k];
		for (j = 0; j < [prefixes count]; j++)	{
			prefix = [prefixes objectAtIndex:j];
			for (i = 0; i < 1; i++)	{
				imageName = [NSString stringWithFormat:@"%@%dNew%@.png", prefix, i, suffix];
				newImageName = [NSString stringWithFormat:@"%@%dNew%@.png", prefix, i + 1, suffix];
				baseImage = [NSImage imageNamed:imageName];
				if (baseImage)	{
					newImage = [baseImage imageByFlippingHorizontally];
					[newImage retain];
//					NSLog(@"setting image name, %@", newImageName);

					[newImage setName:newImageName];
				}
			}
		}
	}


}

-(NSColor*) colorForImageName:(NSString*)nm	{
//	int i;
//	float percents[4] = {0.0, .4, 0.5, 0.6};
	NSColor* tmp;
	if ([nm isEqualToString:@"BrickTR.png"])	{

		return [[NSColor redColor] blendedColorWithFraction:0.1 ofColor:[NSColor blackColor]];
	}
	
	if ([nm isEqualToString:@"GrainTR.png"])	{
		tmp = [[NSColor yellowColor] blendedColorWithFraction:0.5 ofColor:[NSColor brownColor]];
		return [tmp blendedColorWithFraction:0.4 ofColor:[NSColor whiteColor]];
	//	return tmp;
	//	return [[NSColor yellowColor] blendedColorWithFraction:0.05 ofColor:[NSColor blackColor]];
	}
	
	if ([nm isEqualToString:@"OreTR.png"])	{
		return [NSColor grayColor];
	}
	if ([nm isEqualToString:@"SheepTR.png"])	{
		tmp = [NSColor greenColor];
		tmp = [tmp blendedColorWithFraction:0.5 ofColor:[NSColor yellowColor]];
//		return tmp;
		return [tmp blendedColorWithFraction:0.15 ofColor:[NSColor blackColor]];;
	}
	
	if ([nm isEqualToString:@"WoodTR.png"])	{
		return [[NSColor greenColor] blendedColorWithFraction:0.65 ofColor:[NSColor blackColor]];
	}	
	
	if ([nm isEqualToString:@"BackTR.png"])	{
		return [NSColor colorWithCalibratedRed:0.4 green:0.5 blue:0.55 alpha:1.0];
		//return [NSColor blackColor];
	}
	
	
	NSLog(@"%s, no color for '%@'", __FUNCTION__, nm);
	return nil;
}

-(NSImage*) cardImageWithToken:(NSImage*)token bgColor:(NSColor*)bgColor size:(NSSize)sz	{
	NSImage* image = [[[NSImage alloc] initWithSize:sz] autorelease];
//	NSBezierPath* path;
	int crpWidth = (int)(sz.width / 60.0);
	int offset;
	if (crpWidth >= 3)
		offset = 2;
	else if (crpWidth == 2)
		offset = 1;
	else
		offset = 0;
		
	NSRect cardRect = NSMakeRect(offset, offset, sz.width - 2 * offset, sz.height - 2 * offset);
	int rad = (int)(sz.width / 10.0);
	NSBezierPath* cardRectPath = [NSBezierPath bezierPathWithRoundedRect:cardRect cornerRadius:rad];
	[cardRectPath setLineWidth:crpWidth];
	int ps = (int)(sz.width * 0.75);
	NSSize pictureSize = NSMakeSize(ps, ps);
	NSRect pictureRect = NSMakeRect( (sz.width - pictureSize.width) / 2, (sz.height - pictureSize.height) / 2, pictureSize.width, pictureSize.height);
	NSBezierPath* circlePath = [NSBezierPath bezierPathWithOvalInRect:pictureRect];
	int cpWidth = (int)(sz.width / 90.0);
	[circlePath setLineWidth:cpWidth];
//	for (i = 0; i < [resources count]; i++)	{
//		name = [NSString stringWithFormat:@"%@TR.png", [resources objectAtIndex:i]];
//		iconImage = [NSImage imageNamed:name];
//		iconImage = [NSImage imageNamed:name];
//		color = [self colorForImageName:name];
//		newImage = [[[NSImage alloc] initWithSize:sz] autorelease];
		[image lockFocus];
		[bgColor set];
		[cardRectPath fill];
		[[NSColor whiteColor] set];
		[cardRectPath stroke];
		[token drawInRect:pictureRect fromRect:NSMakeRect(0, 0, [token size].width, [token size].height) operation:NSCompositeSourceOver fraction:1.0];
		[[NSColor grayColor] set];
		[circlePath stroke];
		[image unlockFocus];
//	}
	return image;
}



@end

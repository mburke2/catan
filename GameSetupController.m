//
//  GameSetupController.m
//  catan
//
//  Created by James Burke on 1/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GameSetupController.h"
//#import "GameClient.h"

@implementation GameSetupController

//-(id) initWithServer:(GameClient*)obj name:(NSString*)nm color:(NSColor*)color board:(NSData*)bInfo prefs:(NSDictionary*)prefs asHost:(BOOL)flag	{
-(id) initWithServer:(BGClient*)obj name:(NSString*)nm color:(NSColor*)color board:(NSData*)bInfo prefs:(NSDictionary*)prefs asHost:(BOOL)flag	{

	self = [super init];
	if (self)	{
		if (nm == nil || [@"" isEqualToString:nm])
			nm = [[NSString stringWithFormat:@"Player %d", [[obj index] intValue] + 1] retain];
		shouldChangeColorSetting = NO;
		theServer = [obj retain];
		gameHost = flag;
		myColor = [color retain];
		myName = [nm retain];
		players = [[NSMutableArray alloc] init];
		readyFlag = NO;
		
		gamePrefs = [NSDictionary dictionaryWithDictionary:prefs];
		[gamePrefs retain];
		boardInfo = [bInfo retain];
		
//		[gamePrefs retain];
	}
	return self;
}

-(NSData*) boardInfo	{
	return boardInfo;
}
-(NSDictionary*) gamePrefs	{
	return gamePrefs;
}

-(void) awakeFromNib	{
//	buttonArray = [NSArray arrayWithObjects:tradeBox, purchaseBox, devCardUseageBox, onePerTurnBox, excludeVPBox, knightBox, nil];
	buttonDict = [NSDictionary dictionaryWithObjectsAndKeys:
		tradeBox, @"CAN_TRADE", purchaseBox, @"CAN_PURCHASE", devCardUseageBox, @"CAN_PLAY_DEV_CARD",
		onePerTurnBox, @"ONE_PER_TURN", excludeVPBox, @"EXCLUDE_VP", knightBox, @"ONLY_KNIGHT", 
		knightBeforeRoll, @"KNIGHT_BEFORE_ROLL",  nil];
		
	[buttonDict retain];
	[readyButton setState:0];
	[startButton setEnabled:NO];
	[colorWell setColor:myColor];
	
	
	NSArray* tcs = [playerTable tableColumns];
	int i;
	for (i = 0; i < [tcs count]; i++)	{
		if ([[[tcs objectAtIndex:i] identifier] isEqualToString:@"Color"])
			[[tcs objectAtIndex:i] setDataCell:[[[NSImageCell alloc] init] autorelease]];
	}
	
	
	NSArray* keys = [buttonDict allKeys];
	id obj;
	for (i = 0; i < [keys count]; i++)	{
		obj = [buttonDict objectForKey:[keys objectAtIndex:i]];
		if (obj)
			[obj setState:[[gamePrefs objectForKey:[keys objectAtIndex:i]] boolValue]];
	}
	
	[pointTotalField setIntValue:[[gamePrefs objectForKey:@"POINT_TOTAL"] intValue]];
	[settlementField setIntValue:[[gamePrefs objectForKey:@"SETTLEMENT_TOKENS"] intValue]];
	[cityField setIntValue:[[gamePrefs objectForKey:@"CITY_TOKENS"] intValue]];
	
	if (gameHost == NO)	{
		for (i = 0; i < [keys count]; i++)	{
			[[buttonDict objectForKey:[keys objectAtIndex:i]] setEnabled:NO];
		}
		[desertLocationSwitch setEnabled:NO];
		[generateBoardButton setEnabled:NO];
		[portStatusField setHidden:YES];
		[pointTotalField setEnabled:NO];
		[cityField setEnabled:NO];
		[settlementField setEnabled:NO];
	}
	else	{
		[portStatusField setStringValue:[NSString stringWithFormat:@"Listening on port %d", [theServer portNumber]]];
	//	[self generateBoard:nil];
	}	
	

	Board* b = [[[Board alloc] init] autorelease];
	[b setBoardInfo:boardInfo];
	[boardPreview setBoard:b];
	
//	[theServer infoChanged];
	[[chatInputField window] makeFirstResponder:chatInputField];
}

-(IBAction) toggleReady:(id)sender	{
	readyFlag = [readyButton state];
//	[theServer setReady:readyFlag];
//	[theServer infoChanged];
	[theServer updateAttribute:@"READY" withValue:[NSNumber numberWithBool:readyFlag]];
}
/*	NSTextStorage* txtStore = [chatView textStorage];
//	[txtStore appendAttributedString:nameAttStr];
//	[txtStore appendAttributedString:textAttStr];
	[txtStore appendAttributedString:str];
	NSRange range = NSMakeRange([txtStore length] - 1, 1);
	
	[chatView scrollRangeToVisible:range];
*/

-(void) receiveChat:(NSString*)str fromName:(NSString*)nm	{
//	NSMutableString
	NSAttributedString* attStr = [[[NSAttributedString alloc] initWithString:
		[NSString stringWithFormat:@"%@:  %@\n", nm, str]
		 attributes:nil] autorelease];
	[[chatView textStorage] appendAttributedString:attStr];

	NSRange range = NSMakeRange([[chatView textStorage] length] - 1, 1);	
	[chatView scrollRangeToVisible:range];
}

-(IBAction) sendChat:(id)sender	{
	NSString* str = [chatInputField stringValue];
	if ([str isEqualToString:@""] == NO)	{
		[theServer notify:@selector(receiveChat:fromName:) args:[NSArray arrayWithObjects:str, myName, nil]];
		[self receiveChat:str fromName:myName];
	}
	[chatInputField setStringValue:@""];
	[[chatInputField window] makeFirstResponder:chatInputField];
}
/*
/*
-(void) beginGame:(NSTimer*)t	{
//	NSLog(@"beginning game");
	int i;
	[netService stop];
	NSArray* colors = [NSArray arrayWithObjects:[NSColor blueColor], [NSColor redColor], [NSColor orangeColor], [NSColor purpleColor], nil];
//	NSString* names = [NSArray arrayWithObjects:@"Mook", @"Silly Pants", @"Dog Balls", @"Anton", nil];
//	Board* theBoard = [Board newBoard];
//	[theBoard generateBoardInfo];
//	NSData* boardInfo = [theBoard boardInfo];
//	NSData* boardInfo = [Board infoForNewBoard];
	
	NSMutableArray* players = [NSMutableArray array];
	NSDistantObject <clientProtocol> *client;
	for (i = 0; i < [clientConnections count]; i++)	{
		client = [[clientConnections objectAtIndex:i] rootProxy];
		[players addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			[client color], @"Color",
			[client name], @"Name", nil]];
		//[players addObject:[NSDictionary dictionaryWithObjectsAndKeys:[colors objectAtIndex:i], @"Color", [names objectAtIndex:i], @"Name", nil]];
	}

	NSData* boardInfo = [self boardInfo];
	NSArray* devCards = [self makeDevCards];
	NSDictionary* gamePrefs = [NSUnarchiver unarchiveObjectWithData:[self gamePrefs]];
	for (i = 0; i < [clientConnections count]; i++)	{
		[[[clientConnections objectAtIndex:i] rootProxy] startGameWithBoardInfo:boardInfo players:players localPlayer:i devCards:devCards gamePrefs:gamePrefs];
//		NSLog(@"i = %d", i);
//		NSLog(@"client = %@", [[clientConnections objectAtIndex:i] rootProxy]);
	}
}*/

//-(void) startGameWithBoardInfo:(NSData*)info players:(NSArray*)playerInfo localPlayer:(int)n devCards:(NSArray*)devCards gamePrefs:(NSDictionary*)prefs	{
-(void) startGameWithDevCards:(NSArray*)devCards	{
	NSLog(@"starting game");
	NSDictionary* infoDict = [theServer infoDictionary];
    NSLog(@"got infoDict, %@", infoDict);
	NSData* newBoardData = [[infoDict objectForKey:@"BOARD"] objectAtIndex:0];
    NSLog(@"got newBoardData");
	NSDictionary* gPrefs = [NSUnarchiver unarchiveObjectWithData:[infoDict objectForKey:@"PREFS"]];
//    NSLog(@"gPrefs = %@", gPrefs);
	NSLog(@"prefs = %@", gPrefs);
	[BoardHexagon setShouldRoateTiles:YES]; 

//	myIndex = n;
//	[[GameController gameController] setServer:self];
	[[GameController gameController] setServer:theServer];
	[theServer setOwner:[GameController gameController]];
//	NSLog(@"starting game");
	Control* c = [[Control alloc] init];
	Board* newBoard = [Board newBoard];
	[newBoard setBoardInfo:newBoardData];
//	NSLog(@"set board data");
	[[GameController gameController] setBoard:newBoard];
//	NSArray* devCards = [self makeDevCards];
	int i;
//	NSLog(@"making game players");
	NSMutableArray* gamePlayers = [NSMutableArray array];
	for (i = 0; i < [players count]; i++)	{
		[gamePlayers addObject:[Player playerWithName:[[players objectAtIndex:i] objectForKey:@"NAME"] color:[[players objectAtIndex:i] objectForKey:@"COLOR"]]];
	}
//	NSLog(@"made them");
	[[GameController gameController] setPlayers:gamePlayers];
//	NSLog(@"set players");
	[[GameController gameController] setLocalPlayer:[gamePlayers objectAtIndex:[theServer index]]];
//	NSLog(@"set local player");
	[[GameController gameController] setDevCardOrder:devCards];
//	NSLog(@"set dev cards");
	[[GameController gameController] setGamePrefs:gPrefs];
//	NSLog(@"set prefs");
//	NSLog(@"loading GAMECONTROLLER nib");
	[NSBundle loadNibNamed:@"GameControl.nib" owner:c];
	[self close];
//	[setup release];
//	setup = nil;
}

-(IBAction) startGame:(id)sender	{
//	[theServer startGame];
	NSArray* devCards = [self makeDevCards];
	[theServer notify:@selector(startGameWithDevCards:) args:[NSArray arrayWithObject:devCards]];
	[self startGameWithDevCards:devCards];
}


	
-(IBAction) colorChanged:(id)sender	{
//	NSLog(@"colorChanged");
	[myColor release];
	myColor = [[colorWell color] retain];
	if (shouldChangeColorSetting)	{
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
	}
	shouldChangeColorSetting = YES;
	[self performSelector:@selector(updateColor) withObject:nil afterDelay:0.2];
//	[theServer performSelector:@selector(infoChanged:) withObject:nil afterDelay:0.2];
//	[theServer infoChanged];
//	[theServer set
}

-(IBAction) generateBoard:(id)sender	{
	int selectedRow = [desertLocationSwitch selectedRow];
	
	NSData* info;
	if (selectedRow == 1)
		info = [Board infoForNewBoardWithDesertInCenter:YES];
	else
		info = [Board infoForNewBoardWithDesertInCenter:NO];
	
//	[self setBoardInfo:info edgeFlag:[NSNumber numberWithInt:selectedRow]];
	[theServer updateAttribute:@"BOARD" withValue:[NSArray arrayWithObjects:info, [NSNumber numberWithInt:selectedRow], nil]];
}

-(void) setBoardInfo:(NSData*)data	edgeFlag:(NSNumber*)n {
//	if (gameHost)	{
//		[theServer updateAttribute:@"BOARD" withValue:[NSArray arrayWithObjects:data, n, nil]];
//		[theServer notify:_cmd args:[NSArray arrayWithObjects:data, n, nil]];
//	}
	[desertLocationSwitch selectCellAtRow:[n intValue] column:0];
	

	[boardInfo release];
	boardInfo = [data retain];
	Board* b = [[[Board alloc] init] autorelease];
	[b setBoardInfo:data];
	[boardPreview setBoard:b];
}

/*
tradeBox, @"CAN_TRADE", purchaseBox, @"CAN_PURCHASE", devCardUseageBox, @"CAN_PLAY_DEV_CARD",
		onePerTurnBox, @"ONE_PER_TURN", excludeVPBox, @"EXCLUDE_VP", knightBox, @"ONLY_KNIGHT", 
		knightBeforeRoll, @"KNIGHT_BEFORE_ROLL",  nil];*/
-(IBAction) prefsChanged:(id)sender	{
	NSMutableDictionary* newPrefs = [NSMutableDictionary dictionaryWithDictionary:gamePrefs];
//	NSString* key = [[buttonDict allKeysForObject:sender] objectAtIndex:0];
	NSArray* bullshit = [buttonDict allKeysForObject:sender];
	NSString* key = nil;
	if (bullshit && [bullshit count] > 0)
		key  = [bullshit objectAtIndex:0];
		
//	NSLog(@"key = %@", key);
	if ([key isEqualToString:@"ONE_PER_TURN"] && [sender state] == NSOffState)	{
		[newPrefs removeObjectForKey:@"EXCLUDE_VP"];
		[newPrefs removeObjectForKey:@"ONLY_KNIGHT"];
		[newPrefs setObject:[NSNumber numberWithBool:NO] forKey:@"EXCLUDE_VP"];
		[newPrefs setObject:[NSNumber numberWithBool:NO] forKey:@"ONLY_KNIGHT"];
	//	[newPrefs replaceObjectAtIndex:4 withObject:[NSNumber numberWithBool:NO]];
	//	[newPrefs replaceObjectAtIndex:5 withObject:[NSNumber numberWithBool:NO]];
	}
	else if ([key isEqualToString:@"EXCLUDE_VP"] || [key isEqualToString:@"ONLY_KNIGHT"] && [sender state] == NSOnState)	{
	//	[newPrefs replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:YES]];
		[newPrefs removeObjectForKey:@"ONE_PER_TURN"];
		[newPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"ONE_PER_TURN"];
		if ([key isEqualToString:@"ONLY_KNIGHT"])	{
//			[newPrefs replaceObjectAtIndex:5 withObject:[NSNumber numberWithBool:NO]];
			[newPrefs removeObjectForKey:@"EXCLUDE_VP"];
			[newPrefs setObject:[NSNumber numberWithBool:NO] forKey:@"EXCLUDE_VP"];
		}
		else	{
			[newPrefs removeObjectForKey:@"ONLY_KNIGHT"];
			[newPrefs setObject:[NSNumber numberWithBool:NO] forKey:@"ONLY_KNIGHT"];
		}
			//[newPrefs replaceObjectAtIndex:4 withObject:[NSNumber numberWithBool:NO]];
	}
	
	else if ([key isEqualToString:@"CAN_PLAY_DEV_CARD"] && [sender state] == NSOffState)	{
		[newPrefs removeObjectForKey:@"KNIGHT_BEFORE_ROLL"];
		[newPrefs setObject:[NSNumber numberWithBool:NO] forKey:@"KNIGHT_BEFORE_ROLL"];
	}
	else if ([key isEqualToString:@"KNIGHT_BEFORE_ROLL"] && [sender state] == NSOnState)	{
		[newPrefs removeObjectForKey:@"CAN_PLAY_DEV_CARD"];
		[newPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"CAN_PLAY_DEV_CARD"];
	}
	
	if (key)	{
		[newPrefs removeObjectForKey:key];
		[newPrefs setObject:[NSNumber numberWithBool:[sender state]] forKey:key];
	}

	else	{
		if (sender == pointTotalField)	{
			[newPrefs removeObjectForKey:@"POINT_TOTAL"];
			[newPrefs setObject:[NSNumber numberWithInt:[pointTotalField intValue]] forKey:@"POINT_TOTAL"];
		}
		if (sender == cityField)	{
			[newPrefs removeObjectForKey:@"CITY_TOKENS"];
			[newPrefs setObject:[NSNumber numberWithInt:[cityField intValue]] forKey:@"CITY_TOKENS"];
		}

		if (sender == settlementField)	{
			[newPrefs removeObjectForKey:@"SETTLEMENT_TOKENS"];
			[newPrefs setObject:[NSNumber numberWithInt:[settlementField intValue]] forKey:@"SETTLEMENT_TOKENS"];
		}

	}
	[theServer updateAttribute:@"PREFS" withValue:[NSArchiver archivedDataWithRootObject:newPrefs]];
//	[self setPrefs:newPrefs];
}

-(void) setPrefs:(NSData*)newPrefsData	{
    NSDictionary* newPrefs = [NSUnarchiver unarchiveObjectWithData:newPrefsData];
//	NSLog(@"setting prefs, %@", newPrefs);
	[gamePrefs release];
	gamePrefs = [NSDictionary dictionaryWithDictionary:newPrefs];
	[gamePrefs retain];
	
	int i;
	NSArray* keys = [gamePrefs allKeys];
	id obj;
	for (i = 0; i < [keys count]; i++)	{
		obj = [buttonDict objectForKey:[keys objectAtIndex:i]];
		if (obj)
			[obj setState:[[gamePrefs objectForKey:[keys objectAtIndex:i]] boolValue]];
	}
	
//	[pointTotalField setEnabled:YES];
	[pointTotalField setIntValue:[[gamePrefs objectForKey:@"POINT_TOTAL"] intValue]];
	[cityField setIntValue:[[gamePrefs objectForKey:@"CITY_TOKENS"] intValue]];
	[settlementField setIntValue:[[gamePrefs objectForKey:@"SETTLEMENT_TOKENS"] intValue]];
	
//	if (gameHost)	{
		//[theServer notify:_cmd args:[NSArray arrayWithObject:newPrefs]];
//		[theServer updateAttribute:@"PREFS" withValue:newPrefs];
//	}
}



/*
-(void) updatePrefs	{

	int i;
	for (i = 0; i < [buttonArray count]; i++)	{
		[[buttonArray objectAtIndex:i] setState:[[gamePrefs objectAtIndex:i] boolValue]];
	}
}
*/

-(void) updateColor	{
	shouldChangeColorSetting = NO;
	[theServer updateAttribute:@"COLOR" withValue:myColor];
//	[theServer infoChanged];
}


-(void) infoChanged:(NSArray*)keys	{
	NSLog(@"!!!!!! INFO CHANGED, keys = %@", keys);
	int i;
	for (i = 0; i < [keys count]; i++)	{
		[self handleInfoChangeForKey:[keys objectAtIndex:i]];
	}
}

-(void) handleInfoChangeForKey:(NSString*)key	{
	NSDictionary* info = [theServer infoDictionary];
	id object = [info objectForKey:key];
	if ([key isEqualToString:@"BOARD"])	{
		[self setBoardInfo:[(NSArray*)object objectAtIndex:0] edgeFlag:[(NSArray*)object objectAtIndex:1]];
	}
	else if ([key isEqualToString:@"PREFS"])	{
		[self setPrefs:(NSDictionary*)object];
	}
	else	{
		NSArray* tokens = [key componentsSeparatedByString:@":"];
		if ([tokens count] == 2)	{
			int pIndex = [[tokens objectAtIndex:0] intValue];
			NSString* attribute = [tokens objectAtIndex:1];
			[self handleChangeInAttribute:attribute forPlayer:pIndex object:object];
		}
		else	{
			NSLog(@"\t\t\tSTRANGE KEY, %@, obj = %@", key, object);
		}
	}
}

-(void) handleChangeInAttribute:(NSString*)attribute forPlayer:(int)pIndex	object:(id)obj {
	NSLog(@"SETUP IS HANDLING %@ for %d", attribute, pIndex);
	if (pIndex > [players count])	{
		NSLog(@"%s, ILLEGAL INDEX, index  = %d, count = %d", pIndex, [players count]);
		return;
	}
	
	if (pIndex == [players count])
		[players addObject:[NSMutableDictionary dictionary]];
	
	NSDictionary* aPlayerDict = [players objectAtIndex:pIndex];
	
	[aPlayerDict setValue:obj forKey:attribute];
	[playerTable reloadData];
	if (gameHost)
		[self checkReadyForAllPlayers];
}

-(void) checkReadyForAllPlayers	{
	BOOL allReady = YES;
	int i;
	NSDictionary* aPlayerDict;
	NSNumber* flag;
	for (i = 0; i < [players count]; i++)	{
		aPlayerDict = [players objectAtIndex:i];
		flag = [aPlayerDict objectForKey:@"READY"];
		allReady = allReady && flag && [flag boolValue];
	}
	
	[startButton setEnabled:allReady];
}

-(void) otherinfoChanged:(NSArray*)keys	{
	NSLog(@"%s, %@", __FUNCTION__, keys);
	NSMutableDictionary* newPlayer = [NSMutableDictionary dictionary];
	NSDictionary* info = [theServer infoDictionary];
	int i;

//	NSMutableArray* newKeys = [NSMutableArray array];
	if ([keys count] == 3)	{
		NSString* newKey;
		for (i = 0; i < [keys count]; i++)	{
			newKey = [[[keys objectAtIndex:i] componentsSeparatedByString:@":"] objectAtIndex:1];
			[newPlayer setObject:[info objectForKey:[keys objectAtIndex:i]] forKey:newKey];
//			[newKeys addObject:];
		}
		[self addPlayer:newPlayer];
	} else	{
//		int i;
		int index;
		NSString* key;
		for (i = 0; i < [keys count]; i++)	{
			index = [[[[keys objectAtIndex:i] componentsSeparatedByString:@":"] objectAtIndex:0] intValue];
			key = [[[keys objectAtIndex:i] componentsSeparatedByString:@":"] objectAtIndex:1];
		}
//		NSLog(@"info changed... ignoring it");
	}
		
}

-(NSString*) name	{
	return myName;
}


-(NSColor*) color	{
	return myColor;
}

-(BOOL) ready	{
	return readyFlag;
}	



-(int) numberOfRowsInTableView:(NSTableView*)tv	{
	return [players count];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex	{
	NSDictionary* aPlayerDict = [players objectAtIndex:rowIndex];
	if ([aPlayerDict objectForKey:@"COLOR"] == nil || [aPlayerDict objectForKey:@"NAME"] == nil || [aPlayerDict objectForKey:@"READY"] == nil)
		return;
	if ([[aTableColumn identifier] isEqualToString:@"Color"])	{
		//[aCell setStringValue:@"blah"];
		NSImage* image = [[[NSImage alloc] initWithSize:NSMakeSize(12, 12)] autorelease];
		[image lockFocus];
		[[[players objectAtIndex:rowIndex] objectForKey:@"COLOR"] set];
		[NSBezierPath fillRect:NSMakeRect(0, 0, [image size].width, [image size].height)];
		[[NSColor blackColor] set];
		[NSBezierPath strokeRect:NSMakeRect(0, 0, [image size].width, [image size].height)];
		[image unlockFocus];
		[aCell setImage:image];
	}

	else if ([[aTableColumn identifier] isEqualToString:@"Name"])	{
		NSString* nm = [[players objectAtIndex:rowIndex] objectForKey:@"NAME"];
		NSDictionary* attributes = nil;
		if ([[[players objectAtIndex:rowIndex] objectForKey:@"READY"] boolValue] == NO)
			attributes = [NSDictionary dictionaryWithObject:[NSColor grayColor]
				forKey:NSForegroundColorAttributeName];
		NSAttributedString* attStr = [[[NSAttributedString alloc] initWithString:nm attributes:attributes] autorelease];
		[aCell setStringValue:attStr];
	}
}

-(void) setPlayers:(NSArray*)p	{
	BOOL allReady = YES;
	[players removeAllObjects];
	int i;
	for (i = 0; i < [p count]; i++)	{
		[players addObject:[p objectAtIndex:i]];
		allReady = allReady && [[[p objectAtIndex:i] objectForKey:@"READY"] boolValue];
	}
	
	if (allReady && gameHost)
		[startButton setEnabled:YES];
	else
		[startButton setEnabled:NO];
	[playerTable reloadData];
}

-(void) close	{
	[window close];
}

-(void) addPlayer:(NSDictionary*)dict	{
//	NSLog(@"adding player HERE");
	[players addObject:dict];
	[playerTable reloadData];
}




-(NSMutableArray*) makeDevCards	{
//	NSMutableArray* devCards = [[NSMutableArray alloc] init];
	NSMutableArray* devCards = [NSMutableArray array];
	
	int i;

	
	for (i = 0; i < 2; i++)	{
		[devCards addObject:@"Road Building"];
		[devCards addObject:@"Year Of Plenty"];
		[devCards addObject:@"Monopoly"];
//		[devCards addObject:[DevelopmentCard cardWithType:@"Road Building"]];
//		[devCards addObject:[DevelopmentCard cardWithType:@"Year of Plenty"]];
//		[devCards addObject:[DevelopmentCard cardWithType:@"Monopoly"]];
	}
	
	for (i = 0; i < 5; i++)	{
		[devCards addObject:@"Victory Point"];
//		[devCards addObject:[DevelopmentCard cardWithType:@"Victory Point"]];
	}
	for (i = 0; i < 14; i++)	{
		[devCards addObject:@"Knight"];
//		[devCards addObject:[DevelopmentCard cardWithType:@"Knight"]];
	}
	

	[devCards shuffle];
//	NSMutableString* str = [NSMutableString stringWithString:@"DevCardOrder = "];
//	for (i = 0; i < [devCards count]; i++)	{
//		[str appendFormat:@"%@, ", [devCards objectAtIndex:i]];
//	}
//	NSLog(@"%@", str);
	return devCards;
}




@end

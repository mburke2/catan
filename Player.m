//
//  Player.m
//  catan
//
//  Created by James Burke on 1/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#import "TradeRoute.h"
#import "BoardTokens.h"
#import "GameController.h"
#import "CollectionView.h"
#import "AnimatedCardView.h"
#import "BoardView.h"

#define PP //NSLog(@"%s", __FUNCTION__)

@implementation Player
//-(id) initWithName:(NSString*)str color:(NSColor*)color	{
-(id) init		{
	self = [super init];
	if (self)	{
//		myName = [[str copy] retain];
//		myColor = [[color copy] retain];
		
		myName = nil;
		myColor = nil;
		armySize = 0;
		vpCards = 0;
		
		receivedInTrade = 0;
		tradedAway = 0;

		resourcesLostToRobber = 0;
		resourcesStolen = 0;
		earnedResources = 0;
		expectedResources = 0;
		sevensRolled = 0;
		
		resources = [[NSMutableArray alloc] init];
		draggedResources = nil;
		catagories = [NSArray arrayWithObjects:@"Catagory: Brick", @"Catagory: Wood", @"Catagory: Sheep", @"Catagory: Grain", @"Catagory: Ore", nil];
		items = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
		[catagories retain];
		[items retain];
		
		active = NO;
		settlements = [[NSMutableArray array] retain];
		myRoads = [[NSMutableArray alloc] init];
		myDevCards = [[NSMutableArray alloc] init];
		cardsToDiscard = 0;
//		[settlements retain];
	}
	return self;
}

+(Player*) playerWithName:(NSString*)nm color:(NSColor*)color	{
//	Player* p = [[Player alloc] initWithName:nm color:color];
	Player* p = [[Player alloc] init];
	[p setName:nm];
	[p setColor:color];
	[p autorelease];
	
	return p;
}

-(BOOL) active	{
	return active;
}


-(void) setName:(NSString*)nm	{
	[myName release];
	myName = [[nm copy] retain];
}

-(void) setColor:(NSColor*)color	{
	[myColor release];
	myColor = [[color copy] retain];
}
-(void) addDevCard:(DevelopmentCard*)dc	{
	[myDevCards addObject:dc];
}

-(NSArray*) developmentCards	{
	return myDevCards;
}

-(void) setResourceView:(CollectionView*)cv	{
	resView = [cv retain];
}

-(void) animationFinished	{
	//[[NSNotificationCenter defaultCenter] performSelector:@selector(postNotification:) withObject:note afterDelay:initialDelay + duration + 0.02];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RESOURCES_CHANGED_NOTIFICATION" object:self];
	
}

-(void) addResource:(NSString*)str fromPoint:(NSPoint)p	{
	[resources addObject:str];
	NSView* content = [[resView window] contentView];
	AnimatedCardView* acv = [[GameController gameController] animatedCardView];
	BoardView* bv = [[GameController gameController] boardView];
	p = [content convertPoint:p fromView:bv];
	NSRect oldRect = NSMakeRect(p.x, p.y, [[NSImage imageNamed:@"BrickRes.tiff"] size].width, [[NSImage imageNamed:@"BrickRes.tiff"] size].height);
	NSRect newRect = [resView frameForNewResourceOfType:str];
	newRect.origin = [content convertPoint:newRect.origin fromView:resView];
	NSImage* image = [NSImage imageNamed:[NSString stringWithFormat:@"%@Res.tiff", str]];
	float initialDelay = [resView makeRoomForResourceOfType:str];
//	float duration = 5.5;
	float duration = 0.75;
	NSDictionary* aniDict = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSValue valueWithRect:oldRect], @"StartFrame",
		[NSValue valueWithRect:newRect], @"EndFrame",
		[NSNumber numberWithFloat:duration], @"AnimationLength", 
		image, @"Image", 
		self, @"Delegate", nil];

//	NSNotification* note = [NSNotification notificationWithName:@"RESOURCES_CHANGED_NOTIFICATION" object:self];

//	[bv  performSelector:@selector(lockDrawing) withObject:nil afterDelay:initialDelay];
//	[bv  performSelector:@selector(unlockDrawing) withObject:nil afterDelay:initialDelay + duration];
	[acv performSelector:@selector(startAnimation:) withObject:aniDict afterDelay:initialDelay];
//	[acv performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:initialDelay + duration];
}

-(void) addResource:(NSString*)str	{
	[resources addObject:str];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RESOURCES_CHANGED_NOTIFICATION" object:self];
}

-(void) addResourceNotifyingItemTableOnly:(NSString*)str	{
	[resources addObject:str];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RESOURCE_CHANGED_NOTIFICATION_FOR_ITEM_TABLE" object:self];
}

-(NSArray*) resources	{
	return resources;
}

-(int) numberOfRowsInTableView:(NSTableView*)tv	{
	return [myDevCards count];
//	return [resources count];
}


-(id) tableView:(NSTableView*)tv objectValueForTableColumn:(NSTableColumn*)tc row:(int)r	{
	NSColor* color;
	if ([[myDevCards objectAtIndex:r] playable])
		color = [NSColor blackColor];
	else
		color = [NSColor grayColor];
	
	NSDictionary* atts = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
	return [[[NSAttributedString alloc] initWithString:[(DevelopmentCard*)[myDevCards objectAtIndex:r] type] attributes:atts] autorelease];
//	return [[myDevCards objectAtIndex:r] type];
//	return [resources objectAtIndex:r];
}

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard	{
	[pboard declareTypes:[NSArray arrayWithObject:@"CATAN_RESOURCE_TYPE"] owner:self];
	
	NSMutableArray* tmpArr = [NSMutableArray array];
	int index = [rowIndexes firstIndex];
	while (index != NSNotFound)	{
		[tmpArr addObject:[resources objectAtIndex:index]];
		index = [rowIndexes indexGreaterThanIndex:index];
	}
	[draggedResources release];
	draggedResources = [NSArray arrayWithArray:tmpArr];
	[draggedResources retain];
	[pboard setPropertyList:[NSArray arrayWithArray:tmpArr] forType:@"CATAN_RESOURCE_TYPE"];
	
	return YES;
}

-(void) addSettlement:(Vertex*)v	{
//	NSLog(@"adding settlement");
	if ([settlements indexOfObject:v] == NSNotFound)
		[settlements addObject:v];
}
-(NSArray*) tradeRoutes	{
	int i;
	TradeRoute* tr;
	NSMutableArray* tradeRoutes = [NSMutableArray array];
	for (i = 0; i < [settlements count]; i++)	{
		tr = [[settlements objectAtIndex:i] tradeRoute];
		if (tr && [tradeRoutes indexOfObject:tr] == NSNotFound)
			[tradeRoutes addObject:tr];
	}
	return tradeRoutes;
}	

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation	{
//	NSLog(@"drag ended, operation = %d", operation);
	if (operation == NSDragOperationCopy)	{
		int i;
		for (i = 0; i < [draggedResources count]; i++)	{
			[resources removeObjectAtIndex:[resources indexOfObject:[draggedResources objectAtIndex:i]]];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RESOURCES_CHANGED_NOTIFICATION" object:self];
	}
	[draggedResources release];
	draggedResources = nil;
}


-(void) spend:(NSArray*)arr	{
//	NSLog(@"spending %@", arr);
	int i;
	for (i = 0; i < [arr count]; i++)	{
		[resources removeObjectAtIndex:[resources indexOfObject:[arr objectAtIndex:i]]];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RESOURCES_CHANGED_NOTIFICATION" object:self];
}

/*
- (void)outlineViewItemWillExpand:(NSNotification *)notification	{
	PP;
}	


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item	{
	PP;
	return NO;
}
*/



-(int) outlineView:(NSOutlineView*)ov numberOfChildrenOfItem:(id)item	{
	PP;
//	NSLog(@"item = %@", item);
	if (item == nil)	{
//		NSLog(@"returning 5");
		return 5;
	}
	if ([self itemIsCatagory:item])
		return [self countResourcesOfType:[self typeForItem:item]];
	
	return 0;
//	else 
//		return 0;
}

-(BOOL) outlineView:(NSOutlineView*)ov isItemExpandable:(id)item	{
	PP;
//	NSLog(@"item = %@", item);
//	return NO;
	if ([self itemIsCatagory:item] && [self countResourcesOfType:[self typeForItem:item]] > 0)
		return YES;
	return NO;
}

-(id) outlineView:(NSOutlineView*)ov child:(int)index ofItem:(id)item	{
	PP;
//	NSLog(@"child = %d, item = %@", index, item);
	if (item == nil)	{
		//NSLog(@"parent is nil");
		return [catagories objectAtIndex:index];
		if (index == 0)
//			return [catagories objec
			return [NSString stringWithFormat:@"Catagory: Brick", [self countResourcesOfType:@"Brick"]];
		else if (index == 1)
			return [NSString stringWithFormat:@"Catagory: Wood", [self countResourcesOfType:@"Wood"]];
		else if (index == 2)
			return [NSString stringWithFormat:@"Catagory: Sheep", [self countResourcesOfType:@"Sheep"]];
		else if (index == 3)
			return [NSString stringWithFormat:@"Catagory: Grain", [self countResourcesOfType:@"Grain"]];
		else if (index == 4)
			return [NSString stringWithFormat:@"Catagory: Ore", [self countResourcesOfType:@"Ore"]];
	}
	
//	NSLog(@"parent is not nil");
//	NSlog(@
	int i = [catagories indexOfObject:item];
	return [items objectAtIndex:i];
	return [self typeForItem:item];
	
//	return [item substringWithRange:NSMakeRange(10, [item length] - 1)];
//	return @"Fart";
}

-(int) countResourcesOfType:(NSString*)str	{
	int count = 0;
	int i;
	for (i = 0; i < [resources count]; i++)	{
		if ([str isEqualToString:[resources objectAtIndex:i]])
			count++;
	}	
	
	return count;
}

-(NSString*) typeForItem:(id)item	{
//	PP;
//	NSLog(@"item = %@", item);
	NSString* type;
	if ([item isKindOfClass:[NSString class]]  && [item length] > 10 && [[item substringWithRange:NSMakeRange(0, 10)] isEqualToString:@"Catagory: "])	
		type = [item substringWithRange:NSMakeRange(10, [item length] - 10)];
	else 
		type = item;
		
	return type;
}

-(BOOL) itemIsCatagory:(id)item	{
//	PP;
//	if (item)	{
//		NSLog(@"item isnn't null");
//		NSLog(@"it's an NSObject = %d", [item isKindOfClass:[NSObject class]]);
//		NSLog(@"it's %@", NSStringFromClass([item class]));
//	}
//	else
//		NSLog(@"item is mother fucking null");
//	if ([item length] > 10)
//		NSLog(@"'%@'", [item substringWithRange:NSMakeRange(0, 10)]);
	if ([item isKindOfClass:[NSString class]] && [item length] > 10 && [[item substringWithRange:NSMakeRange(0, 10)] isEqualToString:@"Catagory: "])
		return YES;
		
//	NSLog(@"returning NO");
	return NO;
}	


- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation	{
	PP;
//	[self addDevCard:[[GameController gameController] buyDevCard]];
	if ([[GameController gameController] buyDevCard] == NO)	{
		NSBeep();
		return NO;
	}
		
	[tableView reloadData];
	return YES;
}

-(NSArray*) settlements	{
	return settlements;
}

-(void) setActive:(BOOL)flag	{
	active = YES;
}	
-(int) score	{
	int score = [settlements count] + vpCards;
	int i;
	for (i = 0; i < [settlements count]; i++)	{
		if ([[[settlements objectAtIndex:i] item] class] == [CityToken class])
			score++;
	}
	if ([[GameController gameController] playerHasLongestRoad:self])
		score += 2;
	if ([[GameController gameController] playerHasLargestArmy:self])
		score += 2;

	return score;
//	return [settlements count] + vpCards;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation	{
	PP;
	[tableView setDropRow:row dropOperation:NSTableViewDropAbove];
	return NSDragOperationCopy;
}





-(id) outlineView:(NSOutlineView*)ov objectValueForTableColumn:(NSTableColumn*)tc byItem:(id)item	{
//	PP;
//	NSLog(@"item = %
	if ([self itemIsCatagory:item])
		return [NSString stringWithFormat:@"%@ (%d)", [self typeForItem:item], [self countResourcesOfType:[self typeForItem:item]]];

//	NSLog(@"PP.... item = %@", item);
	return item;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)dragItems toPasteboard:(NSPasteboard *)pboard	{
	PP;
//	NSLog(@"items = %@", dragItems);
	[pboard declareTypes:[NSArray arrayWithObject:@"CATAN_RESOURCE_TYPE"] owner:self];
	[pboard setPropertyList:dragItems forType:@"CATAN_RESOURCE_TYPE"];
	return YES;
	if ([dragItems count] == 4)	{
		id itm = [dragItems objectAtIndex:0];
		int i;
		for (i = 1; i < 4; i++)	{
			if (itm != [dragItems objectAtIndex:i])
				return NO;
		}
	}
	return YES;
//	if ([[GameController 
}

-(NSString *)tableView:(NSTableView *)aTableView toolTipForCell:(NSCell *)aCell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)aTableColumn row:(int)row mouseLocation:(NSPoint)mouseLocation	{
//	NSLog(@"Getting tooltip");
//	if (row > [myDevCards count])
//		return ni;
		
	NSString* type = [[myDevCards objectAtIndex:row] type];
	NSString* result = @"default tooltip";
	if ([type isEqualToString:@"Knight"])
		result = @"Use a Knight card to move the robber, and steal a card from an opposing player.  A Knight also contributes to largest army.";
	else if ([type isEqualToString:@"Monopoly"])
		result = @"Use a Monopoly card to steal every card of a particular resource, from all opposing players.";
	else if ([type isEqualToString:@"Road Building"])
		result = @"Use a Road Building card to build two free lengths of road.";
	else if ([type isEqualToString:@"Year of Plenty"])
		result = @"Use a Year of Plenty card to take two free resource cards from the bank.";
	else if ([type isEqualToString:@"Victory Point"])
		result = @"Use a Victory Point card for a free point.";
	else	
		result = [NSString stringWithFormat:@"There is no tooltip for %@.  (This should not have happened)", type];

	return result;
}



-(void) tableViewDoubleClick:(id)sender	{
	PP;
	
	int row = [sender clickedRow];
	if (row < 0 || row >= [myDevCards count])
		return;
		
	if ([[myDevCards objectAtIndex:[sender clickedRow]] playable] == NO)
		return;
	if ([[GameController gameController] currentPlayer] != self)  
		return ;
	if ([[GameController gameController] playDevCard:[[myDevCards objectAtIndex:row] type]] == NO)
		NSBeep();
	else
		[sender reloadData];

//		[myDevCards removeObjectAtIndex:[sender clickedRow]];
//	NSLog(@"here");
}

-(void) playDevCard:(NSString*)str	{
	int i;
	if ([str isEqualToString:@"Knight"])
		armySize++;
	else if ([str isEqualToString:@"Victory Point"])
		vpCards++;
	for (i = 0; i < [myDevCards count]; i++)	{
		if ([str isEqualToString:[[myDevCards objectAtIndex:i] type]])	{
			[myDevCards removeObjectAtIndex:i];
			return;
		}
	}
}


/*
-(void) resourceTableDoubleClicked:(id)sender	{
	PP;
//	id item = [sender itemAtRow:[sender clickedRow]];
//	DevelopmentCard* card = [myDevCards objectAtIndex:[sender clickedRow]];
//	NSLog(@"item = %@", item);	
//	if (cardsToDiscard > 0 && [sender clickedRow] >= 0 && [sender clickedRow] < [resources count])
//	[[GameController gameController] playDevCard:item];
}*/

-(int) discardCount	{
	return cardsToDiscard;
}

-(void) decreaseDiscardCountBy:(int)n	{
	cardsToDiscard -= n;
}
-(void) setDiscardIfNeeded	{
	if ([resources count] > 7)
		cardsToDiscard = [resources count] / 2;
	else
		cardsToDiscard = 0;
}

-(void) addRoad:(Edge*)e	{
	[myRoads addObject:e];
}	

-(int) roadCount	{
	return [myRoads count];
}
-(int) settlementCount	{
	int counter = 0;
	return [settlements count];
}

//CATAN_RESOURCE_TYPE


-(NSString*) name	{
	return myName;
}

-(NSColor*) color	{
//	return [NSColor blueColor];
	return myColor;
}

-(void) activateDevCards	{
	int i;
	for (i = 0; i < [myDevCards count]; i++)	{
		[[myDevCards objectAtIndex:i] setPlayable:YES];
	}
	[[GameController gameController] reloadDevCardTable];
}
-(void) deactivateDevCards	{
	int i;
	for (i = 0; i < [myDevCards count]; i++)	{
		[[myDevCards objectAtIndex:i] setPlayable:NO];
	}
	
	[[GameController gameController] reloadDevCardTable];
}
-(int) armySize	{
	return armySize;
}
/*

-(int) rollsRequiredToGainResource:(NSString*)singleRes	{
	NSArray* resBase = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	float gainsPerRoll[5] = {0};
	[self getGainsPerRoll:gainsPerRoll];
	int index = [resBase indexOfObject:singleRes];
	
	if (gainsPerRoll[index] == 0)
		return 0;
	int rollCount = 0;
	float resCount = 0;

	while (resCount < 1)	{
		rollCount++;
		resCount += gainsPerRoll[index];
	}
	
	return rollCount;
}*/


-(NSArray*) bestTradeResources:(int)count	{
	float gainsPerRoll[5] = {0};
	
}

-(NSArray*) twoToOneResources	{
	NSArray* trArray = [self tradeRoutes];
	NSString* res;
	NSMutableArray* result = [NSMutableArray array];
	int i;
	for (i = 0; i < [trArray count]; i++)	{
		res = [[trArray objectAtIndex:i] resource];
		if (res)
			[result addObject:res];
	}
	return result;
}

-(BOOL) hasThreeToOne	{
	NSArray* trArray = [self tradeRoutes];
	int i;
	for (i = 0; i < [trArray count]; i++)	{
		if ([[trArray objectAtIndex:i] resource] == nil)
			return YES;
	}	
	return NO;
}

/*
-(int) blahrollsRequiredToHaveResources:(NSArray*)targetArray	{
	NSMutableArray* myMutableResources = [NSMutableArray arrayWithArray:[self resources]];
	NSMutableArray* mutableTarget = [NSMutableArray arrayWithArray:targetArray];
	
	int i;
	NSString* res;
	for (i = 0; i < [targetArray count]; i++)	{	
		res = [targetArray objectAtIndex:i];
		if ([myMutableResources indexOfObject:res] != NSNotFound)	{
			[myMutableResources removeObject:res];
			[mutableTarget removeObject:res];
		}
	}
	
	return [self rollsRequiredToGainResources:[NSArray arrayWithArray:mutableTarget]];
}
*/

/*
-(int) rollsRequiredToStrictlyGainResources:(NSArray*)targetArray	{
	NSArray* resBase = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	float gainsPerRoll[5] = {0};
	int targets[5] = {0};
	int i;
	for (i = 0; i < [targetArray count]; i++)	{
		targets[[resBase indexOfObject:[targetArray objectAtIndex:i]]]++;
	}
	[self getGainsPerRoll:gainsPerRoll];

	int rollCounter = 0;
	float resCounts[5] = {0};
	
	BOOL done = NO;
	while (done == NO)	{
		rollCounter++;
		done = YES;
		for (i = 0; i < 5; i++)		{
			resCounts[i] += gainsPerRoll[i];
			if (resCounts[i] < targets[i])
				done = NO;
		}
	}
	
	return rollCounter;
}
*/

/*
-(int) rollsRequiredToGainAcquirableResources:(NSArray*)targetArray plus:(int)n	{
	
}*/


-(BOOL) canBuyResources:(NSArray*)target withResources:(NSArray*)source	{
//	NSLog(@"testing to buy %@, with %@", target, source);
	NSMutableArray* mutableTarget = [NSMutableArray arrayWithArray:target];
	NSMutableArray* mutableSource = [NSMutableArray arrayWithArray:source];
	NSString* res;
	int index;
	int i;
	for (i = 0; i < [target count]; i++)	{
		res = [target objectAtIndex:i];
		index = [mutableSource indexOfObject:res];
		if (index != NSNotFound)	{
			[mutableSource removeObjectAtIndex:index];
			index = [mutableTarget indexOfObject:res];
			[mutableTarget removeObjectAtIndex:index];
		}
	}
	
	if ([mutableTarget count] == 0)
		return YES;
	
//	NSLog(@"going to handle 2:1's");
//	NSLog(@"target = %@, source = %@", mutableTarget, mutableSource);
	NSArray* twoToOnes = [self twoToOneResources];
	for (i = 0; i < [twoToOnes count]; i++)	{
		res = [twoToOnes objectAtIndex:i];
		while ([mutableTarget count] > 0 && [mutableSource countForObject:res] >= 2)	{
			[mutableTarget removeObjectAtIndex:0];
			index = [mutableSource indexOfObject:res];
			[mutableSource removeObjectAtIndex:index];

			index = [mutableSource indexOfObject:res];
			[mutableSource removeObjectAtIndex:index];
		}
	}
	
	if ([mutableTarget count] == 0)
		return YES;
		
	int tradeRatio = 4;
	if ([self hasThreeToOne])
		tradeRatio = 3;

//	NSLog(@"going to handle regular trades, ratio = %d", tradeRatio);
	NSArray* resBase = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	int j;
	for (i = 0; i < [resBase count]; i++)	{
		res = [resBase objectAtIndex:i];
		while ([mutableTarget count] > 0 && [mutableSource countForObject:res] >= tradeRatio)	{
			[mutableTarget removeObjectAtIndex:0];
			
			for (j = 0; j < tradeRatio; j++)	{
			
				index = [mutableSource indexOfObject:res];
				[mutableSource removeObjectAtIndex:index];
			}
//			index = [mutableSource indexOfObject:res];
//			[mutableSource removeObjectAtIndex:index];
		}
	}
//	NSLog(@"
	if ([mutableTarget count] == 0)
		return YES;
		
	return NO;
}
/*
-(NSArray*) strictlyAcquirableResources	{
	float gainsPerRoll[5] = {0};
	NSMutableArray* result = [NSMutableArray array];
	NSArray* resBase = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	[self getGainsPerRoll:gainsPerRoll];
	
	int i;
	for (i = 0; i < 5; i++)	{
		if (gainsPerRoll[i] > 0)
			[result addObject:[resBase objectAtIndex:i]];
	}
	return result;
}
*/
-(int) rollsRequiredToGainResources:(NSArray*)targetArray	{
	if ([[self settlements] count] == 0)
		return 0;

	//-(BOOL) canBuyResources:(NSArray*)target withResources:(NSArray*)source	{
	NSArray* resBase = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	NSMutableArray* sourceRes = [NSMutableArray arrayWithArray:[self resources]];
	float projectedRes[5] = {0};
	int rollCounter = 0;
	int i, j;
	
	while ([self canBuyResources:targetArray withResources:sourceRes] == NO)	{
		rollCounter++;
		[self projectResources:projectedRes afterRolls:rollCounter];
//		NSLog(@"projection for %d rolls... %f, %f, %f, %f, %f", rollCounter, 
//			projectedRes[0],
//			projectedRes[1],
//			projectedRes[2],
//			projectedRes[3],
//			projectedRes[4]);
			
		sourceRes = [NSMutableArray arrayWithArray:[self resources]];
		for (i = 0; i < [resBase count]; i++)	{
			for (j = 1; j < projectedRes[i]; j++)	{
				[sourceRes addObject:[resBase objectAtIndex:i]];
			}
		}
	}
	
	return rollCounter;
}
/*
-(int) rollsRequiredToHaveResources:(NSArray*)targetArray	{
	BOOL threeToOneFlag;
	NSArray* twoToOneRes
	NSArray* resBase = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	float gainsPerRoll[5] = {0};
	[self getGainsPerRoll:gainsPerRoll];
	int i;
	NSMutableString* string = [NSMutableString stringWithString:@"GAINS PER ROLL:\n\n"];
	for (i = 0; i < [resBase count]; i++)	{
		[string appendFormat:@"%@, %f\n", [resBase objectAtIndex:i], gainsPerRoll[i]];
	}
	NSLog(@"%@", string);
	
}*/

-(void) projectResources:(float*)res afterRolls:(int)rolls	{
	[self getGainsPerRoll:res];
	
	int i;
	for (i = 0; i < 5; i++)	{
		res[i] = rolls * res[i];
	}
}


-(void) getGainsPerRoll:(float*)gainsPerRoll	{

    int i, j;

	for (i = 0; i  < 5; i++)	{
		gainsPerRoll[i] = 0;
	}
	NSArray* resBase = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
//	float gainsPerRoll[5] = {0};
	int index;
	Vertex* vert;
	NSArray* hexes;
	BoardHexagon* hex;
	NSString* aRes;
	float prob;
	for (i = 0; i < [settlements count]; i++)	{
		vert = [settlements objectAtIndex:i];
		hexes = [vert hexagons];
		for (j = 0; j < [hexes count]; j++)	{
			hex = [hexes objectAtIndex:j];
			aRes = [hex resource];
            if (aRes != nil && [resBase indexOfObject:aRes] != NSNotFound)  {
                prob = [hex probability];
                index = [resBase indexOfObject:aRes];
                if ([[vert item] isKindOfClass:[SettlementToken class]])
                    gainsPerRoll[index] += prob;
                else
                    gainsPerRoll[index] += (2 * prob);
            }
		}
	}
}


-(void) settlementWasRobbered:(BoardToken*)token	{
	resourcesLostToRobber++;
//	NSLog(@"SETTLEMENT WAS ROBBERED, %@, %@", [self name], token);
//	if ([token class] == [SettlementToken class])
//		resourcesLostToRobber += 1;
//	else
//		resourcesLostToRobber += 2;
//	NSLog(@"TOTAL = %d", resourcesLostToRobber);
}
/*
	int resourcesLostToRobber;
	int resourcesStolen;
	int earnedResources;
	float expectedResources;
	int sevensRolled;
*/

-(void) rolledSeven	{
	sevensRolled++;
}
-(int) stolenResources	{
	return resourcesStolen;
}

-(void) incrementStolenResources:(int)n	{
	resourcesStolen += n;
}
-(void) incrementEarnedResources:(int)n	{
//	NSLog(@"incrementing earned res by %d", n);
	earnedResources += n;
//	NSLog(@"val is %d", earnedResources);
}
-(void) incrementExpectedResources:(float)f	{
	expectedResources +=f;
}

-(int) sevensRolled	{
	return sevensRolled;
}
-(int) earnedResources	{
	return earnedResources;
}
-(float) expectedResources	{
	return expectedResources;
}
-(int) resourcesLostToRobber	{
	return resourcesLostToRobber;
}


-(int) tradedAway	{
	return tradedAway;
}
-(int) receivedInTrade	{
	return receivedInTrade;
}

-(void) tradedResources:(int)n	{
	tradedAway += n;
}
-(void) receivedResourcesViaTrade:(int)n	{
	receivedInTrade += n;
}


@end

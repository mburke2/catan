//
//  GameController.m
//  catan
//
//  Created by James Burke on 1/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

/*
phases...
	0 roll to see who goes first
	1 place first settlement and road
	2 place second settlement and road (reverse order)
	3 normal game play

*/

#import "Debug.h"

int indexOfMax(int array[4])	{
	int max = array[0];
	int index = 0;
	int i;
	for (i = 1; i < 4; i++)	{
		if (array[i] > max)	{
			max = array[i];
			index = i;
		}
	}
	return index;
}
#import "GameController.h"
#import "Control.h"
#import "BoardView.h"
#import "ResourceManager.h"

#define PP //NSLog(@"%s", __FUNCTION__)

static GameController* THE_SINGLE_GAME_CONTROLLER_INSTANCE = 0;

@implementation GameController

-(id) init	{
	self = [super init];
	if (self)	{
		turnIndex = 0;
		winner = nil;
		largestArmy = nil;
		phase = RollPhase;
		roadBuilderCounter = 0;
	//	thePlayer = [[Player alloc] init];
		vertices = [[NSMutableArray alloc] init];
	//	[self makeDevCards];
		canMoveRobber = NO;
		theBoard = nil;
		interface = nil;
		rolled = nil;
		canSteal = NO;
		gamePrefs = nil;
		playedKnight = NO;
		playedCard = NO;
		longestRoad = [[NSArray alloc] init];
		int i;
		for (i = 0; i < 4; i++)	{
			rollPhaseResultArray[i] = 0;
		}
		
	//	inProgress = NO;

	}
	return self;
}

-(BOOL) gameInProgress	{
	if (winner)
		return NO;
	if (interface || theBoard)
		return YES;
	return NO;
}

+(GameController*) gameController	{
	if (THE_SINGLE_GAME_CONTROLLER_INSTANCE == 0)
		THE_SINGLE_GAME_CONTROLLER_INSTANCE = [[GameController alloc] init];
	
	return THE_SINGLE_GAME_CONTROLLER_INSTANCE;
}


	
#pragma mark DRAGGING


-(BOOL) canDragRoadTo:(Edge*)edge	{
//	NSLog(@"checking road");
//	NSLog(@"rolled = %d, pref = %@", rolled, [gamePrefs objectForKey:@"CAN_PURCHASE"]);

	if ([players objectAtIndex:turnIndex] != thePlayer)
		return NO;
//	NSLog(@"canDragRoadTo");
	if ([edge item])
		return NO;

	if (rolled == NO && [[gamePrefs objectForKey:@"CAN_PURCHASE"] boolValue] == NO && phase != SetupPhase && phase != ReverseSetupPhase)
		return NO;
		
	NSArray* verts = [edge vertices];
	Vertex* vertex;
	NSArray* vertEdges;
	int i, j;
	for (i = 0; i < [verts count]; i++)	{
		vertex = [verts objectAtIndex:i];
		if ([vertex item] != nil && [[vertex item] owner] == thePlayer)
			return YES;
		
		vertEdges = [vertex edges];
		for (j = 0; j < [vertEdges count]; j++)	{
			if ([[vertEdges objectAtIndex:j] item] && [[[vertEdges objectAtIndex:j] item] owner] == thePlayer)
				return YES;
		}
		
	}
	
	return NO;
}

-(BOOL) canDragCityTo:(Vertex*)vertex	{
	if (rolled == NO && [[gamePrefs objectForKey:@"CAN_PURCHASE"] boolValue] == NO)
		return NO;
	
	if ([players objectAtIndex:turnIndex] != thePlayer)
		return NO;
	if ([vertex item] != nil && [[vertex item] class] == [SettlementToken class] && [[vertex item] owner ] == thePlayer)
		return YES;
//	if ([[vertex item] isEqualToString:@"Settlement"])
//		return YES;
	
	return NO;
}
-(BOOL) canDragSettlementTo:(Vertex*)vertex	{
	if (rolled == NO && [[gamePrefs objectForKey:@"CAN_PURCHASE"] boolValue] == NO && phase != SetupPhase && phase != ReverseSetupPhase)
		return NO;

	if ([players objectAtIndex:turnIndex] != thePlayer)
		return NO;
	if ([vertex item])
		return NO;
	int i;
	NSArray* neighbors = [vertex neighbors];
	
	for (i = 0; i < [neighbors count]; i++)
		if ([[neighbors objectAtIndex:i] item] != nil)
			return NO;	
	
	if (phase == SetupPhase || phase == ReverseSetupPhase)
		return YES;
	
	
	if (phase == PlayPhase)	{
		NSArray* edges = [vertex edges];
		for (i = 0; i < [edges count]; i++)	{
			if ([[[edges objectAtIndex:i] item] owner] == thePlayer && [[[edges objectAtIndex:i] item] class] == [RoadToken class]) // isEqualToString:@"Road"])
				return YES;
		}
	}
	
	return NO;
}

-(void) setActive:(BOOL)flag forIndex:(int)index	{
	Player* p = [players objectAtIndex:index];
	[p setActive:flag];
	[interface update];
}


-(void) interfaceBecameActive	{
//	[server activate];
	NSNumber* index = [NSNumber numberWithInt:[players indexOfObject:thePlayer]];
	[server notify:@selector(playerAtIndexBecameActive:) args:[NSArray arrayWithObject:index]];
	[self playerAtIndexBecameActive:index];
}

-(void) playerAtIndexBecameActive:(NSNumber*)n	{
	Player* p = [players objectAtIndex:[n intValue]];
	[p setActive:YES];
	[interface update];
}	

-(BOOL) buyDevCard	{
//	NSLog(@"drawDevCard");
	if ([devCards count] == 0)
		return NO;
	if (rolled == NO && [[gamePrefs objectForKey:@"CAN_PURCHASE"] boolValue] == NO)
		return NO;
	DevelopmentCard* c = [devCards objectAtIndex:0];
//	NSLog(@"got card here, it's %@", c);
	[c retain];
	[c autorelease];
	[devCards removeObjectAtIndex:0];
	
	if ([players objectAtIndex:turnIndex] == thePlayer)	{
		[server notify:_cmd args:nil];
	}

	[[players objectAtIndex:turnIndex] spend:[NSArray arrayWithObjects:@"Sheep", @"Ore", @"Grain", nil]];
	[[players objectAtIndex:turnIndex] addDevCard:c];
//	NSLog(@"got card");
//	NSLog(@"it's %@", c);
//	NSLog(@"%s, returning %@, %@", __FUNCTION__, c, [c type]);	
	[interface update];
//	return c;
	return YES;
}


#pragma mark BOARD MANAGEMENT


-(void) addVertexItem:(Vertex*)v	{
	[vertices addObject:v];
	[[players objectAtIndex:turnIndex] addSettlement:v];
//	[thePlayer addSettlement:v];

	if (phase == SetupPhase || phase == ReverseSetupPhase)	{
//		if (phase == ReverseSetupPhase)	{
		if (phase == SetupPhase && 
			(([players count] == 2 && [[players objectAtIndex:turnIndex] settlementCount] == 3)	||
			 ([players count] != 2 && [[players objectAtIndex:turnIndex] settlementCount] == 2))) {//[self umberOfSettlementsPlayerShouldHaveDuringSetup])	{
			NSArray* hexes = [v hexagons];
			int i;
			NSMutableDictionary* dict = [NSMutableDictionary dictionary];
			[dict setObject:[players objectAtIndex:turnIndex] forKey:@"Player"];
			[dict setObject:[NSMutableArray array] forKey:@"Resources"];
//			[dict setObject:[NSMutableArray array] forKey:@"Origins"];
			NSMutableArray* resInfoArr;
			for (i = 0; i < [hexes count]; i++)	{
				if ([[hexes objectAtIndex:i] resource])	{
					resInfoArr = [dict objectForKey:@"Resources"];
					[resInfoArr addObject:[[hexes objectAtIndex:i] resource]];
//					resInfoArr = [dict objectForKey:@"Origins"];
//					[resInfoArr addObject:[NSValue valueWithPoint:[(BoardHexagon*)[hexes objectAtIndex:i] center]]];
//					[[players objectAtIndex:turnIndex] addResource:[[hexes objectAtIndex:i] resource]];
				}
			}
//			[resourceManager distributeBoardResources:[NSArray arrayWithObject:dict]];
			[resourceManager distributeBoardResources:[NSDictionary dictionaryWithObjectsAndKeys:
				[NSArray arrayWithObject:dict], @"PlayerInfo",
				[NSArray array], @"Tiles", nil]];
		}
		[[players objectAtIndex:turnIndex] spend:[NSArray array]];
//		[thePlayer spend:[NSArray array]];
	//	return;
	}
	else if ([[v item] class] == [SettlementToken class])	{
	//	[thePlayer spend:[NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", nil]];
		[[players objectAtIndex:turnIndex] spend:[NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", nil]];
	}
	else if ([[v item] class] == [CityToken class]) 	{
	//	[thePlayer spend:[NSArray arrayWithObjects:@"Grain", @"Grain", @"Ore", @"Ore", @"Ore", nil]];
		[[players objectAtIndex:turnIndex] spend:[NSArray arrayWithObjects:@"Grain", @"Grain", @"Ore", @"Ore", @"Ore", nil]];

	}
	
	

//	[thePlayer spend:
	[interface update];
	BOOL flag = NO;
	if ([v tradeRoute])
		flag = YES;
	[interface updateBoardBackground:flag];
}


-(void) addItem:(NSString*)item toVertex:(NSNumber*)n	{
	NSArray* vertices = [theBoard tileIntersections];
	Vertex* vertex = [vertices objectAtIndex:[n intValue]];
	if ([item isEqualToString:@"City"])	
		[vertex setItem:[[[CityToken alloc] initWithOwner:[players objectAtIndex:turnIndex]] autorelease]];
	 else if ([item isEqualToString:@"Settlement"])	
		[vertex setItem:[[[SettlementToken alloc] initWithOwner:[players objectAtIndex:turnIndex]] autorelease]];
	else	{
		PP;
		NSLog(@"THIS SHOULD NOT HAVE HAPPENED");
	}
	[self addVertexItem:vertex];

	
	if ([players objectAtIndex:turnIndex] == thePlayer)	{
		[server notify:_cmd args:[NSArray arrayWithObjects:item, n, nil]];
	}
}

-(void) addRoadToEdge:(NSNumber*)n	{
	NSArray* edges = [theBoard tileEdges];
	Edge* e = [edges objectAtIndex:[n intValue]];
	[e setItem:[[[RoadToken alloc] initWithOwner:[players objectAtIndex:turnIndex]] autorelease]];
	[[e item] setEdge:e];
	[self addEdgeItem:e];
	
	if ([players objectAtIndex:turnIndex] == thePlayer)	
		[server notify:_cmd args:[NSArray arrayWithObject:n]];

}	

-(void) addEdgeItem:(Edge*)e	{

	if ([[e item] class] == [RoadToken class])	{//isEqualToString:@"Road"])
		[[players objectAtIndex:turnIndex] addRoad:e];

		if (roadBuilderCounter > 0)	{
			roadBuilderCounter--;
			[[players objectAtIndex:turnIndex] spend:[NSArray array]];

		}
		else	{
			if (phase == SetupPhase || phase == ReverseSetupPhase)
				[[players objectAtIndex:turnIndex] spend:[NSArray array]];
			else
				[[players objectAtIndex:turnIndex] spend:[NSArray arrayWithObjects:@"Brick", @"Wood", nil]];
		}
		
		//NSArray* lr = [[e item] computeLongestRoadExcluding:[NSArray array]];
		NSArray* lr = [[e item] computeLongestRoad];
//		BOOL shouldGiveLongestRoad;
		if ([lr count] > [longestRoad count])	{
			[self updateLongestRoad:lr];
//			[longestRoad release];
//			longestRoad = [NSArray arrayWithArray:lr];
//			[longestRoad retain];
		}
	}
	[interface update];
	[interface updateBoardBackground:NO];
}

-(void) updateLongestRoad:(NSArray*)newRoad	{
//	NSLog(@"updating longest road");
	Player* prevOwner = nil;
	Player* newOwner = nil;
	if ([longestRoad count] >= 5)
		prevOwner = [[[longestRoad objectAtIndex:0] item] owner];

//	[longestRoad release];
//	longestRoad = [NSArray arrayWithArray:newRoad];
//	[longestRoad retain];
	
	if ([newRoad count] >= 5)
		newOwner = [[[newRoad objectAtIndex:0] item] owner];
		
	if (newOwner && prevOwner != newOwner)	{
		NSDictionary* callback = [NSDictionary dictionaryWithObjectsAndKeys:
			self, @"TARGET",
			NSStringFromSelector(@selector(setLongestRoad:)), @"SELECTOR",
			newRoad, @"PARAMETER", 
			nil];
//		[longestRoad release];
		[self setLongestRoad:[NSArray array]];
		[resourceManager animateIconForProperty:@"LongestRoad" fromPlayer:prevOwner toPlayer:newOwner withCallback:callback];
		[resourceManager animateLongRoad:newRoad];
	}
	else	{
		[self setLongestRoad:newRoad];
//		longestRoad = [NSArray arrayWithArray:newRoad];
//		[longestRoad retain];
	}

}
-(void) setLongestRoad:(NSArray*)arr	{
//	NSLog(@"setting long road");
	[longestRoad release];
//	longestRoad = [arr retain];
	longestRoad = [NSArray arrayWithArray:arr];
	[longestRoad retain];
//	NSLog(@"set it, going to redraw stuff");
	[interface update];
}

-(NSArray*) longestRoad	{
	return longestRoad;
}	

-(void) setLargestArmy:(Player*)p	{
	largestArmy = p;
	[interface update];
}
-(BOOL) playerHasLongestRoad:(Player*)p	{
//	BOOL flag = NO;
//	NSLog(@"testing longest road");
//	if ([longestRoad count] > 5)
	
//	NSLog(@"player = %d", flag);
	if ([longestRoad count] >= 5 && [[[longestRoad objectAtIndex:0] item] owner] == p)
		return YES;
	return NO;
}


#pragma mark RESOURCE MANAGEMENT

-(BOOL) trade:(NSArray*)res from:(Player*)from to:(Player*)to	{
//	Player* from = [tradePlayers objectAtIndex:0];
//	Player* to = [tradePlayers objectAtIndex:1];
	
	if (from == thePlayer)	{
		[server notify:@selector(trade:fromToIndices:) args:[NSArray arrayWithObjects:
			res, [NSArray arrayWithObjects:[NSNumber numberWithInt:[players indexOfObject:from]],[NSNumber numberWithInt:[players indexOfObject:to]], nil], nil]];
	}
	
	[from spend:res];
	int i;
	[resourceManager tradeResources:res fromPlayer:from toPlayer:to];
	for (i = 0; i < [res count]; i++)	{
//		[to addResource:[res objectAtIndex:i]];
	}
	
	[interface update];
	return YES;

}

-(BOOL) trade:(NSArray*)res fromToIndices:(NSArray*)playerIndices	{
	if (rolled == NO && [[gamePrefs objectForKey:@"CAN_TRADE"] boolValue] == NO)
		return NO;
	[self trade:res from:[players objectAtIndex:[[playerIndices objectAtIndex:0] intValue]] to:[players objectAtIndex:[[playerIndices objectAtIndex:1] intValue]]];
	return YES;
}

-(void) stealFrom:(Player*)p	{
	PP;
//	if ([players objectAtIndex:turnIndex] == thePlayer)
//		[server notify:@selector(stealFromPlayerAtIndex:) args:[NSArray arrayWithObject:[NSNumber numberWithInt:[players indexOfObject:p]]]];
	
	NSString* res = [[p resources] objectAtIndex:rand() % [[p resources] count]];
	[self stealResource:res fromPlayer:p];
	
}
-(void) stealResource:(NSString*)res fromPlayer:(Player*)p	{
	PP;
	if ([players objectAtIndex:turnIndex] == thePlayer)
		[server notify:@selector(stealResource:fromPlayerAtIndex:) args:[NSArray arrayWithObjects:res, [NSNumber numberWithInt:[players indexOfObject:p]], nil]];
	
//	[[players objectAtIndex:turnIndex] addResource:res];
//	if ([players objectAtIndex:turnIndex] == [self localPlayer])
	[resourceManager stealResource:res fromPlayer:p toPlayer:[players objectAtIndex:turnIndex]];
//	[resourceManager tradeResources:[NSArray arrayWithObject:res] fromPlayer:p toPlayer:[players objectAtIndex:turnIndex]];
	[p spend:[NSArray arrayWithObject:res]];
	canSteal = NO;
	[interface update];
}

-(void) stealResource:(NSString*)res fromPlayerAtIndex:(NSNumber*)n	{
	PP;
	[self stealResource:res fromPlayer:[players objectAtIndex:[n intValue]]];
}

-(void) makeCurrentPlayerSpend:(NSArray*)arr	{
	[[players objectAtIndex:turnIndex] spend:arr];
	if ([players objectAtIndex:turnIndex] == thePlayer)
		[server notify:_cmd args:[NSArray arrayWithObject:arr]];
//	[thePlayer spend:arr];
}

-(void) makeCurrentPlayerGiveResourcesToBank:(NSArray*)arr	{
	[[players objectAtIndex:turnIndex] tradedResources:[arr count]];
	[[players objectAtIndex:turnIndex] spend:arr];
	if ([players objectAtIndex:turnIndex] == thePlayer)
		[server notify:_cmd args:[NSArray arrayWithObject:arr]];
}





-(BOOL) currentPlayerCanTradeToBank:(NSArray*)arr	{

	return YES;
}

-(int) bankValueForTrade:(NSArray*)arr	{
	PP;
	NSLog(@"rolled = %d, pref = %@", rolled, [gamePrefs objectForKey:@"CAN_TRADE"]);
	if (rolled == NO && [[gamePrefs objectForKey:@"CAN_TRADE"] boolValue] == NO)
		return 0;
	NSLog(@"here");
	NSMutableArray* trade = [NSMutableArray arrayWithArray:arr];
	NSArray* tradeRoutes = [thePlayer tradeRoutes];
	[trade sortUsingSelector:@selector(caseInsensitiveCompare:)];
	
	int value = 0;
	int i;
	BOOL threeToOneFlag = NO;
	for (i = 0; i < [tradeRoutes count]; i++)	{
		if ([[tradeRoutes objectAtIndex:i] resource] == nil)
			threeToOneFlag = YES;
		else	{
			value += [self twoToOneTradeValue:trade forResource:[[tradeRoutes objectAtIndex:i] resource]];
			[trade removeObject:[[tradeRoutes objectAtIndex:i] resource]];  
		}
	}
	
	[trade sortUsingSelector:@selector(caseInsensitiveCompare:)];
//	int counts[5] = {0, 0, 0, 0, 0};
	NSString* res = nil;
	int tmpCount = 0;
	for (i = 0; i < [trade count]; i++)	{
		if ([res isEqualToString:[trade objectAtIndex:i]] == NO)	{
			if (threeToOneFlag)
				value += (tmpCount / 3);
			else
				value += (tmpCount / 4);
			res = [trade objectAtIndex:i];
			tmpCount = 0;
		}
		
		tmpCount++;
	}
	if (threeToOneFlag)
		value += tmpCount / 3;
	else
		value += tmpCount / 4;
	
	return value;
}

-(int) twoToOneTradeValue:(NSArray*)trade forResource:(NSString*)str	{
	int i;
	int count = 0;
	for (i = 0; i < [trade count]; i++)
		if ([str isEqualToString:[trade objectAtIndex:i]])
			count++;
			
	return count / 2;
}

-(void) resCounts:(int[5])result	{
	int i;
	NSString* res;
	result[0] = 0; result[1] = 0; result[2] = 0; result[3] = 0; result[4] = 0;
	for (i = 0; i < [[thePlayer resources] count]; i++)	{
		res = [[thePlayer resources] objectAtIndex:i];
		if ([res isEqualToString:@"Wood"])
			result[0]++;
		else if ([res isEqualToString:@"Brick"])
			result[1]++;
		else if ([res isEqualToString:@"Sheep"])
			result[2]++;
		else if ([res isEqualToString:@"Grain"])
			result[3]++;
		else if ([res isEqualToString:@"Ore"])
			result[4]++;
	}
}


-(BOOL) localPlayerMustDiscard	{
	if ([thePlayer discardCount] > 0)
		return YES;
	return NO;
}

-(void) player:(Player*)p discarded:(NSArray*)resArr	{
	if (p == thePlayer)
		[server notify:@selector(playerAtIndex:discarded:) args:[NSArray arrayWithObjects:[NSNumber numberWithInt:[players indexOfObject:p]], resArr, nil]];
		
	[p spend:resArr];
	[p decreaseDiscardCountBy:[resArr count]];
	
	[interface update];
}

-(void) playerAtIndex:(NSNumber*)n discarded:(NSArray*)arr	{
	[self player:[players objectAtIndex:[n intValue]] discarded:arr];
}


#pragma mark NEXT


-(Player*) winner	{
	return winner;
}
//numberOfSettlementsPlayerShouldHaveDuringSetup
-(BOOL) turnCanEnd	{
	if (phase == RollPhase)
		return NO;
	else if (phase == SetupPhase)	{
		int n = [self numberOfSettlementsPlayerShouldHaveDuringSetup];
		if ([[players objectAtIndex:turnIndex] settlementCount] == n && [[players objectAtIndex:turnIndex] roadCount] == n)
			return YES;
//		if ([[players objectAtIndex:turnIndex] settlementCount] == 1 && [[players objectAtIndex:turnIndex] roadCount] == 1)
//			return YES;
		return NO;
	} else if (phase == ReverseSetupPhase)	{
		if ([[players objectAtIndex:turnIndex] settlementCount] == 2 && [[players objectAtIndex:turnIndex] roadCount] == 2)
			return YES;
		return NO;
	}
	
	if (rolled == NO || canMoveRobber == YES || roadBuilderCounter > 0)
		return NO;

	int i;
	for (i = 0; i < [players count]; i++)	{
		if ([[players objectAtIndex:i] discardCount] > 0)
			return NO;
	}
	
	return YES;
		
}



-(void) robberMoved	{
//	NSLog(@"ROBBER MOVED");
//	if (thePlayer == [players objectAtIndex:turnIndex])
//		[server notify:_cmd args:nil];
	canMoveRobber = NO;
	if ([players objectAtIndex:turnIndex] == thePlayer)
		canSteal = YES;
	[interface update];
	[interface updateBoardBackground:NO];

}

-(BOOL) canSteal	{
	return canSteal;
}	

-(void) giveResourceToCurrentPlayerFromBank:(NSString*)res	{
//	[[players objectAtIndex:turnIndex] addResource:res];
	[[players objectAtIndex:turnIndex] receivedResourcesViaTrade:1];
	[resourceManager tradeResources:[NSArray arrayWithObject:res] fromBankToPlayer:[players objectAtIndex:turnIndex]];
	if ([players objectAtIndex:turnIndex] == thePlayer)
		[server notify:_cmd args:[NSArray arrayWithObject:res]];
}	

-(void) giveResource:(NSString*)res	{
	[[players objectAtIndex:turnIndex] addResource:res];
	if ([players objectAtIndex:turnIndex] == thePlayer)
		[server notify:_cmd args:[NSArray arrayWithObject:res]];

}


-(BOOL) canMoveRobber	{
//	return YES;
	return canMoveRobber;
}






-(void) makeDevCards	{
	devCards = [[NSMutableArray alloc] init];
	
	int i;

	
	for (i = 0; i < 2; i++)	{
		[devCards addObject:[DevelopmentCard cardWithType:@"Road Building"]];
		[devCards addObject:[DevelopmentCard cardWithType:@"Year of Plenty"]];
		[devCards addObject:[DevelopmentCard cardWithType:@"Monopoly"]];
	}
	
	for (i = 0; i < 5; i++)	{
		[devCards addObject:[DevelopmentCard cardWithType:@"Victory Point"]];
	}
	for (i = 0; i < 14; i++)	{
		[devCards addObject:[DevelopmentCard cardWithType:@"Knight"]];
	}
	

//	[devCards shuffle];
}
/*
	tradeBox, @"CAN_TRADE", purchaseBox, @"CAN_PURCHASE", devCardUseageBox, @"CAN_PLAY_DEV_CARD",
		onePerTurnBox, @"ONE_PER_TURN", excludeVPBox, @"EXCLUDE_VP", knightBox, @"ONLY_KNIGHT", 
		knightBeforeRoll, @"KNIGHT_BEFORE_ROLL",  nil];
*/

/*
	options... allow all dev cards before roll
				only allow knights before roll
				allow none before roll
*/


-(BOOL) playDevCard:(NSString*)card	{
//	NSLog(@"rolled = %d, canPlayCard = %@, knightBeforeRoll = %@", rolled, [gamePrefs objectForKey:@"CAN_PLAY_DEV_CARD"], [gamePrefs objectForKey:@"KNIGHT_BEFORE_ROLL"]);
	NSLog(@"rolled = %d, prefs = %@", rolled, gamePrefs);
	if (rolled == NO)	{
		if ([[gamePrefs objectForKey:@"CAN_PLAY_DEV_CARD"] boolValue] == NO )
			return NO;
		else if ([card isEqualToString:@"Knight"] == NO && [[gamePrefs objectForKey:@"KNIGHT_BEFORE_ROLL"] boolValue] == YES)
			return NO;
//		if (([card isEqualToString:@"Knight"] && [[gamePrefs objectForKey:@"KNIGHT_BEFORE_ROLL"] boolValue]) == NO)
//			return NO;
	}
	
	if (playedCard && [[gamePrefs objectForKey:@"ONE_PER_TURN"] boolValue] == YES)	{
		if ([[gamePrefs objectForKey:@"EXCLUDE_VP"] boolValue] == YES)	{
			if ([card isEqualToString:@"Victory Point"] == NO)
				return NO;
		}
		else if ([[gamePrefs objectForKey:@"ONLY_KNIGHT"] boolValue] == YES)	{
			if (playedKnight)
				return NO;
		}
		else
			return NO;
	}
	
	
	if ([card isEqualToString:@"Knight"])
		playedKnight = YES;
		
	if ([card isEqualToString:@"Victory Point"] == NO || [[gamePrefs objectForKey:@"EXCLUDE_VP"] boolValue] == NO)
		playedCard = YES;
		
//		return NO;
//	return NO;
	//NSLog(@"playing %@", [card type]);
	[[players objectAtIndex:turnIndex] playDevCard:card];
	if ([card isEqualToString:@"Knight"])	{
		[self updateLargestArmy:[players objectAtIndex:turnIndex]];
	}	
	[interface devCardPlayed:card];
	
	BOOL local = NO;
	if (thePlayer == [players objectAtIndex:turnIndex])	{
		local = YES;
		[server notify:_cmd args:[NSArray arrayWithObject:card]];
	}
	
	if ([card isEqualToString:@"Year Of Plenty"])	{
	//	NSLog(@"card is Yop");
		if (local)	{	
	//		NSLog(@"local is true");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"YoPNote" object:nil];
		}
	//	else
	//		NSLog(@"local is false");
	}
	
	else if ([card isEqualToString:@"Road Building"])	{
	//	if (local)	{
			roadBuilderCounter = 2;
		if (local)	{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ROAD_BUILDER_PLAYED" object:[players objectAtIndex:turnIndex]];
		}
	}
	
	else if ([card isEqualToString:@"Knight"])	{
		if (local)
			canMoveRobber = YES;
	}
	
	else if ([card isEqualToString:@"Monopoly"])	{
		if (local)
			[[NSNotificationCenter defaultCenter] postNotificationName:@"MonopolyNote" object:nil];
	}
	
	else if ([card isEqualToString:@"Victory Point"])	{
		if (local)	{
		
		}
	}	
	
	
	else	{
		NSLog(@"weird card, %@", card);
		return NO;	
	}
	
	
	[interface update];
	return YES;
}

-(BOOL) playerHasLargestArmy:(Player*)p	{
	if (p == nil)
		return NO;
	if (p == largestArmy)
		return YES;
	return NO;
}


-(void) monopolize:(NSString*)res	{
	if (thePlayer == [players objectAtIndex:turnIndex])
		[server notify:_cmd args:[NSArray arrayWithObject:res]];
	
	Player* p;
	NSArray* resArray;
	NSMutableArray* tmp;
	
	int i, j;
	for (i = 0; i < [players count]; i++)	{
		p = [players objectAtIndex:i];
		resArray = [p resources];
		tmp = [NSMutableArray array];
		for (j = 0; j < [resArray count]; j++)		{
			if ([res isEqualToString:[resArray objectAtIndex:j]])
				[tmp addObject:[resArray objectAtIndex:j]];
		}
		[p spend:tmp];
		[p incrementStolenResources:[tmp count]];
		/*
		-(void) tradedResources:(int)n;
-(void) receivedResourcesViaTrade:(int)n;
*/
		[p tradedResources:-1 * [tmp count]];
		[[players objectAtIndex:turnIndex] receivedResourcesViaTrade:-1 * [tmp count]];
		[resourceManager tradeResources:tmp fromPlayer:p toPlayer:[players objectAtIndex:turnIndex]];
//		for (j = 0; j < [tmp count]; j++)	{
//			[[players objectAtIndex:turnIndex] addResource:[tmp objectAtIndex:j]];
//		}
	}
	
	[interface monoplized:res];
	[interface update];

}



-(BOOL) canBuildRoad	{

	if (phase == RollPhase)
		return NO;
	if (phase == SetupPhase || phase == ReverseSetupPhase)	{
		if ([thePlayer roadCount] == [thePlayer settlementCount] - 1)
			return YES;
		return NO;
	}	
	int resCount[5];
	[self resCounts:resCount];
	if ((resCount[0] > 0 && resCount[1] > 0) || (roadBuilderCounter > 0 && thePlayer == [players objectAtIndex:turnIndex]))
		return YES;
	
	return NO;
}

-(int) numberOfSettlementsPlayerShouldHaveDuringSetup	{
	int count = 0;
	int i;
//	int index = [players indexOfObject:thePlayer];
//	NSLog(@"getting number of settlements... placementCounter = %d", placementCounter);
	for (i = 0; i < placementCounter; i++)	{
		if (turnIndex == [[placementIndices objectAtIndex:i] intValue])
			count++;
	}
	
	return count;
}

-(BOOL) canBuildSettlement	{

	if (phase == RollPhase)
		return NO;
		
	if (phase == SetupPhase)	{
//		return YES;
		if ([thePlayer settlementCount] < [self numberOfSettlementsPlayerShouldHaveDuringSetup])
			return YES;
//		if ([thePlayer settlementCount] == [thePlayer roadCount])
//			return YES;
		//if ([thePlayer settlementCount] == 0)
		//	return YES;
		return NO;
	}
	else if (phase == ReverseSetupPhase)	{
		if ([thePlayer settlementCount] == 1)
			return YES;
		return NO;
	}
	if ([self availableSettlementsForLocalPlayer] <= 0)
		return NO;

	
	int resCount[5];
	[self resCounts:resCount];
		
	if (resCount[0] > 0 && resCount[1] > 0 && resCount[2] > 0 && resCount[3] > 0)
		return YES;
	
	return NO;
}
-(BOOL) canBuildCity	{
	if (phase != PlayPhase)
		return NO;
	
	if ([self availableCitiesForLocalPlayer] <= 0)
		return NO;
	
	int resCount[5];
	[self resCounts:resCount];
	if (resCount[3] > 1 && resCount[4] > 2)
		return YES;
	return NO;
}
-(BOOL) canBuildDevCard	{
	if (phase != PlayPhase)
		return NO;
		
	int resCount[5];
	[self resCounts:resCount];
	if (resCount[2] > 0 && resCount[3] > 0 && resCount[4] > 0)
		return YES;
	return NO;
}



/*
-(void) performRoll:(NSArray*)rollArray	{
	
}*/
-(void) performRoll:(NSArray*)rollArray	{
//	NSLog(@"rolling");
	if (rolled)	{
		NSLog(@"already rolled, ignoring request");
		return;
	}
	rolled = YES;

	NSNumber* n1 = [rollArray objectAtIndex:0];
	NSNumber* n2 = [rollArray objectAtIndex:1];
	if (phase == RollPhase)	{
		rollPhaseResultArray[turnIndex] = [n1 intValue] + [n2 intValue];
	}
//	if (phase == SetupPhase || phase == ReverseSetupPhase)
//		return NO;
//	if (rolled == YES)
//		return NO;
	
//	int r = [n1 intValue]  + [n2 intValue];

	if ([players objectAtIndex:turnIndex] == thePlayer)	{
		//[server notify:_cmd args:[NSArray arrayWithObjects:n1, n2, nil]];
		[server notify:_cmd args:[NSArray arrayWithObject:rollArray]];
	}		
	[interface setRollValue1:[n1 intValue] value2:[n2 intValue]];
//	NSDictionary* waitDict = [NSDictionary dictionaryWithObjectsAndKeys:
//		[NSNumber numberWithFloat:[interface diceRollAnimationDelay]], @"Delay",
//		NSStringFromSelector(@selector(secondPerformRoll:)), @"Selector",
//		rollArray, @"Argument", nil];
		
//	[NSThread detachNewThreadSelector:@selector(waitAndCall:) toTarget:self withObject:waitDict];
	if (DEBUG_MODE)
		[self secondPerformRoll:rollArray];
	else
		[self performSelector:@selector(secondPerformRoll:) withObject:rollArray afterDelay:[interface diceRollAnimationDelay]];
//	if (canMoveRobber)
//		return NO;
}
/*
-(void) waitAndCall:(NSDictionary*)dict	{
	NSAutoreleasePool* threadPool = [[NSAutoreleasePool alloc] init];
	float delay = [[dict objectForKey:@"Delay"] floatValue];
	NSLog(@"waiting %f", delay);
	SEL sel = NSSelectorFromString([dict objectForKey:@"Selector"]);
	NSArray* arg = [dict objectForKey:@"Argument"];
	
	NSDate* startDate = [NSDate date];
	NSDate* endDate = [NSDate dateWithTimeIntervalSinceNow:delay];
	
	while (-[startDate timeIntervalSinceNow] < delay)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
	
	NSLog(@"calling method");
	[self performSelectorOnMainThread:sel withObject:arg waitUntilDone:NO];
	[threadPool release];
}	
*/

-(void) secondPerformRoll:(NSArray*)rollArray	{
    NSLog(@"%s", __FUNCTION__);
	NSNumber* n1 = [rollArray objectAtIndex:0];
	NSNumber* n2 = [rollArray objectAtIndex:1];
	int r = [n1 intValue] + [n2 intValue];
	if (phase == RollPhase)	{
		//NSLog(@"phase = RollPhase");
		#warning moved this chunk to first perform roll
//		rollPhaseResultArray[turnIndex] = r;
	}
	else	{
			int i, j;

		if (DEBUG_MODE == 0)	{
			if (r == 7)		{
				[[players objectAtIndex:turnIndex] rolledSeven];
				for (i = 0; i < [players count]; i++)	{
					[[players objectAtIndex:i] setDiscardIfNeeded];
				}
	//			[thePlayer setDiscardIfNeeded];
				if ([players objectAtIndex:turnIndex] == thePlayer)	{
//					NSLog(@"setting robber to moveable");
					canMoveRobber = YES;
				}
			}
		}
        NSLog(@"in else");

		//if (roadBuilderCounter > 0)
		//	return NO;

//		BOOL changed = NO;
		NSArray* hexagons;
		BoardHexagon* aHex;
		NSMutableDictionary* tmpDict = [NSMutableDictionary dictionary];
		NSMutableArray* tileArray = [NSMutableArray array];
		NSMutableDictionary* innerDict;
		NSMutableArray* resInfoArray;
		Player* tokenOwner;
		for (i = 0; i < [players count]; i++)	{
			innerDict = [NSMutableDictionary dictionary];
			[innerDict setObject:[players objectAtIndex:i] forKey:@"Player"];
			[innerDict setObject:[NSMutableArray array] forKey:@"Resources"];
//			[innerDict setObject:[NSMutableArray array] forKey:@"Origins"];
//			[innerDict setObject:[NSMutableArray array] forKey:@"Tiles"];
			[tmpDict setObject:innerDict forKey:[NSString stringWithFormat:@"%d", i]];
		}
    //    NSLog(@"innerDict = %@", innerDict);
		for (i = 0; i < [vertices count]; i++)	{
			hexagons = [(Vertex*)[vertices objectAtIndex:i] hexagons];
//            NSLog(@"vertex = %d", i);
			for (j = 0; j < [hexagons count]; j++)	{
  //              NSLog(@"hex = %d", j);
  
				aHex = [hexagons objectAtIndex:j];
				if ([aHex diceValue] == r && [tileArray indexOfObject:aHex] == NSNotFound)
					[tileArray addObject:aHex];
				if ([aHex diceValue] == r)	{
					tokenOwner = [[[vertices objectAtIndex:i] item] owner];
					if ([aHex robber] == NO)	{
						innerDict = [tmpDict objectForKey:[NSString stringWithFormat:@"%lu", [players indexOfObject:tokenOwner]]];
						[[innerDict objectForKey:@"Resources"] addObject:[aHex resource]];
					}
					else	{
						[tokenOwner settlementWasRobbered:[[vertices objectAtIndex:i] item]];
					}
				}
			}
		}
		NSMutableArray* resArray = [NSMutableArray array];
		NSArray* keys = [tmpDict allKeys];
		for (i = 0; i < [keys count]; i++)	{
			innerDict = [tmpDict objectForKey:[keys objectAtIndex:i]];
			if ([[innerDict objectForKey:@"Resources"] count] > 0)
				[resArray addObject:[tmpDict objectForKey:[keys objectAtIndex:i]]];
		}
		
		
		float gains[5];
		Player* aPlayer;
		int q;
		float sum;
		for (i = 0; i < [players count]; i++)	{
			for (q = 0; q < 5; q++)	{
				gains[q] = 0;
			}
			aPlayer = [players objectAtIndex:i];
			[aPlayer getGainsPerRoll:gains];
			sum = 0;
			for (q = 0; q < 5; q++)	{
				sum += gains[q];
			}
            /* !!!!! this seems to cause crashes sometimes... not sure why */
			[aPlayer incrementExpectedResources:sum];
		}
		[resourceManager distributeBoardResources:[NSDictionary dictionaryWithObjectsAndKeys:
			tileArray, @"Tiles", resArray, @"PlayerInfo", nil]];
		
			
	}

//	if (phase == RollPhase && [players objectAtIndex:turnIndex] == localPlayer && rolled == YES)
	if (phase == RollPhase && [players objectAtIndex:turnIndex] == thePlayer && rolled == YES)	{
//		[self endTurn];
//		[self performSelector:@selector(endTurn) withObject:nil afterDelay:0.1];
		[self endTurn];
//		[interface update];
	}

//	[interface update];
}
	
-(void) endRoll	{
	[interface update];
//	NSLog(@"canMoveRobber = %d", canMoveRobber);
//	return YES;
}

-(void) printGuesstimates	{
	return;
	NSLog(@"PRINTING GUESSTIMATES");
	int q;
	NSArray* blargh = [NSArray arrayWithObjects:
		[NSArray arrayWithObjects:@"Brick", @"Wood", nil],
		[NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", nil],
		[NSArray arrayWithObjects:@"Grain", @"Grain", @"Ore", @"Ore", @"Ore", nil],
		[NSArray arrayWithObjects:@"Sheep", @"Grain", @"Ore", nil], nil];
		
	int i;
	NSArray* blarghNames = [NSArray arrayWithObjects:@"Road", @"Sett.", @"City", @"Dev. Card", nil];
	Player* aLameTemporaryPlayer;
	int theRollGuesstimate;
	for (q = 0; q < [players count]; q++)	{
		aLameTemporaryPlayer = [players objectAtIndex:q];
		NSLog(@"%@", [aLameTemporaryPlayer name]);
		for (i = 0; i < [blargh count]; i++)	{
			theRollGuesstimate = [aLameTemporaryPlayer rollsRequiredToGainResources:[blargh objectAtIndex:i]];
			NSLog(@"%@: %d", [blarghNames objectAtIndex:i], theRollGuesstimate);
		}
	}
	
	NSLog(@"DONE PRINTING");
}

-(int) numberOfRowsInTableView:(NSTableView*)tv    {
    if (tv == statsTable)
        return 7;
    return 0;
}

-(id) tableView:(NSTableView*)tv objectValueForTableColumn:(NSTableColumn*)tc row:(int)r    {
//    NSLog(@"getting thing for %@, %d", [tc identifier], r);
    NSString* ident = [tc identifier];
    
    
    if ([ident isEqualToString:@"Heading"]) {
        NSArray* types = [NSArray arrayWithObjects:@"Earned Resources:", @"Expected Earned Resources:", @"Sevens Rolled:", @"Resources Lost To Robber:", @"Resources Stolen:", @"Resources Traded Away:", @"Recived Through Trade:", nil];
        
        return [types objectAtIndex:r];
    }
//Resources Lost To Robber
//Expected Earned Resources
    
    Player* player = nil;
    for (Player* p in players)  {
        if ([[p name] isEqualToString:ident])
            player = p;
    }
    
    if (player == nil)  {
        NSLog(@"%s THIS SHOULD NOT HAPPEN", __FUNCTION__);
    }
    
    if (r == 0)
        return [NSString stringWithFormat:@"%d", [player earnedResources]];
    else if (r == 1)
        return [NSString stringWithFormat:@"%0.1f", [player expectedResources]];
    else if (r == 2)
        return [NSString stringWithFormat:@"%d", [player sevensRolled]];
    else if (r == 3)
        return [NSString stringWithFormat:@"%d", [player resourcesLostToRobber]];
    else if (r == 4)
        return [NSString stringWithFormat:@"%d", [player stolenResources]];
    else if (r == 5)
        return [NSString stringWithFormat:@"%d", [player tradedAway]];
    else if (r == 6)
        return [NSString stringWithFormat:@"%d", [player receivedInTrade]];

    
    
    return @"WHOOPS";
    
}

-(void) printEndGameStats   {
//    NSLog(@"%s", __FUNCTION__);
//    NSLog(@"statsTable = %@", statsTable);
    [[NSBundle mainBundle] loadNibNamed:@"StatsWindow" owner:self topLevelObjects:nil];
//    NSLog(@"now statsTable = %@", statsTable);
    NSFont* font = [NSFont systemFontOfSize:14];
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    
    NSAttributedString* string;
    NSTableColumn* tc;
    tc = [[NSTableColumn alloc] initWithIdentifier:@"Heading"];
    string = [[NSAttributedString alloc] initWithString:@"Expected Earned Resources:" attributes:attributes];
    [tc setWidth:[string size].width];
    [[tc headerCell] setTitle:@""];
    [statsTable addTableColumn:tc];

    NSMutableArray* usedPlayers = [NSMutableArray array];
    for (Player* p in players)  {
        if ([usedPlayers indexOfObject:p] == NSNotFound)    {
//        [[tc headerCell] setTitle:[p name]];
        
            string = [[NSAttributedString alloc] initWithString:@"999.9" attributes:attributes];
            tc = [[NSTableColumn alloc] initWithIdentifier:[p name]];
            [tc setWidth:[string size].width];
            [[tc headerCell] setTitle:[p name]];
            [statsTable addTableColumn:tc];
            [usedPlayers addObject:p];
        }
    }
    
//    NSLog(@"going to reload table... columns = %@\n%lu", [statsTable tableColumns], [[statsTable tableColumns] count]);
    [statsTable reloadData];
}

-(void) oldprintEndGameStats	{
	int i;
	NSMutableString* junkStr = [NSMutableString string];
	[junkStr appendString:@"\nEnd Game Stats:"];
	Player* aTempPlayer;
	for (i = 0; i < [players count]; i++)	{
		aTempPlayer = [players objectAtIndex:i];
		[junkStr appendFormat:@"\n%@:\n", [aTempPlayer name]];
		[junkStr appendFormat:@"\tEarned Resources:          %d\n", [aTempPlayer earnedResources]];
		[junkStr appendFormat:@"\tExpected Earned Resources: %f\n", [aTempPlayer expectedResources]];
		[junkStr appendFormat:@"\tSevens Rolled:             %d\n", [aTempPlayer sevensRolled]];
		[junkStr appendFormat:@"\tResources lost to robber:  %d\n", [aTempPlayer resourcesLostToRobber]];
		[junkStr appendFormat:@"\tResources stolen:          %d\n", [aTempPlayer stolenResources]];
		[junkStr appendFormat:@"\tTraded away:               %d\n", [aTempPlayer tradedAway]];
		[junkStr appendFormat:@"\tReceived through trade:    %d\n", [aTempPlayer receivedInTrade]];
	}
		
	NSLog(@"%@", junkStr);
}

-(void) endTurn	{
	PP;
	NSLog(@"%s, turnIndex = %d", __FUNCTION__, turnIndex);
	[self printGuesstimates];

	if ([[players objectAtIndex:turnIndex] score] >= [self winningPointTotal])	{
		winner = [players objectAtIndex:turnIndex];
		[resourceManager runEndGameAnimation];
		[self printEndGameStats];
	}
	[self printPhase];
	//NSLog(@"turnIndex = %d", turnIndex);
//	if ([players
	if ([players objectAtIndex:turnIndex] == thePlayer)
		[server notify:_cmd args:nil];
//	if (phase == ReverseSetupPhase)
//		turnIndex--;
//	else
//		turnIndex++;
	if (phase == SetupPhase)	{
		if (placementCounter < [placementIndices count])
			turnIndex = [[placementIndices objectAtIndex:placementCounter] intValue];
		placementCounter++;
	}
	else
		turnIndex++;
	
	//NSLog(@"here, turnIndex = %d", turnIndex);
//	NSLog(@"player count = %d", [players count]);

	if (turnIndex < 0)		{
		//NSLog(@"too small");
		turnIndex = [players count] - 1;
	}
	else if (turnIndex >= [players count])	{
		//NSLog(@"too big");
		turnIndex = 0;
	}

	
	
//	NSLog(@"after modification, turnIndex = %d", turnIndex);
	if (phase == RollPhase && turnIndex == 0)	{
		turnIndex = indexOfMax(rollPhaseResultArray);
		placementCounter = 1;
		[self buildPlacementIndicesStartingWithIndex:turnIndex];
		phase = SetupPhase;
		firstPlayer = turnIndex;
		[thePlayer spend:[NSArray array]];
	}
	
	else if (phase == SetupPhase)	{
		//placementCounter++;
		if (placementCounter > [placementIndices count])	{
			turnIndex = firstPlayer;
			if (turnIndex < 0)
				turnIndex = [players count] - 1;
				
			phase = PlayPhase;
		}
	}

	rolled = NO;	
	[thePlayer spend:[NSArray array]];
	
	if ([players objectAtIndex:turnIndex] == thePlayer)	{
		NSBeep();
		[NSApp requestUserAttention:NSInformationalRequest];
	}
		
	playedCard = NO;
	playedKnight = NO;
	[thePlayer activateDevCards];
	[interface update];

}

-(void) buildPlacementIndicesStartingWithIndex:(int)n	{
	if ([players count] == 2)	{
		placementIndices = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:n],
			[NSNumber numberWithInt:(n + 1) % 2],
			[NSNumber numberWithInt:(n + 1) % 2],
			[NSNumber numberWithInt:n],
			[NSNumber numberWithInt:(n + 1) % 2],
			[NSNumber numberWithInt:n],
			nil];
	}
	else	{
		int i;
		NSMutableArray* tmp = [NSMutableArray array];
		for (i = 0; i < [players count]; i++)	{
			[tmp addObject:[NSNumber numberWithInt:(n + i) % [players count]]];
		}
		for (i = [players count] - 1; i >= 0; i--)	{
			[tmp addObject:[NSNumber numberWithInt:(n + i) % [players count]]];			
		}
		
		placementIndices =[NSArray arrayWithArray:tmp];
	}
	
//	NSLog(@"PLACEMENT INDICES = %@", placementIndices);
	[placementIndices retain];
}


-(BOOL) rolled	{
	return rolled;
}

-(BOOL) localTurn	{
	int i;
	for (i = 0; i < [players count]; i++)	{
		if ([[players objectAtIndex:i] active] == NO)
			return NO;
	}
	if ([players objectAtIndex:turnIndex] == thePlayer)
		return YES;
	return NO;
}





-(void) moveRobberToTile:(NSNumber*)n	{//rect:(NSRobber)rect	{
//	NSLog(@"MOVING ROBBER TO %@", n);
	NSArray* tiles = [theBoard tiles];
	BoardHexagon* hex = [tiles objectAtIndex:[n intValue]];
	
	[theBoard moveRobberToTile:hex];
	[self robberMoved];
	
	if ([players objectAtIndex:turnIndex] == thePlayer)	
		[server notify:_cmd args:[NSArray arrayWithObject:n]];
	
}


-(void) printPhase	{
	return;
	NSString* str = @"";
	switch (phase)	{
		case RollPhase:
			str = @"RollPhase";
			break;
		case SetupPhase:
			str = @"SetupPhase";
			break;
		case ReverseSetupPhase:
			str = @"ReverseSetupPhase";
			break;
		case PlayPhase:
			str = @"PlayPhase";
			break;
	}
	
	NSLog(@"PHASE = %@", str);
}



-(void) player:(Player*)p isChatting:(NSString*)str	{
	if (p == thePlayer)
		[server notify:@selector(playerAtIndex:isChatting:) args:[NSArray arrayWithObjects:[NSNumber numberWithInt:[players indexOfObject:p]], str, nil]];
	[interface player:p chat:str];
}

-(void) playerAtIndex:(NSNumber*)n isChatting:(NSString*)str		{
	[self player:[players objectAtIndex:[n intValue]] isChatting:str];
}	

/*
	[[GameController gameController] player:[[GameController gameController] localPlayer] isChatting:[chatInputField stringValue]];
}


-(void) player:(Player*)p chat:(NSString*)str	{
*/


-(NSArray*) robbablePlayerIndices	{
	BoardHexagon* robberTile = [theBoard tileWithRobber];
	NSArray* verts = [robberTile vertices];

	NSMutableArray* tmpArray = [NSMutableArray array];
	int i;
//	int index;
	NSNumber* n;
	Player* p;
	for (i = 0; i < [verts count]; i++)	{
		if ([[verts objectAtIndex:i] item])	{
			p = [[[verts objectAtIndex:i] item] owner];
			if (p != thePlayer)	{
				n = [NSNumber numberWithInt:[players indexOfObject:p]];
				if ([tmpArray indexOfObject:n] == NSNotFound)
					[tmpArray addObject:n];
			}
		}
	}
	
	return tmpArray;
}


-(int) rollPhaseRollForPlayer:(Player*)p	{
	return rollPhaseResultArray[[players indexOfObject:p]];
}	

-(void) reloadDevCardTable	{
	[interface reloadDevCardTable];
}


#pragma mark ACCESSORS

-(void) setPlayers:(NSArray*)arr	{
	players = [arr retain];
	/*
	if ([players count] == 2)
		placementIndices = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1],
			[NSNumber numberWithInt:1], [NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:0], nil];
	else	{
		int i;
		NSMutableArray* arr = [NSMutableArray array];
		for (i = 0; i < [players count]; i++)	{
			[arr addObject:[NSNumber numberWithInt:i]];
		}
		for (i = [players count] - 1; i >= 0; i--)	{
			[arr addObject:[NSNumber numberWithInt:i]];
		}
		placementIndices = [NSArray arrayWithArray:arr];
	}
	
	[placementIndices retain];
	*/
}

-(void) setLocalPlayer:(Player*)p	{
	thePlayer = [p retain];
}

-(int) phase	{
	return phase;
}
-(void) setPhase:(int)p	{
	phase = p;
}



-(void) setBoard:(Board*)b	{
	[theBoard release];
	theBoard = [b retain];
}

-(Board*) board	{
	return theBoard;
}	


-(Player*) localPlayer	{
	return thePlayer;
}

-(void) setServer:(GameClient*)srvr	{
	server = [srvr retain];
}

-(void) setInterface:(Control*)c	{
	interface = [c retain];
}

-(NSDictionary*) gamePrefs	{
	return gamePrefs;
}

-(void) setGamePrefs:(NSDictionary*)dict	{
	[gamePrefs release];
	gamePrefs = [NSDictionary dictionaryWithDictionary:dict];
	[gamePrefs retain];
}

-(void) setDevCardOrder:(NSMutableArray*)arr	{
	devCards = [[NSMutableArray alloc] init];
	int i;
	for (i = 0; i < [arr count]; i++)	{
		[devCards addObject:[DevelopmentCard cardWithType:[arr objectAtIndex:i]]];
	}
//	devCards = [arr retain];
}

-(int) turnIndex	{
	return turnIndex;
}

-(Player*) currentPlayer	{
	return [players objectAtIndex:turnIndex];
}


-(NSArray*) players	{
	return players;
}

-(void) setResourceManager:(ResourceManager*)rm	{
	resourceManager = [rm retain];
}


-(AnimatedCardView*) animatedCardView	{
	return [interface animatedCardView];
}


-(BoardView*) boardView	{
	return [interface boardView];
}


-(void) highlightLongestRoad	{
	[resourceManager animateLongRoad:longestRoad];
	/*
//	NSLog(@"highlighting longest road");
	[theBoard unhighlightAllRoads];
	int i;
	for (i = 0; i < [longestRoad count]; i++)	{
		[[[longestRoad objectAtIndex:i] item] setHighlight:YES]; 
	}
	*/
	[interface updateBoardBackground:NO];
}	


-(void) updateLargestArmy:(Player*)p	{
//-(void) animateIconForProperty:(NSString*)str fromPlayer:(Player*)fromPlayer toPlayer:(Player*)toPlayer	{

	if (p == largestArmy)
		return;
	
	NSDictionary* callback = [NSDictionary dictionaryWithObjectsAndKeys:
		self, @"TARGET",
		NSStringFromSelector(@selector(setLargestArmy:)), @"SELECTOR",
		p, @"PARAMETER", nil];
		
	if (largestArmy == nil)	{
		if ([p armySize] >= 3)		{
			[resourceManager animateIconForProperty:@"LargestArmy" fromPlayer:nil toPlayer:p withCallback:callback];
//			largestArmy = p;
		}
	}
	else if ([p armySize] > [largestArmy armySize])	{
		if (largestArmy != p)
			[resourceManager animateIconForProperty:@"LargestArmy" fromPlayer:largestArmy toPlayer:p withCallback:callback];
//		largestArmy = p;
	}
}


#pragma mark JUNK METHODS
-(void) oldendTurn	{
	PP;
	[self printPhase];
	//NSLog(@"turnIndex = %d", turnIndex);
//	if ([players
	if ([players objectAtIndex:turnIndex] == thePlayer)
		[server notify:_cmd args:nil];
	if (phase == ReverseSetupPhase)
		turnIndex--;
	else
		turnIndex++;
	
	//NSLog(@"here, turnIndex = %d", turnIndex);
//	NSLog(@"player count = %d", [players count]);

	if (turnIndex < 0)		{
		//NSLog(@"too small");
		turnIndex = [players count] - 1;
	}
	else if (turnIndex >= [players count])	{
		//NSLog(@"too big");
		turnIndex = 0;
	}

	
	
//	NSLog(@"after modification, turnIndex = %d", turnIndex);
	if (phase == RollPhase && turnIndex == 0)	{
		turnIndex = indexOfMax(rollPhaseResultArray);
		phase = SetupPhase;
		firstPlayer = turnIndex;
		[thePlayer spend:[NSArray array]];
	}
	else if (phase == SetupPhase)	{
		if (turnIndex == firstPlayer)	{
			turnIndex--;
			if (turnIndex < 0)
				turnIndex = [players count] - 1;
			
			phase = ReverseSetupPhase;
		}
	}
	else if (phase == ReverseSetupPhase)	{
		//NSLog(@"turnIndex = %d", turnIndex);
		int endIndex = firstPlayer - 1;
		if (endIndex < 0)
			endIndex = [players count] - 1;
		
		//NSLog(@"endIndex = %d", endIndex);
		if (turnIndex == endIndex)	{
			phase = PlayPhase;
			turnIndex = firstPlayer;
		}
	}

	rolled = NO;	
	[thePlayer spend:[NSArray array]];
	
	if ([players objectAtIndex:turnIndex] == thePlayer)	{
		NSBeep();
		[NSApp requestUserAttention:NSInformationalRequest];
	}
		
	playedCard = NO;
	playedKnight = NO;
	[thePlayer activateDevCards];
	[interface update];

}


-(int) cityCount	{
	return [[gamePrefs objectForKey:@"CITY_TOKENS"] intValue];
}
-(int) settlementCount	{
	return [[gamePrefs objectForKey:@"SETTLEMENT_TOKENS"] intValue];
}



-(int) availableSettlementsForLocalPlayer	{
	int count = [self settlementCount];
	NSArray* arr = [thePlayer settlements];
	int i;
	for (i = 0; i < [arr count]; i++)	{
		if ([[[arr objectAtIndex:i] item] class] == [SettlementToken class])	
			count--;
	}
	
	return count;
}
-(int) availableCitiesForLocalPlayer	{
	int count = [self cityCount];
	NSArray* arr = [thePlayer settlements];
	int i;
	for (i = 0; i < [arr count]; i++)	{
		if ([[[arr objectAtIndex:i] item] class] == [CityToken class])
			count--;
	}
	
	return count;
}


-(int) winningPointTotal	{
	
	return [[gamePrefs objectForKey:@"POINT_TOTAL"] intValue];

}

@end

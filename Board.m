//
//  Board.m
//  catan
//
//  Created by James Burke on 12/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Board.h"
#define PP NSLog(@"%s", __FUNCTION__)

@implementation Board


-(id) init	{
	self = [super init];
	if (self)	{
		[self createBoard];
//		[self generateBoardInfo];
	}
	return self;
}

+(Board*) newBoard	{
	Board* b = [[Board alloc] init];
	[b autorelease];
	return b;
}

-(NSArray*) tiles	{
	return myHexagons;
}
-(NSArray*) tileEdges	{
	return myEdges;
}
-(NSArray*) tileIntersections	{
	return myVertices;
}

-(void) moveRobberToTile:(BoardHexagon*)tile	{
	int i;
	for (i = 0; i < [myHexagons count]; i++)	{
		[[myHexagons objectAtIndex:i] setRobber:NO];
	}
	
	[tile setRobber:YES];
}


-(NSArray*) tradeRoutes	{
	return myTradeRoutes;
}


-(NSData*) boardInfo	{
	int i;
	NSMutableArray* tmp = [NSMutableArray array];
	BoardHexagon* hex;
	int diceValue;
	id resObj = nil;
	for (i = 0; i < [myHexagons count]; i++)	{
		hex = [myHexagons objectAtIndex:i];
		diceValue = [hex diceValue];
		resObj = [hex resource];
		if (resObj == nil)
			resObj = [NSNull null];
		[tmp addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:diceValue], @"DiceValue", resObj, @"Resource", nil]];
	}
	
	NSArray* tileArray = [NSArray arrayWithArray:tmp];
	
	tmp = [NSMutableArray array];
	for (i = 0; i < [myTradeRoutes count]; i++)	{
		resObj = [[myTradeRoutes objectAtIndex:i] resource];
		if (resObj == nil)
			resObj = [NSNull null];
		[tmp addObject:resObj];
	}
	NSArray* trArray = [NSArray arrayWithArray:tmp];
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:tileArray, @"TileInfo", trArray, @"TradeRouteInfo", nil];
//	NSLog(@"DICT = %@", dict);
	return [NSArchiver archivedDataWithRootObject:dict];
}

-(void) setBoardInfo:(NSData*)data	{
//	NSLog(@"setting board info");
	NSDictionary* infoDict = [NSUnarchiver unarchiveObjectWithData:data];
	NSArray* tileArray = [infoDict objectForKey:@"TileInfo"];
	NSArray* trArray = [infoDict objectForKey:@"TradeRouteInfo"];
	int i;
	BoardHexagon* hex;
	NSDictionary* dict;
	id resObj;
	int diceValue;
	char letter;
	for (i = 0; i < [tileArray count]; i++)	{
		hex = [myHexagons objectAtIndex:i];
		dict = [tileArray objectAtIndex:i];
		diceValue = [[dict objectForKey:@"DiceValue"] intValue];
		letter = [[dict objectForKey:@"LetterValue"] charValue];
	
//		if (diceValue != 0)	{
		[hex setDiceValue:diceValue];
		[hex setResource:[dict objectForKey:@"Resource"]];
		[hex setLetter:letter];
//		}
	}
	
//	NSLog(@"trArray = %@", trArray);
	for (i = 0; i < [trArray count]; i++)	{
		resObj = [trArray objectAtIndex:i];
		if (resObj != [NSNull null])
			[[myTradeRoutes objectAtIndex:i] setResource:[trArray objectAtIndex:i]];
	}
	
//	int i;
	int desertIndex;
	for (i = 0; i < [myHexagons count]; i++)	{
		[[myHexagons objectAtIndex:i] setRobber:NO];
		if ([[myHexagons objectAtIndex:i] resource] == nil)
			desertIndex = i;
	}
	[[myHexagons objectAtIndex:desertIndex] setRobber:YES];
}
//			tmp = (11 - i) + desertIndex + 1;
// ((len - 1) - i) + start + 1
// ((len - i) + start
// len + start + 1 - i

+(NSArray*) boardInfoFromArray:(int[])values length:(int)len startingAt:(int)startIndex clockwise:(BOOL)clockwiseFlag	{
//	PP;
	NSMutableArray* newArray = [NSMutableArray array];
	int i;
	int tmp;
//	NSMutableString* str = [NSMutableString string];
//	[str appendString:@"values = "];
//	for (i = 0; i < len; i++)	{
//		[str appendFormat:@"%d ", values[i]];
//	}
//	NSLog(@"%@", str);
	for (i = 0; i < len; i++)	{
		if (clockwiseFlag)
			tmp = i + startIndex;
		else	{
			tmp = len  + startIndex - i;
	///		if (len > 1)
	//			tmp = len + startIndex + 1 - i;
	//		else
	//			tmp = 0;
		}
			
		
//		NSLog(@"before adjustment, tmp = %d", tmp);
		if (tmp >= len)
			tmp -= len;
		if (tmp < 0)
			tmp += len;
		
//		NSLog(@"tmp = %d", tmp);
		[newArray addObject:[NSNumber numberWithInt:values[tmp]]];
	}
	
	
	return newArray;
}

+(NSData*) infoForNewBoardWithDesertInCenter:(BOOL)centerFlag	{
	int i;
//	PP;
	int diceValues[19] = {0, 5, 2,  6,  3,  8, 10,  9, 12, 11, 4, 8, 10, 9,  4, 5, 6, 3, 11};
	char diceValueLetters[19];
	char tmpChar = 'A';
	diceValueLetters[0] = '-';
	for (i = 1; i < 19; i++)	{
		diceValueLetters[i] = tmpChar;
		tmpChar++;
	}
	if (centerFlag)	{
		int hold;
		for (i = 0; i < 10; i++)	{
			hold = diceValues[i];
			diceValues[i] = diceValues[18 - i];
			diceValues[18 -i] = hold;
			hold = diceValueLetters[i];
			diceValueLetters[i] = diceValueLetters[18 - i];
			diceValueLetters[18 - i] = hold;
		}	
	}	

	BOOL clockwise = rand() % 2;
//	BOOL clockwise = NO;
//	clockwise = 0;
//	clockwise = 1;
//	NSLog(@"clockwise = %d", clockwise);
	int outsideIndices[12] = {0, 2, 5, 10, 15, 17, 18, 16, 13, 8, 3, 1};
	int middleIndices[6] = {4, 7, 12, 14, 11, 6};
	int insideIndices[1] = {9};

	int outsideLetters[12] = {'-', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'};
	int middleLetters[6] = {'L', 'M', 'N', 'O', 'P', 'Q'};
	int insideLetters[1] = {'R'};

	NSMutableArray* resourceArray = [NSMutableArray arrayWithObjects:
		@"Ore", @"Ore", @"Ore", 
		@"Brick", @"Brick", @"Brick",
		@"Wood", @"Wood", @"Wood", @"Wood", 
		@"Sheep", @"Sheep", @"Sheep", @"Sheep",
		@"Grain", @"Grain", @"Grain", @"Grain", nil];
	[resourceArray shuffle];

	int desertIndex;
	
	desertIndex = rand() % 12;
	if (centerFlag)	{
		while ((desertIndex % 2) == 1)
			desertIndex = rand() % 12;
	}
//	desertIndex = 7;
//	if (centerFlag == NO)	{
//	desertIndex = rand () % 12;
	if (centerFlag == NO)
		[resourceArray insertObject:[NSNull null] atIndex:outsideIndices[desertIndex]];
	else
		[resourceArray insertObject:[NSNull null] atIndex:9];
//	}
//	else	{
//		desertIndex = 0;
//		[resourceArray insertObject:[NSNull null] atIndex:insideIndices[desertIndex]];
//	}
	
	NSMutableArray* order = [NSMutableArray array];
	NSMutableArray* letters = [NSMutableArray array];
	
	NSArray* tmp;

	tmp = [self boardInfoFromArray:outsideIndices length:12 startingAt:desertIndex clockwise:clockwise];
	[order addObjectsFromArray:tmp];
	tmp = [self boardInfoFromArray:outsideLetters length:12 startingAt:desertIndex clockwise:clockwise];
	[letters addObjectsFromArray:tmp];
//	NSLog(@"desertIndex = %d", desertIndex);

	if (clockwise)
		desertIndex = (desertIndex / 2);
	else
		desertIndex = (desertIndex + 1) / 2;
//	NSLog(@"desertIndex = %d", desertIndex);
		
	if (centerFlag)	{
	//	desertIndex -= 1;
	//	if (desertIndex < 0)
	//		desertIndex = 5;
		
	}
	if (desertIndex >= 6)
		desertIndex -= 6;
	if (desertIndex < 0)
		desertIndex += 6;
//	NSLog(@"here, order = %@", order);
	tmp = [self boardInfoFromArray:middleIndices length:6 startingAt:desertIndex clockwise:clockwise];
	[order addObjectsFromArray:tmp];
	tmp = [self boardInfoFromArray:middleLetters length:6 startingAt:desertIndex clockwise:clockwise];
	[letters addObjectsFromArray:tmp];
//	NSLog(@"and now to here, order = %@", order);
	desertIndex = 0;
	tmp = [self boardInfoFromArray:insideIndices length:1 startingAt:desertIndex clockwise:clockwise];
	[order addObjectsFromArray:tmp];
	tmp = [self boardInfoFromArray:insideLetters length:1 startingAt:desertIndex clockwise:clockwise];
	[letters addObjectsFromArray:tmp];
//	NSLog(@"done, order = %@", order);
//	}
	int index;
	NSMutableArray* newDiceValues = [NSMutableArray array];
	NSMutableArray* newLetterValues = [NSMutableArray array];
	for (i = 0; i < [order count]; i++)	{
		index = [order indexOfObject:[NSNumber numberWithInt:i]];
		[newDiceValues addObject:[NSNumber numberWithInt:diceValues[index]]];
		[newLetterValues addObject:[NSNumber numberWithChar:diceValueLetters[index]]];
	}	

	
	NSMutableArray* trArray =[NSMutableArray arrayWithObjects:
		@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", 
		[NSNull null], [NSNull null], [NSNull null], [NSNull null], nil];
		
	[trArray shuffle];
	
	
	NSMutableArray* tmpArr = [NSMutableArray array];
//	int i;
	for (i = 0; i < 19; i++)	{
		[tmpArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			[newDiceValues objectAtIndex:i], @"DiceValue", 
			[newLetterValues objectAtIndex:i], @"LetterValue",
			[resourceArray objectAtIndex:i], @"Resource", nil]];
	}
	NSArray* tileArray = [NSArray arrayWithArray:tmpArr];
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:tileArray, @"TileInfo", trArray, @"TradeRouteInfo", nil];
//	NSLog(@"DICT = %@", dict);
//	NSLog(@"returning");
	return [NSArchiver archivedDataWithRootObject:dict];


}

+(NSData*) oldinfoForNewBoardWithDesertInCenter:(BOOL)flag	{
//	return nil;
	BOOL clockwise = rand() % 2;
//	NSLog(@"clockwise = %d", clockwise);
	int i;
	int diceValues[19] = {0, 5, 2,  6,  3,  8, 10,  9, 12, 11, 4, 8, 10, 9,  4, 5, 6, 3, 11};
	char diceValueLetters[19];
	char tmpChar = 'A';
	diceValueLetters[0] = '-';
	for (i = 1; i < 19; i++)	{
		diceValueLetters[i] = tmpChar;
		tmpChar++;
	}
	int outerIndices[12] = {0, 2, 5, 10, 15, 17, 18, 16, 13, 8, 3, 1};
	int middleIndices[6] = {4, 7, 12, 14, 11, 6};
	int insideIndices[1] = {9};

	char outerLetters[12] = {'-', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'};
	char middleLetters[6] = {'L', 'M', 'N', 'O', 'P', 'Q'};
	char insideLetters[1] = {'R'};
	
	NSMutableArray* resourceArray = [NSMutableArray arrayWithObjects:
		@"Ore", @"Ore", @"Ore", 
		@"Brick", @"Brick", @"Brick",
		@"Wood", @"Wood", @"Wood", @"Wood", 
		@"Sheep", @"Sheep", @"Sheep", @"Sheep",
		@"Grain", @"Grain", @"Grain", @"Grain", nil];
	[resourceArray shuffle];
	[resourceArray shuffle];
	int desertIndex = rand() % 12;
	[resourceArray insertObject:[NSNull null] atIndex:outerIndices[desertIndex]];


//	int diceValIndex = desertIndex;
	NSMutableArray* order = [NSMutableArray array];
	NSMutableArray* letters = [NSMutableArray array];
	int tmp;

	int letterIndex = 0;
//	NSLog(@"desertIndex = %d", desertIndex);
//	clockwise = 0;
	for (i = 0; i < 12; i++)	{
//	for (i = 11; i >= 0; i--)	{
		if (clockwise)	{
			tmp = i + desertIndex;
			if (tmp >= 12)
				tmp -= 12;
		}
		else	{
			tmp = (11 - i) + desertIndex + 1;
		}
		if (tmp < 0)
			tmp += 12;
		if (tmp >= 12)
			tmp -= 12;
//		NSLog(@"tmp = %d", tmp);
		[order addObject:[NSNumber numberWithInt:outerIndices[tmp]]];
		[letters addObject:[NSNumber numberWithChar:outerLetters[tmp]]];
//		letterIndex++;
	}
	if (clockwise)
		desertIndex = desertIndex / 2;
	else	{
		if (desertIndex == 11)
			desertIndex = 0;
		desertIndex = (desertIndex + 1) / 2;
	}
	
	for (i = 0; i < 6; i++)	{
		if (clockwise)
			tmp = i + desertIndex;
		else
			tmp = (5 - i) + desertIndex + 1;
		if (tmp >= 6)
			tmp -= 6;
		if (tmp < 0)
			tmp += 6;
		[order addObject:[NSNumber numberWithInt:middleIndices[tmp]]];
		[letters addObject:[NSNumber numberWithChar:middleLetters[tmp]]];
	}
	for (i = 0; i < 1; i++)	{
		[order addObject:[NSNumber numberWithInt:insideIndices[i]]];
		[letters addObject:[NSNumber numberWithChar:insideLetters[i]]];
	}
//	int i;
	NSMutableArray* newDiceValues = [NSMutableArray array];
	NSMutableArray* newLetterValues = [NSMutableArray array];
	for (i = 0; i < [order count]; i++)	{
		tmp = [order indexOfObject:[NSNumber numberWithInt:i]];
		[newDiceValues addObject:[NSNumber numberWithInt:diceValues[tmp]]];
		[newLetterValues addObject:[NSNumber numberWithChar:diceValueLetters[tmp]]];
	}	
/*	for (i = 0; i < 12; i++)	{
	//	tmp = i + desertIndex;
	//	if (tmp >= 12)
	//		tmp -= 12;
		tmp = [outers 
	//	[newDiceValues addObject:[NSNumber numberWithInt:diceValues[outerIndices[tmp]]]];
		
	}
	desertIndex = desertIndex / 2;
	for (i = 0; i < 6; i++)	{
		tmp = i + desertIndex;
		if (tmp >= 6)
			tmp -= 6;
		[newDiceValues addObject:[NSNumber numberWithInt:diceValues[middleIndices[tmp]]]];
	}
	[newDiceValues	addObject:[NSNumber numberWithInt:diceValues[insideIndices[0]]]];
*/	
	NSMutableArray* trArray =[NSMutableArray arrayWithObjects:
		@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", 
		[NSNull null], [NSNull null], [NSNull null], [NSNull null], nil];
		
	[trArray shuffle];
	
	
	NSMutableArray* tmpArr = [NSMutableArray array];
//	int i;
	for (i = 0; i < 19; i++)	{
		[tmpArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			[newDiceValues objectAtIndex:i], @"DiceValue", 
			[newLetterValues objectAtIndex:i], @"LetterValue",
			[resourceArray objectAtIndex:i], @"Resource", nil]];
	}
	NSArray* tileArray = [NSArray arrayWithArray:tmpArr];
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:tileArray, @"TileInfo", trArray, @"TradeRouteInfo", nil];
//	NSLog(@"DICT = %@", dict);
	return [NSArchiver archivedDataWithRootObject:dict];

}
-(void) generateBoardInfo	{
	int i;
	int diceValues[19] = {0, 5, 2,  6,  3,  8, 10,  9, 12, 11, 4, 8, 10, 9,  4, 5,   6, 3, 11};
	int hexIndices[19] = {0, 2, 5, 10, 15, 17, 18, 16, 13,  8, 3, 1,  4, 7, 12, 14, 11, 6, 9};
	NSMutableArray* resourceArray = [NSMutableArray arrayWithObjects:
		@"Grain", @"Grain", @"Grain", @"Grain", 
		@"Wood", @"Wood", @"Wood", @"Wood",
		@"Sheep", @"Sheep", @"Sheep", @"Sheep",
		@"Ore", @"Ore", @"Ore", 
		@"Brick", @"Brick", @"Brick",
		nil];
	[resourceArray shuffle];
	[resourceArray insertObject:[NSNull null] atIndex:0];
	for (i = 0; i < 19; i++)	{
		[[myHexagons objectAtIndex:hexIndices[i]] setDiceValue:diceValues[i]];
		[[myHexagons objectAtIndex:hexIndices[i]] setResource:[resourceArray objectAtIndex:i]];
	}
	
	NSMutableArray* trInfo = [NSMutableArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", [NSNull null], [NSNull null], [NSNull null], [NSNull null], nil];
	[trInfo shuffle];
	for (i = 0; i < [myTradeRoutes count]; i++)	{
		if ([trInfo objectAtIndex:i] != [NSNull null])
			[[myTradeRoutes objectAtIndex:i] setResource:[trInfo objectAtIndex:i]];
	}
}

-(BoardHexagon*) tileWithRobber	{
	int i;
	for (i = 0; i < [myHexagons count]; i++)	{
		if ([[myHexagons objectAtIndex:i] robber])
			return [myHexagons objectAtIndex:i];
	}
	
	PP;
	NSLog(@"SHOULDN'T HAVE GOTTEN TO HERE");
}


-(void) createBoard	{
//	PP;
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
	
	myVertices = [NSArray arrayWithArray:newVerts];
	[myVertices retain];
	for (i = 0; i < [myVertices count]; i++)
		[[myVertices objectAtIndex:i] setTag:i + 1];
		
	myEdges = [NSArray arrayWithArray:newEdges];
	[myEdges retain];
	
	[[newHexes objectAtIndex:0] setRobber:YES];
	myHexagons = [NSArray arrayWithArray:newHexes];
	[myHexagons retain];
	
	
/*	NSMutableArray* tmpRoutes = [NSMutableArray arrayWithObjects:[TradeRoute tradeRouteWithResource:nil], [TradeRoute tradeRouteWithResource:nil],
		[TradeRoute tradeRouteWithResource:nil], [TradeRoute tradeRouteWithResource:nil], 
		[TradeRoute tradeRouteWithResource:@"Wood"], [TradeRoute tradeRouteWithResource:@"Brick"], 
		[TradeRoute tradeRouteWithResource:@"Sheep"], [TradeRoute tradeRouteWithResource:@"Ore"],
		[TradeRoute tradeRouteWithResource:@"Grain"], nil];
	[tmpRoutes shuffle];*/
	
	NSMutableArray* tmpRoutes = [NSMutableArray array];
	for (i = 0; i < 9; i++)	{
		[tmpRoutes addObject:[[[TradeRoute alloc] init] autorelease]];
	}	
	myTradeRoutes = [NSArray arrayWithArray:tmpRoutes];
	[myTradeRoutes retain];
	//	(4, 5)    (11, 17), (29, 35), (46, 51)   (52, 53)            (48, 43), (30, 24) (12, 6)         (2, 3)

	int vertexTradeRouteIndices[18] = {4, 5, 11, 17, 29, 35, 46, 51, 52, 53, 48, 43, 30, 24, 12, 6, 2, 3};
	NSPoint tradeRouteOffsets[9] = {NSMakePoint(0, 0.75), NSMakePoint(0.75, 0.40), NSMakePoint(0.75, -0.40), NSMakePoint(0.75, -0.40),
		NSMakePoint(0, -0.75), NSMakePoint(-0.75, -0.40), NSMakePoint(-0.75, -0.40), NSMakePoint(-0.75, 0.40), NSMakePoint(0, 0.75)};
	Vertex* trV1;
	Vertex* trV2;
	for (i = 0; i < 9; i++)	{
		trV1 = [myVertices objectAtIndex:vertexTradeRouteIndices[2 * i]];
		trV2 = [myVertices objectAtIndex:vertexTradeRouteIndices[1 + 2 * i]];
		[trV1 setTradeRoute:[myTradeRoutes objectAtIndex:i]];
		[trV2 setTradeRoute:[myTradeRoutes objectAtIndex:i]];
		[[myTradeRoutes objectAtIndex:i] addVertex:trV1];
		[[myTradeRoutes objectAtIndex:i] addVertex:trV2];
		[[myTradeRoutes objectAtIndex:i] setOffset:tradeRouteOffsets[i]];
	}
	
	
	[myVertices retain];
	[myHexagons retain];
	[myEdges retain];
	[myTradeRoutes retain];
	
//	[self createWaterHexagons];
//	NSLog(@"created board, there's %d vertices", [myVertices count]);
//	NSLog(@"there are %d tradeRoutes, retainCount = %d", [myTradeRoutes count], [myTradeRoutes retainCount]);
//	NSLog(@"edge count = %d", [myEdges count]);
//	for (i = 0; i < [theVertices count]; i++)	{
//		NSLog(@"neighbor count = %d", [[[theVertices objectAtIndex:i] neighbors] count]);
//	}
}




-(NSArray*) hexagonsForRect:(NSRect)r	{
//	PP;
	NSMutableArray* hexagons = [NSMutableArray array];
	NSMutableArray* edges = [NSMutableArray array];
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

-(void) unhighlightAllRoads	{
	int i;
	for (i = 0; i < [myEdges count]; i++)	{
		 if ([[myEdges objectAtIndex:i] item])
			[[[myEdges objectAtIndex:i] item] setHighlight:NO];
	}
}




@end

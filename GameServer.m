//
//  GameServer.m
//  catan
//
//  Created by James Burke on 1/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GameServer.h"
#import "NSMutableArray-Shuffle.h"
#import "GameClient.h"
//#import "PortNumber.h"
#define PP NSLog(@"%s", __FUNCTION__)
static int NUMBER_OF_PLAYERS = 4;
@implementation GameServer

-(id) init	{
	self = [super init];
	if (self)	{
//		listenPort = [[NSSocketPort alloc] initWithTCPPort:34567];
//		if (listenPort)	{
//			NSLog(@"listening on 34567");
//		}
//		else	{
//			while (listenPort == nil)
//				listenPort = [[NSSocketPort alloc] initWithTCPPort:0];
//			NSLog(@"port 34567 is unavailable, using %d instead", [listenPort portNumber]);
//		}
//		[listenPort autorelease];

 //		listenConnection = [[NSConnection alloc] initWithReceivePort:listenPort sendPort:nil];
//		NSLog(@"registering port");
//		[[NSSocketPortNameServer sharedInstance] registerPort:listenPort name:@"CATAN_GAME_PORT"];
//		NSLog(@"registered, %d", flag);
//		clientConnections = [NSArray array];
//		[clientConnections retain];
		
//		names = [NSArray array];
//		[names retain];
		gameName = nil;
		gavePrefs = NO;
		gaveBoard = NO;
		activeIndices = [NSMutableArray array];
		[activeIndices retain];
		theServer = nil;
	}
	return self;
}

/*
-(void) updateActiveClients	{
	int i, j;
	NSNumber* flag = [NSNumber numberWithBool:YES];
	NSDistantObject <clientProtocol> * proxy;
	for (i = 0; i < [activeIndices count]; i++)	{
		proxy =  [[clientConnections objectAtIndex:[[activeIndices objectAtIndex:i] intValue]] rootProxy];
		[proxy setProtocolForProxy:@protocol(clientProtocol)];
		for (j = 0; j < [activeIndices count]; j++)	{
			[proxy setActive:flag forIndex:[activeIndices objectAtIndex:j]];
		}
	}
	
//	[prox setActive:flag forIndex:n];
}*/		

/*
-(void) dealloc	{
//	NSLog(@"deallocing server, port retainCount = %d, connection count = %d", [listenPort retainCount], [listenConnection retainCount]);
//	[listenConnection release];
//	NSLog(@"released listen connection");
//	NSLog(@"port retainCount = %d", [listenPort retainCount]);

//	[listenPort release];
	[super dealloc];
}*/

/*
-(id) retain	{
	NSLog(@"retaining server, count will be %d", [self retainCount] + 1);
	return [super retain];
}

-(void) release	{
	NSLog(@"releasing server, count will be %d", [self retainCount] - 1);
	[super release];
}*/

-(void) setNumberOfPlayers:(int)n	{
	NUMBER_OF_PLAYERS = n;
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



-(void) setGameName:(NSString*)name	{
	[gameName release];
	gameName = [name copy];
	[gameName retain];
	
//	int pn = [listenPort portNumber];
	int pn = [theServer listeningPort];
	netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_catanService._tcp."  name:[NSString stringWithFormat:@"%@'s game", gameName] port:pn];
	[netService publish];
}

-(void) listen	{
//+(BGServer*) runServerInSeparateThreadPortNumber:(int)pn maxClients:(int)mc owner:(id)obj;
	theServer = [BGServer runServerInSeparateThreadPortNumber:34567 maxClients:4 owner:self];
	[theServer handleStartupInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:[self boardInfo], [NSNumber numberWithBool:NO], nil], @"BOARD", [self gamePrefs], @"PREFS", nil]];
	[theServer retain];
}

-(NSDictionary*) infoForNewClientAtIndex:(int)index	{
	NSColor* color;
	if (index == 0)
		color = [NSColor blueColor];
	else if (index == 1)
		color = [NSColor redColor];
	else if (index == 2)
		color = [NSColor orangeColor];
	else if (index == 3)
		color = [NSColor purpleColor];
	else
		color = [NSColor blackColor];
		
	return [NSDictionary dictionaryWithObjectsAndKeys:color, @"COLOR", [NSNumber numberWithBool:NO], @"READY", nil];
}


/*
-(void) listen	{
	NSSocketPort* aPort = nil;
	aPort = [[NSSocketPort alloc] initWithTCPPort:34567];
	while (aPort == nil)
		aPort = [[NSSocketPort alloc] initWithTCPPort:0];
		
	listenHandle = [[NSFileHandle alloc] initWithFileDescriptor:[aPort socket]];
	[aPort release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptConnection:) name:NSFileHandleConnectionAcceptedNotification object:listenHandle];
	[listenHandle acceptConnectionInBackgroundAndNotify];
}*/

/*
-(void) distObjListen	{
//	NSLog(@"going to listen");
	[listenConnection setRootObject:self];
//	NSLog(@"set root");
	[listenConnection setDelegate:self];	
//	NSLog(@"listening");
}	*/

/*
-(void) kill	{
	int i;
	NSLog(@"Killing server");
//	for (i = 0; i < [clientConnections count]; i++)	{
///		[clientConnections release];
//	}
	NSLog(@"client connections killed");
	NSArray* objs = [listenConnection remoteObjects];
	for (i = 0; i < [objs count]; i++)	{
		[[objs objectAtIndex:i] release];
	}
	[listenConnection setRootObject:nil];
	NSLog(@"reset root object");
	[listenConnection setDelegate:nil];
	NSLog(@"reset delegate");
	[listenConnection invalidate];
	[listenConnection release];
	
	[listenPort invalidate];
	[listenPort release];
//	listenConnection = nil;
//	listenPort = nil;
//	NSLog(@"released connection");
//	listenConnection = nil;
	NSLog(@"killed");
}
*/
-(int) portNumber	{
//	return [listenPort portNumber];
	return [theServer listeningPort];
}

/*
- (BOOL)connection:(NSConnection *)parentConnection shouldMakeNewConnection:(NSConnection *)newConnection	{
	PP;
	NSLog(@"send port = %@:%d, receive port = %@:%d", [(NSSocketPort*)[newConnection sendPort] ipAddress], [(NSSocketPort*)[newConnection sendPort] portNumber], [(NSSocketPort*)[newConnection receivePort] ipAddress], [(NSSocketPort*)[newConnection receivePort] portNumber]);
//	[newConnection setProtocolForProxy:@protocol(clientProtocol)];
	NSMutableArray* arr = [NSMutableArray arrayWithArray:clientConnections];
	[arr addObject:newConnection];

	[clientConnections release];
	clientConnections = [NSArray arrayWithArray:arr];
	[clientConnections retain];
	
	NSString* nm = [[[newConnection rootProxy] name] copy];
	[[newConnection rootProxy] setProtocolForProxy:@protocol(clientProtocol)];
	if ([nm isEqualToString:@""])
		nm = [NSString stringWithFormat:@"Player %d", [clientConnections count]];
		
	NSMutableArray* tmpNames = [NSMutableArray arrayWithArray:names];
	[tmpNames addObject:nm];
	
	[names release];
	names = [NSArray arrayWithArray:tmpNames];
	[names retain];
	
	NSColor* color = nil;
	int count = [clientConnections count];
	if (count == 1)
		color = [NSColor blueColor];
	else if (count == 2)
		color = [NSColor redColor];
	else if (count == 3)
		color = [NSColor orangeColor];
	else if (count == 4)
		color = [NSColor purpleColor];
	
	
	[[[clientConnections objectAtIndex:count - 1] rootProxy] setColor:color];
	[[[clientConnections objectAtIndex:count -1] rootProxy] setIndex:count - 1];
//	if ([clientConnections count] >= NUMBER_OF_PLAYERS)
///		[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(beginGame:) userInfo:nil repeats:NO];
	return YES;
}
*/

-(void) beginGame:(NSTimer*)t	{
	NSLog(@"BEGIN GAME WAS CALLED");
}
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

/*

-(void) acceptConnection:(NSNotification*)note	{
	NSDictionary* dict = [note userInfo];
	if ([dict objectForKey:@"NSFileHandleError"])	{
		NSLog(@"ERROR, %s, %@", __FUNCTION__, [dict objectForKey:@"NSFileHandleError"]);
	}
	else	{
		NSFileHandle* cHandle = [dict objectForKey:@"NSFileHandleNotificationFileHandleItem"];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileHandleReadData:) name:NSFileHandleReadCompletionNotification object:cHandle];
		[clientHandles addObject:cHandle];
		[cHandle readInBackgroundAndNotify];
	}
	
	if ([cHandles count] < 4)
		[listenHandle acceptConnectionInBackgroundAndNotify];
}

-(void) fileHandleReadData:(NSNotification*)note	{
	NSDictionary* dict  = [note userInfo];
	if ([dict objectForKey:@"NSFileHandleError"])	{
		NSLog(@"ERROR, %s, %@", __FUNCTION__, [dict objectForKey:@"NSFileHandleError"]);
	}
	else	{
		NSData* data = [dict objectForKey:@"NSFileHandleNotificationDataItem"];
		if ([data length] == 0)	{
			[[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:[note object]];
			[clientHandles removeObject:[note object]];
		}
		else	{
			NSArray* array = [NSUnarchiver unarchiveObjectWithData:data];
			if ([[array objectAtIndex:0] isEqualToString:@"REQUEST"])
				[self sendDataForSelector:NSSelectorFromString([array objectAtIndex:1]) to:[note object]]
			else
				[self forwardMessageForSelector:NSSelectorFromString([array objectAtIndex:1]) args:[array objectAtindex:2] from:[note object]];
			
			[[note object] readInBackgroundAndNotify];
		}
	}
}
*/
/*
-(void) sendDataForSelector:(SEL)sel to:(NSFileHandle*)cHandle	{
	NSInvocation* inv = [[NSInvocation alloc] init];
	[inv setTarget:self];
	[inv setSelector:sel];
	
	[inv invoke];
	NSData* data;
	[inv getReturnValue:&data];
	
	[cHandle writeData:data];
}*/

/*
-(void) forwardMessageForSelector:(SEL)sel args:(NSArray*)array from:(NSFileHandle*)cHandle	{
	
}
*/

#pragma mark CLIENT REQEUESTS

-(NSData*) boardInfo	{
//	if (gaveBoard == NO)	{
//		gaveBoard = YES;
	return [Board infoForNewBoardWithDesertInCenter:NO];
//	}
//	return [[[clientConnections objectAtIndex:0] rootProxy] boardInfo];
}
/*
	tradeBox, @"CAN_TRADE", purchaseBox, @"CAN_PURCHASE", devCardUseageBox, @"CAN_PLAY_DEV_CARD",
		onePerTurnBox, @"ONE_PER_TURN", excludeVPBox, @"EXCLUDE_VP", knightBox, @"ONLY_KNIGHT", 
		knightBeforeRoll, @"KNIGHT_BEFORE_ROLL",  nil];
*/

-(NSData*) gamePrefs	{
	NSDictionary* dict;
//	if (gavePrefs == NO)	{
//		gavePrefs = YES;
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:YES], @"CAN_TRADE", 
			[NSNumber numberWithBool:YES], @"CAN_PURCHASE",
			[NSNumber numberWithBool:YES], @"CAN_PLAY_DEV_CARD", 
			[NSNumber numberWithBool:NO], @"KNIGHT_BEFORE_ROLL",
			[NSNumber numberWithBool:YES], @"ONE_PER_TURN", 
			[NSNumber numberWithBool:YES], @"EXCLUDE_VP", 
			[NSNumber numberWithBool:NO], @"ONLY_KNIGHT",
			[NSNumber numberWithInt:10], @"POINT_TOTAL",
			[NSNumber numberWithInt:5], @"SETTLEMENT_TOKENS",
			[NSNumber numberWithInt:4], @"CITY_TOKENS", 
			nil]; 
		return [NSArchiver archivedDataWithRootObject:dict];
	
//	}
	
//	return [[[clientConnections objectAtIndex:0] rootProxy] gamePrefs];
		
//	return arr;
}


/*
-(NSData*) newPlayerJoined	{
	NSLog(@"new player joined");
	NSDistantObject <clientProtocol> *c;
	
	NSMutableArray* array = [NSMutableArray array];
	int i;
	for (i = 0; i < [clientConnections count]; i++)	{
		 c = [[clientConnections objectAtIndex:i] rootProxy];
//		NSLog(@"got root proxy, %@", c);
		[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			[c name], @"Name",
			[c color], @"Color",
			[c ready], @"Ready", nil]];
	}
	
//	NSLog(@"returning");
	return [NSArchiver archivedDataWithRootObject:array];
}
*/

#pragma mark CLIENT NOTIFICATIONS

/*
-(void) infoChanged	{
//	NSDistantObject <clientProtocol> *prox;
	NSDistantObject* prox;
	NSMutableArray* newArr = [NSMutableArray array];
	int i;
	for (i = 0; i < [clientConnections count]; i++)	{
		prox = [[clientConnections objectAtIndex:i] rootProxy];
		[newArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			[prox name], @"Name", [prox color], @"Color", [prox ready], @"Ready", nil]];
	}
	
	NSData* data = [NSArchiver archivedDataWithRootObject:newArr];
	
	for (i = 0; i < [clientConnections count]; i++)	{
		prox = [[clientConnections objectAtIndex:i] rootProxy];
		[prox setInfo:data];
	}
}*/




//	[server notify:_cmd args:[NSArray arrayWithObject:[NSNumber numberWithInt:r]]];


-(void) clientIsActive:(NSNumber*)n	{
	NSLog(@"activating %@", n);
	[activeIndices addObject:[NSNumber numberWithInt:[n intValue]]];
	[self updateActiveClients];
}


/*
-(void) DOforwardMessage:(NSData*)msg sender:(int)index	{
	int i;
	for (i = 0; i < [clientConnections count]; i++)	{
		if (i != index)	{
			[[[clientConnections objectAtIndex:i] rootProxy] receiveMessage:msg sender:index];
		}
	}
}*/






@end

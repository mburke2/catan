//
//  GameClient.m
//  catan
//
//  Created by James Burke on 1/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//


#import "GameClient.h"
#import "GameServer.h"

#import <sys/socket.h>
#import <netinet/in.h>


#define PP NSLog(@"%s", __FUNCTION__)


static NSData* THE_SINGLE_REPLY_DATA = nil;
@implementation GameClient

-(id) init	{
	self = [super init];
	if (self)	{
		myIndex = -1;
//		connection = nil;
//		server = nil;
	//	myColor = [[NSColor cyanColor] retain];
	//	myColor = [[NSColor blueColor] retain];
		myColor = nil;
		setup = nil;
	}
	return self;
}

-(int) portNumber	{
//	return [[connection sendPort] portNumber];
}

/*
-(void) connectToAddress:(NSString*)hostAdd onPort:(int)pn		{
	struct sockaddr *address;
	int remoteSocket;
//	NSFileHandle *remoteFile;
	int connectResult = -1;

	NSSocketPort* port = [[NSSocketPort alloc] initRemoteWithTCPPort:pn host:hostAdd];

	address = [[port address] bytes];
	[port release];
	
	remoteSocket = socket(address->sa_family, SOCK_STREAM, 0); 
	if(remoteSocket > 0)	{
		serverHandle = [[NSFileHandle alloc] initWithFileDescriptor:remoteSocket closeOnDealloc:YES];
		if(serverHandle)	{ 
			connectResult = connect(remoteSocket, address, address->sa_len);
			if(connectResult == 0)	{
				connected = YES;
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileHandleReadData:) name:NSFileHandleReadCompletionNotification object:serverHandle];
				[serverHandle readInBackgroundAndNotify];
				// If you made it this far, you can use the file handle as
                // you like for reading or writing.
			}
			else	{
				NSLog(@"%s, An error occurred connecting to the socket.", __FUNCTION__);
			}
		}
		else	{
			NSLog(@"%s, Could not create NSFileHandle object.", __FUNCTION__);
		}
	}
	else	{
		NSLog(@"%s, Could not create socket.", __FUNCTION__);
	}
	
}*/


-(void) infoChanged:(NSArray*)keys	{
	NSLog(@"info changed");
}

-(void) connect:(NSString*) address	{
	NSLog(@"CONNECTING");
//	NSSocketPort* port;
	int colonLoc = [address rangeOfString:@":"].location;
	NSString* ipAddress = [address substringWithRange:NSMakeRange(0, colonLoc)];
	int pn = [[address substringWithRange:NSMakeRange(colonLoc + 1, [address length] - (colonLoc + 1))] intValue];
	theClient = [[BGClient alloc] init];
	[theClient setOwner:self];
	//-(BOOL) connectToIP:(NSString*)ipAddress portNumber:(int)pn;

	BOOL flag = [theClient connectToIP:ipAddress portNumber:pn];
	NSLog(@"%s, CONNECTED FLAG = %d", __FUNCTION__, flag);
//	[self connectToAddress:ipAddress onPort:pn];
//	port = [[NSSocketPort alloc] initRemoteWithTCPPort:pn host:ipAddress];
}	

/*
-(void) DOconnect:(NSString*)address	{
	NSSocketPort* port;
	int colonLoc = [address rangeOfString:@":"].location;
	NSString* ipAddress = [address substringWithRange:NSMakeRange(0, colonLoc)];
	int pn = [[address substringWithRange:NSMakeRange(colonLoc + 1, [address length] - (colonLoc + 1))] intValue];
//	NSLog(@"ipAddress = '%@', pn = '%d'", ipAddress, pn);
//	if ([ipAddress isEqualToString:@"127.0.0.1"])
//		ipAddress = nil;
	port = [[NSSocketPort alloc] initRemoteWithTCPPort:pn host:ipAddress];
	if (port)	{
		connection = [[NSConnection alloc] initWithReceivePort:nil sendPort:port];
		[connection setRootObject:self];
//		NSLog(@"getting server");
		server = [connection rootProxy];
//		NSLog(@"got it");
		[server setProtocolForProxy:@protocol(serverProtocol)];
//		NSLog(@"set protocol");
		[server retain];
//		NSLog(@"retained it");
		//NSLog(@"got server, it's %@", server);
	}
	else	{
		NSLog(@"client couldn't get port");
	}
}*/

/*
-(void) oldConnect:(NSString*)address	{
//	NSLog(@"connecting");
//	NSSocketPort* port = [[NSSocketPortNameServer sharedInstance] portForName:@"CATAN_GAME_PORT" host:nil];

	NSSocketPort* port;
	if (address == nil || [@"127.0.0.1" isEqualToString:address] || [@"local" isEqualToString:address] || [@"" isEqualToString:address])	{
		 //port = [[NSSocketPortNameServer sharedInstance] portForName:@"CATAN_GAME_PORT" host:nil];
	}
	else
		port = [[NSSocketPort alloc] initRemoteWithTCPPort:34567 host:address];
	if (port)	{
		connection = [[NSConnection alloc] initWithReceivePort:nil sendPort:port];
		[connection setRootObject:self];
		server = [connection rootProxy];
		[server setProtocolForProxy:@protocol(serverProtocol)];
		[server retain];
		//NSLog(@"got server, it's %@", server);
	}
	else
		NSLog(@"client couldn't get port");
}*/

/*
-(void) loadSetupWindowAsHost:(BOOL)hostFlag	{
	SEL sels[3] = {@selector(newPlayerJoined), @selector(boardInfo), @selector(gamePrefs)};
	NSMutableArray* dataPieces = [NSMutableArray array];
	int i;
	for (i = 0; i < 3; i++)	{
		[serverHandle writeData:[NSArray arrayWithArray:@"REQUEST", NSStringFromSelector(sels[i])]];
		while (THE_SINGLE_REPLY_DATA == nil)
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
	
		[dataPieces addObject:THE_SINGLE_REPLY_DATA];
		THE_SINGLE_REPLY_DATA = nil;
	}
	
	NSArray* arr = [NSUnarchiver unarchiveObjectWithData:[dataPieces objectAtIndex:0]];
	NSArray* prefs = [NSUnarchiver unarchiveObjectWithData:[dataPieces objectAtIndex:2]]; 
	setup = [[GameSetupController alloc] initWithServer:self name:name color:myColor board:boardInfo prefs:prefs asHost:hostFlag];
	int i;
	for (i = 0; i < [arr count]; i++)	{
		[setup addPlayer:[arr objectAtIndex:i]];
	}
	
//	NSLog(@"loading nib");
	[NSBundle loadNibNamed:@"GameSetup.nib" owner:setup];
}*/

-(void) connectionIsEstablished	{
	NSDictionary* info = [theClient infoDictionary];
	
//	NSLog(@"myIndex = %d", [theClient index]);
	myIndex = [theClient index];
	NSArray* keys = [self keysForPlayer:myIndex inInfoDict:info];
	int i;
	NSArray* pieces;
	NSString* piece;
	for (i = 0; i < [keys count]; i++)	{
		pieces = [[keys objectAtIndex:i] componentsSeparatedByString:@":"];
		piece = [pieces objectAtIndex:1];
		if ([piece isEqualToString:@"NAME"])
			[self setName:[info objectForKey:[keys objectAtIndex:i]]];
		else if ([piece isEqualToString:@"COLOR"])
			[self setColor:[info objectForKey:[keys objectAtIndex:i]]];
//		else if ([piece isEqualToString:@"READY"])
	}
	NSLog(@"loading window");
	[self loadSetupWindowAsHost:host];
}

-(NSArray*) keysForPlayer:(int)n inInfoDict:(NSDictionary*)dict	{
	NSString* targetString = [NSString stringWithFormat:@"%d", n];
	NSMutableArray* result = [NSMutableArray array];
	NSArray* keys = [dict allKeys];
	int i;
	NSArray* pieces;
	for (i = 0; i < [keys count]; i++)	{
		pieces = [[keys objectAtIndex:i] componentsSeparatedByString:@":"];
		if ([pieces count] > 0 && [[pieces objectAtIndex:0] isEqualToString:targetString])
			[result addObject:[keys objectAtIndex:i]];
	}
	return result;
}
-(NSArray*) playerArrayForInfo:(NSDictionary*)dict	{
	int i, j;
	NSArray* keys;
	NSMutableDictionary* newDict;
	NSArray* pieces;
	NSMutableArray* result = [NSMutableArray array];
	for (i = 0; i < 4; i++)	{
		keys = [self keysForPlayer:i inInfoDict:dict];
		if ([keys count] > 0)	{
			newDict = [NSMutableDictionary dictionary];
			for (j = 0; j < [keys count]; j++)	{
				pieces = [[keys objectAtIndex:j] componentsSeparatedByString:@":"];
				[newDict setObject:[dict objectForKey:[keys objectAtIndex:j]] forKey:[pieces objectAtIndex:1]];
			}
			[result addObject:newDict];
		}
	}
	return result;
}

-(void) setHost:(BOOL)flag	{
	host = flag;
}

-(void) loadSetupWindowAsHost:(BOOL)hostFlag	{
	NSDictionary* info = [theClient infoDictionary];
	NSData* boardInfo = [info objectForKey:@"BOARD"];
	NSData* prefs = [info objectForKey:@"PREFS"];
	NSDictionary* prefsDict = [NSUnarchiver unarchiveObjectWithData:prefs];
	NSArray* players = [self playerArrayForInfo:info];
	setup = [[GameSetupController alloc] initWithServer:theClient name:name color:myColor board:boardInfo prefs:prefsDict asHost:hostFlag];
	NSLog(@"created setup");
	int i;
	for (i = 0; i < [players count]; i++)	{
		[setup addPlayer:[players objectAtIndex:i]];
	}
	NSLog(@"loading nib");
	[NSBundle loadNibNamed:@"GameSetup.nib" owner:setup];
	NSLog(@"loaded");
}
/*
-(void) oldloadSetupWindowAsHost:(BOOL)hostFlag	{
	PP;
	NSData* data = [server newPlayerJoined];
//	NSLog(@"got data");
	NSArray* arr = [NSUnarchiver unarchiveObjectWithData:data];
//	NSLog(@"unarchived it");
	int i;
	NSData* boardInfo = [server boardInfo];
	NSData* prefsArray = [server gamePrefs];
	NSArray* prefs = [NSUnarchiver unarchiveObjectWithData:prefsArray];
	NSLog(@"name = '%@',length = %d", name, [name length]);
	setup = [[GameSetupController alloc] initWithServer:self name:name color:myColor board:boardInfo prefs:prefs asHost:hostFlag];
	for (i = 0; i < [arr count]; i++)	{
		[setup addPlayer:[arr objectAtIndex:i]];
	}
	
//	NSLog(@"loading nib");
	[NSBundle loadNibNamed:@"GameSetup.nib" owner:setup];
}*/


#pragma mark REQUESTS FROM SERVER FOR HOST ONLY

-(NSData*) boardInfo	{
	return [setup boardInfo];
}

-(NSData*) gamePrefs	{
	return [NSArchiver archivedDataWithRootObject:[setup gamePrefs]];
}



#pragma mark REQUESTS FROM SERVER

-(NSColor*) color	{
	if (setup)
		return [setup color];
	
	return myColor;
//	return [server initialColor];
}


#pragma mark DIRECTIVES FROM SERVER
-(void) setColor:(NSColor*)color	{
	[myColor release];
	myColor = [color copy];
	[myColor retain];
//	myColor = [color retain];
}

-(void) setIndex:(int)n	{
	myIndex = n;
}

/*
-(void) infoChanged	{
	[server infoChanged];
}
*/

-(void) setInfo:(NSData*)data	{
	NSArray* arr = [NSUnarchiver unarchiveObjectWithData:data];
	
	[setup setPlayers:arr];
}

/*
-(void) startGame	{
	[server beginGame:nil];
}
*/
//-(void) startGameWithBoardInfo:(NSData*)info players:(NSArray*)playerInfo localPlayer:(int)n devCards:(NSMutableArray*)devCards	{
-(void) startGameWithBoardInfo:(NSData*)info players:(NSArray*)playerInfo localPlayer:(int)n devCards:(NSArray*)devCards gamePrefs:(NSDictionary*)prefs	{
	[BoardHexagon setShouldRoateTiles:YES]; 

	myIndex = n;
	[[GameController gameController] setServer:self];
	NSLog(@"starting game");
	Control* c = [[Control alloc] init];
	Board* newBoard = [Board newBoard];
	[newBoard setBoardInfo:info];
	[[GameController gameController] setBoard:newBoard];
	
	int i;
	NSMutableArray* players = [NSMutableArray array];
	for (i = 0; i < [playerInfo count]; i++)	{
		[players addObject:[Player playerWithName:[[playerInfo objectAtIndex:i] objectForKey:@"Name"] color:[[playerInfo objectAtIndex:i] objectForKey:@"Color"]]];
	}
	
	[[GameController gameController] setPlayers:players];
	[[GameController gameController] setLocalPlayer:[players objectAtIndex:n]];
	[[GameController gameController] setDevCardOrder:devCards];
	[[GameController gameController] setGamePrefs:prefs];
	[NSBundle loadNibNamed:@"GameControl.nib" owner:c];
	[setup close];
	[setup release];
	setup = nil;
}


//called from the client side
/*
-(void) notify:(SEL)sel args:(NSArray*)args	{
	NSArray* dataArray = [NSArray arrayWithObjects:NSStringFromSelector(sel), args];
	NSData* data = [NSArchiver archivedDataWithRootObject:dataArray];
	[serverHandle writeData:data];
}*/

-(void) DOnotify:(SEL)sel args:(NSArray*)args	{
	if (args == nil)
		args = [NSArray array];
	NSDictionary* message = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:myIndex], @"Sender", NSStringFromSelector(sel), @"Selector", args, @"Args", nil];
	
	NSData* mData = [NSArchiver archivedDataWithRootObject:message];
	

//	[server forwardMessage:mData sender:myIndex];
}


-(void) setActive:(NSNumber*)flag forIndex:(NSNumber*)n	{
	[[GameController gameController] setActive:[flag boolValue] forIndex:[n intValue]];
}
-(void) activate	{
//	[server clientIsActive:[NSNumber numberWithInt:myIndex]];
}


-(void) receiveMessage:(NSData*)data sender:(int)sender	{
	NSDictionary* msg = [NSUnarchiver unarchiveObjectWithData:data];
	
	NSObject* obj;
	if (setup)
		obj = setup;
	else 
		obj = [GameController gameController];
	
	NSArray* args = [msg objectForKey:@"Args"];
	SEL selector = NSSelectorFromString([msg objectForKey:@"Selector"]);

	if ([args count] == 0)	
		[obj performSelector:selector];
	else if ([args count] == 1)
		[obj performSelector:selector withObject:[args objectAtIndex:0]];
	else if ([args count] == 2)
		[obj performSelector:selector withObject:[args objectAtIndex:0] withObject:[args objectAtIndex:1]];
	else
		NSLog(@"ERROR: %s, sender = %d, sel = %@, args(%d) = %@", __FUNCTION__, sender, NSStringFromSelector(selector), [args count], args);
//	[[GameController gameController] 
}

-(void) setName:(NSString*)str	{
	name = [str retain];
}

-(NSString*) name	{
//	if (setup)
//		return [setup name];
	NSLog(@"retrieving name");
	return name;
}


-(NSNumber*) index	{
	return [NSNumber numberWithInt:myIndex];
}

-(NSNumber*) ready	{
//	if (setup)
//		return [NSNumber numberWithBool:[setup ready]];
//	return NO;
//	return [NSNumber numberWithBool:NO];
}

@end

//
//  FHServer.m
//  catan
//
//  Created by James Burke on 6/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BGServer.h"
//#import <netinet/in.h>

/*
	
	general idea:
	the host creates a server, and gives it board information / prefs directly

	a client connects, requests a color

	the client then sends an update, of it's name, and assigned color
	the client finally requests the info of the other players, the board and prefs, and then
		loads it's associated gui
	
	board / pref changes made by the host result in an update to the server
	color changes made by anybody result in an update to the server

*/

@implementation BGServer

-(id) init	{
	self = [super init];
	if (self)	{
		listeningHandle = nil;
		clientConnections = [NSMutableArray array];
		[clientConnections retain];
//		clientInfo = [NSMutableArray array];
//		[clientInfo retain];
		
		maxClients = 100;
		portNumber = -1;
		lPortFD = -1;
		preferredListeningPort = 0;
//		listening = NO;
//		lPort = nil;
		
	}
	return self;
}

+(BGServer*) runServerInSeparateThreadPortNumber:(int)pn maxClients:(int)mc	owner:(id)obj {
	BGServer* server = [[BGServer alloc] init];
	[server autorelease];
	[server setPreferredListeningPort:pn];
	[server setMaxClientsAllowed:mc];
	[server setOwner:obj];
	
	[NSThread detachNewThreadSelector:@selector(runInNewThread) toTarget:server withObject:nil];
	
	NSDate* timeout = [NSDate date];
	while ([server listeningPort] == -1 && -[timeout timeIntervalSinceNow] < 5.0)	{
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	}
		
	if ([server listeningPort] == -1)	{
		NSLog(@"couldn't set up server");
		return nil;
	}
	
	return server;
}

-(void) runInNewThread	{
	if (listeningHandle)
		return;
	
//	listening = YES;
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[self listen];
	[[NSRunLoop currentRunLoop] run];
	
	NSLog(@"exiting server thread");
	
	
	[pool release];
}


-(void) dealloc	{
	[super dealloc];
}
	

-(int) listeningPort	{
	return portNumber;
}
-(void) setPreferredListeningPort:(int)pn	{
	preferredListeningPort = pn;
}
-(void) setMaxClientsAllowed:(int)n	{
	maxClients = n;
}


//setsockopt() to turn on SO_REUSEADDR

-(void) makeListeningSocket	{
	lPortFD = socket(AF_INET, SOCK_STREAM, 0);
	int on = 1;
	if (setsockopt(lPortFD, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)) < 0)	{
		perror("setsockopt(SO_REUSEADDR) failed");
	}

	struct sockaddr_in stSockAddr;
    bzero(&stSockAddr, sizeof(stSockAddr));
 
    stSockAddr.sin_family = AF_INET;
	stSockAddr.sin_port = htons(preferredListeningPort);
	stSockAddr.sin_addr.s_addr = htonl(INADDR_ANY);
 
    if(-1 == bind(lPortFD,(struct sockaddr*) &stSockAddr, sizeof(stSockAddr)))	{
		printf("error bind failed");
		lPortFD = -1;
    }
	else	{
		unsigned int len = sizeof(stSockAddr);
		getsockname(lPortFD, (struct sockaddr*) &stSockAddr, &len);
		unsigned char buffer[100];
		NSData* data = [NSData dataWithBytes:&stSockAddr length:len];
		[data getBytes:buffer];
		
		portNumber = 256 * buffer[2] + buffer[3];
		NSLog(@"listenig on %d", portNumber);
//		NSLog(@"ready to listen on %d", portNumber);
//		NSLog(@"lPortFD = %d", lPortFD);
		int listenError = listen(lPortFD, 5);
		if (listenError < 0)	{
			NSLog(@"cannot listen");
			lPortFD = -1;
		}
	}
}
-(void) listen	{
	[self makeListeningSocket];

	if (lPortFD < 0)	{
		NSLog(@"CANNOT LISTEN");
		return;
	}
	listeningHandle = [[NSFileHandle alloc] initWithFileDescriptor:lPortFD];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptConnection:) name:NSFileHandleConnectionAcceptedNotification object:listeningHandle];
	[listeningHandle acceptConnectionInBackgroundAndNotify];

}

-(void) kill	{

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[listeningHandle closeFile];
	[listeningHandle autorelease];
	listeningHandle = nil;
}

-(void) stopListening	{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[listeningHandle closeFile];
	[listeningHandle release];
	listeningHandle = nil;
}


-(void) acceptConnection:(NSNotification*)note	{
//	NSLog(@"%s, %@", __FUNCTION__, note);
//	NSLog(@"%s", __FUNCTION__);//, [NSThread currentThread]);
	NSDictionary* dict = [note userInfo];
	if ([dict objectForKey:@"NSFileHandleError"])	{
		perror("Error");
		NSLog(@"%s, ERROR: %@", __FUNCTION__, [dict objectForKey:@"NSFileHandleError"]);
		return;
	}
	
	NSFileHandle* cHandle = [dict objectForKey:@"NSFileHandleNotificationFileHandleItem"];
	NSLog(@"accepted connection from %@", [[self class] addressForSocket:[cHandle fileDescriptor]]);

//	NSLog(@"got handle, %@", cHandle);
	
//	NSLog(@"server is going to create an enpdoint on thread, %@", [NSThread currentThread]);
	ConnectionEndpoint* newEndpoint = [[ConnectionEndpoint alloc] initWithFileHandle:cHandle delegate:self];
	[newEndpoint autorelease];
	if (newEndpoint == nil)	{
		#warning keep any eye out for this
		NSLog(@"%s, got a nil endpoint, very strange", __FUNCTION__);
		[cHandle closeFile];
		[listeningHandle acceptConnectionInBackgroundAndNotify];
		return;
	}

	if ([clientConnections count] >= maxClients)	{
		NSLog(@"refusing connection, because there's too many clients");
		[newEndpoint sendNotice:[NSArray arrayWithObjects:NSStringFromSelector(@selector(serverIsFull)), [NSArray array], nil]];
		[newEndpoint close];
	}
	else		{
		NSDate* blahDate = [NSDate date];
		NSLog(@"SERVER IS WAITING");
		while (-[blahDate timeIntervalSinceNow] < 1.5)	{
		}
			//[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		NSLog(@"SERVER IS DONE WAITING");
		int index = [clientConnections count];
		[clientConnections addObject:newEndpoint];
	
		[newEndpoint sendNotice:[NSArray arrayWithObjects:NSStringFromSelector(@selector(receiveStartupInfo:)), [NSArray arrayWithObject:[self infoDictionary]], nil]];

		NSArray* nameRequestArray = [NSArray arrayWithObjects:NSStringFromSelector(@selector(name)), [NSArray array], nil];
		NSString* name = [newEndpoint sendRequest:nameRequestArray];
		if ([name isEqualToString:@""])
			name = [NSString stringWithFormat:@"Player %d", [clientConnections count]];
		else if (name == nil)	{
			NSLog(@"server couldn't get reply, ignoring connection attempt");
			[listeningHandle acceptConnectionInBackgroundAndNotify];
			return;
		}
		NSMutableDictionary* newPlayerInfoDict = [NSMutableDictionary dictionaryWithDictionary:[[self owner] infoForNewClientAtIndex:index]];
		[newPlayerInfoDict setObject:name forKey:@"NAME"];
//		NSMutableArray* updateKeys = [NSMutableArray array];
//		NSMutableArray* updateObjects = [NSMutableArray array];
		int i;
//		id anObj;
		NSMutableDictionary* updateDict = [NSMutableDictionary dictionary];
		NSArray* origKeys = [newPlayerInfoDict allKeys];
		for (i = 0; i < [origKeys count]; i++)	{
			[updateDict setValue:[newPlayerInfoDict objectForKey:[origKeys objectAtIndex:i]] forKey:[NSString stringWithFormat:@"%d:%@", index, [origKeys objectAtIndex:i]]];
//			anObj = [NSString stringWithFormat:@"%d:%@", index, [[dict allKeys] objectAtIndex:i]];
//			[updateKeys addObject:anObj];
//			anObj = [dict objectForKey:[[dict allKeys] objectAtIndex:i]];
//			[updateObjects addObject:anObj];
		}
//		NSDictionary* updateDict = [NSDictionary dictionaryWithObjectsAndKeys:updateKeys, [self updateMessageAttributesKey], [NSArray arrayWithArray:updateObjects], [self updateMessageValuesKey], nil];
		[self handleNetworkUpdate:updateDict sender:nil];
	
		[newEndpoint sendNotice:[NSArray arrayWithObjects:NSStringFromSelector(@selector(connectionIsEstablished)), [NSArray array], nil]];
	}
	
	[listeningHandle acceptConnectionInBackgroundAndNotify];
}

/*
-(NSData*) bigHugeMessage:(int)len	{
	unsigned char buffer[100];
	NSMutableData* data = [NSMutableData data];
	
	int l;
	while ([data length] < len)	{
		int i;
		for (i = 0; i < 100; i++)	{
			buffer[i] = rand() % 256;
		}
		
		l = len - [data length];
		if (l > 100)
			l = 100;
		[data appendBytes:buffer length:l];
	}
	return data;
}
*/
#pragma mark PROTOCOL METHODS

-(id) handleNetworkRequest:(NSArray*)requestArray sender:(ConnectionEndpoint*)conn	{

	NSInvocation* inv = [self invocationForMessage:requestArray];
	[inv performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
	id returnValue;
	[inv getReturnValue:&returnValue];
	return returnValue;
}

-(void) handleNetworkNotice:(NSArray*)message sender:(ConnectionEndpoint*)conn	{
//	\(@"%s, %@", __FUNCTION__, [NSThread currentThread]);
//	NSLog(@"server got a notice");
	int i;
	ConnectionEndpoint* c;
	for (i = 0; i < [clientConnections count]; i++)	{
		c = [clientConnections objectAtIndex:i];
		if (c != conn)	{
//			NSLog(@"server is sending hte message");
			[c sendNotice:message];
		}
	}
//	NSLog(@"server is done with notice");
}

-(void) handleNetworkUpdate:(NSDictionary*)message sender:(ConnectionEndpoint*)sender	{
//	NSInvocation* inv = [self invocationForMessage:message];
//	[inv invoke];
	
	[self updateInfo:message];
	int i;
	ConnectionEndpoint* c;
	for (i = 0; i < [clientConnections count]; i++)	{
		c = [clientConnections objectAtIndex:i];
		if (c != sender)	{
			[c sendUpdate:message];
		}
	}	
}


-(void) handleNetworkDisconnect:(ConnectionEndpoint*)cEp	{
	#warning need to do something here
	NSLog(@"a client died... removing it");
	[clientConnections removeObject:cEp];
}


-(BOOL) handlesUpdates	{
	return YES;
}
@end


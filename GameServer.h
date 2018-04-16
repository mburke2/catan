//
//  GameServer.h
//  catan
//
//  Created by James Burke on 1/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Board.h"
//#import "ClientServerProtocols.h"
//#import "NSSocketPort-Additions.h"
//#import "DevelopmentCard.h"
#import "BGServer.h"

//@class GameClient;

@interface GameServer : NSObject  {
//	NSSocketPort* listenPort;
//	NSConnection* listenConnection;

	BGServer* theServer;
//	NSArray* clientConnections;
//	NSArray* names;
	
	
	NSString* gameName;
	NSNetService* netService;
	
	BOOL gavePrefs;
	BOOL gaveBoard;
	
	
	
//	NSFileHandle* listenHandle;
//	NSMutableArray* clientHandles;
	NSMutableArray* activeIndices;
}

-(void) kill;
-(id) retain;
-(int) portNumber;
-(void) listen;
-(NSMutableArray*) makeDevCards;
@end

//
//  GameClient.h
//  catan
//
//  Created by James Burke on 1/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Control.h"
//#import "ClientServerProtocols.h"
#import "GameSetupController.h"
#import "BGClient.h"

//@class GameServer;
@interface GameClient : NSObject  {
//	NSConnection* connection;
//	GameServer* server;
	
	BGClient* theClient;

	NSString* name;
	
	int myIndex;
	NSColor* myColor;
	
	GameSetupController* setup;
	
	BOOL host;
	
//	NSFileHandle* serverHandle;
}


-(void) setHost:(BOOL)flag;

//-(int) index;
-(void) infoChanged;
-(void) setSetup:(GameSetupController*)setup;
-(void) setName:(NSString*)str;
-(void) connect:(NSString*)str;
-(void) startGameWithBoardInfo:(NSData*)info players:(NSArray*)players localPlayer:(int)n devCards:(NSMutableArray*)arr;
-(NSColor*) color;
-(void) loadSetupWindow;
-(int) portNumber;

-(void) activate;
-(void) notify:(SEL)sel args:(NSArray*)arr;


@end

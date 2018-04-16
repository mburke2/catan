//
//  FHServer.h
//  catan
//
//  Created by James Burke on 6/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConnectionEndpoint.h"
#import "AbstractConnection.h"
#import "NSSocketPort-Additions.h"
@interface BGServer : AbstractConnection   {

	NSFileHandle* listeningHandle;
	NSMutableArray* clientConnections;

	int preferredListeningPort;
	int portNumber;
	int maxClients;

	int lPortFD;
}


+(BGServer*) runServerInSeparateThreadPortNumber:(int)pn maxClients:(int)mc owner:(id)obj;
-(void) runInNewThread;
-(int) listeningPort;
-(void) setPreferredListeningPort:(int)pn;
-(void) setMaxClientsAllowed:(int)n;

-(void) listen;
-(void) stopListening;

//-(void) handleStartupInfo;





@end

//
//  Server.h
//  catan
//
//  Created by James Burke on 2/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GameServer.h"

@interface Server : NSObject {
	NSConnection* listenConnection;
	NSSocketPort* listenPort;
	GameServer* gameServer;

	
}

@end

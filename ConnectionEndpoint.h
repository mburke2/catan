//
//  ConnectionEndpoint.h
//  catan
//
//  Created by James Burke on 6/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ConnectionEndpoint;
@protocol connectionEndpointDelegateProtocol

-(id) handleNetworkRequest:(NSArray*)message sender:(ConnectionEndpoint*)c;
-(void) handleNetworkNotice:(NSArray*)message sender:(ConnectionEndpoint*)c;
-(void) handleNetworkUpdate:(id)message sender:(ConnectionEndpoint*)c;

-(void) handleNetworkDisconnect:(ConnectionEndpoint*)c;
//-(BOOL) handlesUpdates;
@end


@interface ConnectionEndpoint : NSObject {
	NSFileHandle* myHandle;
	id THE_NETWORK_REPLY;

	id <connectionEndpointDelegateProtocol> myDelegate;
	
	
	NSMutableData* incomingMessage;
	unsigned int incomingMessageTargetLength;
}

-(id) initWithFileHandle:(NSFileHandle*)handle delegate:(id)del;


-(void) sendNotice:(NSArray*)message;
-(id) sendRequest:(NSArray*)message;
-(void) sendUpdate:(NSDictionary*)message;

-(void) close;

@end



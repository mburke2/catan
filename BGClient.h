//
//  FHClient.h
//  catan
//
//  Created by James Burke on 6/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConnectionEndpoint.h"
#import "AbstractConnection.h"

@interface BGClient : AbstractConnection  {
	ConnectionEndpoint* connection;
	NSMutableArray* messageQueue;
	
	int myIndex;
	
	BOOL handlingMessage;
}



-(BOOL) connectToIP:(NSString*)ipAddress portNumber:(int)pn;

-(void) notify:(SEL)sel	args:(NSArray*)args;
-(void) updateAttribute:(id)attribute withValue:(id)val;
-(void) updateAttributes:(NSArray*)atts withValues:(NSArray*)vals;
-(id) request:(SEL)sel args:(NSArray*)args;
-(int) index;


-(int) portNumber;
@end

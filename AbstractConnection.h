//
//  AbstractConnection.h
//  catan
//
//  Created by James Burke on 6/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConnectionEndpoint.h"
#import <sys/socket.h>
#import <netinet/in.h>




@protocol connectionDelegateProtocol
-(void) infoChanged:(NSArray*)keys;
-(NSDictionary*) infoForNewClientAtIndex:(int)index;
@end


@interface AbstractConnection : NSObject <connectionEndpointDelegateProtocol> {


	NSObject <connectionDelegateProtocol>  *myOwner;
	NSMutableDictionary* infoDictionary;


}

-(void) setOwner:(id)obj;
-(id) owner;

-(NSInvocation*) invocationForMessage:(NSArray*)message;
//-(BOOL) handlesUpdates;

-(NSDictionary*) infoDictionary;
-(NSArray*) updateInfo:(NSDictionary*)message;
+(NSString*) addressForSocket:(int)fd;


-(NSString*) updateMessageAttributesKey;
-(NSString*) updateMessageValuesKey;
-(int) indexOfUpdateSender:(NSDictionary*)message;
-(void) handleStartupInfo:(NSDictionary*)dict;
@end

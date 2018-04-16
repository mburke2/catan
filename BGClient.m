//
//  FHClient.m
//  catan
//
//  Created by James Burke on 6/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BGClient.h"


@implementation BGClient

-(id) init	{
	self = [super init];
	if (self)	{
		connection = nil;
		messageQueue = [NSMutableArray array];
		[messageQueue retain];
		handlingMessage = NO;
		myIndex = -1;
	}
	return self;
}	



-(BOOL) connectToIP:(NSString*)ipAddress portNumber:(int)pn	{
//	struct sockaddr *address;
	struct sockaddr_in address;
	int remoteSocket;
//	NSFileHandle *remoteFile;
	int connectResult = -1;

//	NSSocketPort* port = [[NSSocketPort alloc] initRemoteWithTCPPort:pn host:ipAddress];
//	[port autorelease];
	NSFileHandle* remoteHandle = nil;
//	address = (struct sockaddr*)[[port address] bytes];
//	[port release];
	address.sin_family = AF_INET;
	address.sin_port = htons((short)pn);

    int32_t i32Res = inet_pton(AF_INET, [ipAddress UTF8String], (void *) &address.sin_addr);
	if (i32Res <= 0)
		NSLog(@"%s, couldn't create address", __FUNCTION__);
 /*
    if(0 > i32Res)
    {
      printf("error: first parameter is not a valid address family");
      exit(-1);
    }
    else if(0 == i32Res)
    {
      printf("char string (second parameter does not contain valid ipaddress");
      exit(-1);
    }
 */

//	remoteSocket = socket(address->sa_family, SOCK_STREAM, 0); 
	remoteSocket = socket(AF_INET, SOCK_STREAM, 0);
	if(remoteSocket > 0)	{
		remoteHandle = [[NSFileHandle alloc] initWithFileDescriptor:remoteSocket closeOnDealloc:YES];
		[remoteHandle autorelease];
		if(remoteHandle)	{ 
			connection = [[ConnectionEndpoint alloc] initWithFileHandle:remoteHandle delegate:self];
//			connectResult = connect(remoteSocket, address, address->sa_len);
			connectResult = connect(remoteSocket, (struct sockaddr*) &address, sizeof(address));
//			NSLog(@"connected, waiting 3 seconds");
///			NSDate* d = [NSDate date];
	//		while (-[d timeIntervalSinceNow] < 3.0)
	//			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
//			NSLog(@"done waiting");
			if(connectResult == 0)	{
				NSLog(@"*** CONNECT SUCCESS");
//				connection = [[ConnectionEndpoint alloc] initWithFileHandle:remoteHandle delegate:self];
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
	
	if (connectResult == 0)
		return YES;
	
	else	{
		NSLog(@"releasing connection");
		[connection release];
		return NO;
	}
}





-(id) handleNetworkRequest:(NSArray*)requestArray sender:(ConnectionEndpoint*)conn	{
	
	NSLog(@"handling request, %@", requestArray);
	NSInvocation* inv = [self invocationForMessage:requestArray];
	id returnValue;
	[inv invoke];
	[inv getReturnValue:&returnValue];
	
//	NSLog(@"got return value, %@", returnValue);
	return returnValue;
}

-(void) handleNetworkNotice:(NSArray*)noticeArray sender:(ConnectionEndpoint*)conn	{
//	NSLog(@"client got a notice, %@", noticeArray);
	NSInvocation* inv = [self invocationForMessage:noticeArray];
	[inv invoke];
}

-(void) handleNetworkDisconnect:(ConnectionEndpoint*)cEp	{
	NSLog(@"THE SERVER DROPPED");
}

-(void) handleNetworkUpdate:(NSDictionary*)message sender:(ConnectionEndpoint*)c		{
	NSLog(@"client getting update");
	
	if (myIndex == -1)	{
		myIndex = [self indexOfUpdateSender:message];
		NSLog(@"client set myIndex to %d", myIndex);
	}
	NSArray* keys = [self updateInfo:message];
	[myOwner infoChanged:keys];
}




-(void) notify:(SEL)sel	args:(NSArray*)args	{
	if (args == nil)
		args = [NSArray array];
	NSArray* message = [NSArray arrayWithObjects:NSStringFromSelector(sel) , args, nil];
	[connection sendNotice:message];
}



-(void) updateAttributes:(NSArray*)atts withValues:(NSArray*)vals	{
    NSLog(@"\n\n\n\nupdating %@, with %@\n\n\n\n\n", atts, vals);
	NSMutableArray* realKeys = [NSMutableArray array];
	NSString* newKey;
	int i;
	for (i = 0; i < [atts count]; i++)	{
		newKey = [atts objectAtIndex:i];
		#warning should check to see if key is 'special' via sublcass or delegate or some such
        
        if (([newKey isEqualToString:@"BOARD"] || [newKey isEqualToString:@"PREFS"]) == NO)
//        if ([newKey isEqualToString:@"BOARD"] == NO)
			newKey = [NSString stringWithFormat:@"%d:%@", myIndex, newKey];
		[realKeys addObject:newKey];
	}
	NSDictionary* message = [NSDictionary dictionaryWithObjects:vals forKeys:realKeys];
//	NSLog(@"sending update, %@", message);
	[self handleNetworkUpdate:message sender:connection];
	[connection sendUpdate:message];
}

-(void) updateAttribute:(id)attribute withValue:(id)val	{
	if (val == nil)
		val = [NSNull null];
	
	[self updateAttributes:[NSArray arrayWithObject:attribute] withValues:[NSArray arrayWithObject:val]];
//	NSDictionary* message = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObject:val] forKeys:[NSArray arrayWithObject:attribute]];
//	[connection sendUpdate:message];
}


-(id) request:(SEL)sel args:(NSArray*)args	{
	if (args == nil)
		args = [NSArray array];
	NSArray* message = [NSArray arrayWithObjects:NSStringFromSelector(sel), args , nil];
	return [connection sendRequest:message];
}


-(int) index	{
	return myIndex;
}




-(int) portNumber	{
	return 0;
}





@end

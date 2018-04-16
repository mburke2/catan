//
//  ConnectionEndpoint.m
//  catan
//
//  Created by James Burke on 6/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ConnectionEndpoint.h"
#include <unistd.h>


@interface ConnectionEndpoint (privateMethods)
-(void) sendMessage:(NSData*)messageData;

-(void) handleIncomingMessage:(NSArray*)messageArray;
-(void) handleIncomingData:(NSData*)data;

@end


@implementation ConnectionEndpoint (privateMethods)
-(void) handleIncomingData:(NSData*)data	{
	if (incomingMessageTargetLength == 0)	{
		unsigned char sizeBuffer[4];
		[data getBytes:&sizeBuffer length:4];
		incomingMessageTargetLength = sizeBuffer[3] + 256 * (sizeBuffer[2] + 256 * (sizeBuffer[1] + 256 * (sizeBuffer[0])));
		incomingMessage = [NSMutableData dataWithCapacity:incomingMessageTargetLength];
		[incomingMessage retain];
	}
	
	int currentLength = [data length];
	int remainingLength = incomingMessageTargetLength - [incomingMessage length];
	int usedBytes = remainingLength;
	if (usedBytes > currentLength)
		usedBytes = currentLength;
	
	[incomingMessage appendData:[data subdataWithRange:NSMakeRange(0, usedBytes)]];
	if (incomingMessageTargetLength == [incomingMessage length])	{
		NSArray* messageArray = [NSUnarchiver unarchiveObjectWithData:[incomingMessage subdataWithRange:NSMakeRange(4, incomingMessageTargetLength - 4)]];
		incomingMessageTargetLength = 0;
		[incomingMessage release];
		incomingMessage = nil;
		[self handleIncomingMessage:messageArray];
	}
	
	if (currentLength > usedBytes)	{
		[self handleIncomingData:[data subdataWithRange:NSMakeRange(usedBytes, currentLength - usedBytes)]];
	}
}

-(void) handleIncomingMessage:(NSArray*)messageArray	{
	NSLog(@"handling message, %@, delegate= %@", messageArray, myDelegate);
//	NSLog(@"handling message");
	NSString* type = [messageArray objectAtIndex:0];
//	NSLog(@"it was a %@", type);
	id message = [messageArray objectAtIndex:1];
//	NSLog(@"message was %@", message);

	if ([type isEqualToString:@"REQUEST"])	{
		id returnObject = [myDelegate handleNetworkRequest:message sender:self];
		NSLog(@"got return object, %@", returnObject);
		NSData* replyData = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObjects:@"REPLY", returnObject, nil]];
//		[sender writeData:];
		[self sendMessage:replyData];
	}
	else if ([type isEqualToString:@"REPLY"])	{
		THE_NETWORK_REPLY = message;
		[THE_NETWORK_REPLY retain];
	}
	else if ([type isEqualToString:@"NOTICE"])	{
		[myDelegate handleNetworkNotice:message sender:self];
	}
	else if ([type isEqualToString:@"UPDATE"])	{
			[myDelegate handleNetworkUpdate:message sender:self];
	}
	
//	[[note object] readInBackgroundAndNotify];
//	[[note object] readToEndOfFileInBackgroundAndNotify];
}


-(void) sendMessage:(NSData*)messageData	{
	unsigned int length = [messageData length];
//	NSLog(@"sending, length = %d", length);
	length += 4;
	unsigned char sizeBuffer[4];
	int i;
	for (i = 3; i >= 0; i--)	{
		sizeBuffer[i] = length % 256;
		length = length / 256;
	}
	
//	NSLog(@"sending a message, sizeBuffer = %d, %d, %d, %d", sizeBuffer[0], sizeBuffer[1], sizeBuffer[2], sizeBuffer[3]);
	NSData* sizeData = [NSData dataWithBytes:&sizeBuffer length:4];
	NSMutableData* theData = [NSMutableData dataWithCapacity:length];
	[theData appendData:sizeData];
	[theData appendData:messageData];
	
	[myHandle writeData:[NSData dataWithData:theData]];
}

@end
//static NSString* replyMode = @"MY BULLSHIT REPLY MODE";

@implementation ConnectionEndpoint


-(id) initWithFileHandle:(NSFileHandle*)aHandle delegate:(id)del	{
//	NSLog(@"creating an endpoint for delegate %@, on thread %@", del, [NSThread currentThread]);
	self = [super init];
	if (self)	{
		THE_NETWORK_REPLY = nil;
		myHandle = [aHandle retain];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataWasRead:) name:NSFileHandleReadCompletionNotification object:myHandle];
		[myHandle readInBackgroundAndNotify];
		myDelegate = del;
		incomingMessageTargetLength = 0;
		incomingMessage = nil;
	}
	
	return self;

}

-(void) dealloc	{
	NSLog(@"deallocing connection endpoint, handle count = %d", [myHandle retainCount]);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[myHandle closeFile];
//	close([myHandle fileDescriptor]);
//	[myHandle release];
	[super dealloc];
}

-(void) dataWasRead:(NSNotification*)note	{
//	NSLog(@"%s, %@\n(delegate = %@)", __FUNCTION__, note, myDelegate);
		perror("THIS IS THE ERROR:");

//	NSFileHandle* sender = [note object];
	NSDictionary* dict = [note userInfo];
	if ([dict objectForKey:@"NSFileHandleError]"])	{
		NSLog(@"%s, Error: %@", __FUNCTION__, [dict objectForKey:@"NSFileHandleError]"]);
		return;
	}
	
	NSData* data = [dict objectForKey:@"NSFileHandleNotificationDataItem"];
	if ([data length] == 0)	{
		[myDelegate handleNetworkDisconnect:self];
		return;
	}
	
	[self handleIncomingData:data];
	[myHandle readInBackgroundAndNotify];
}



-(void) sendUpdate:(NSDictionary*)message	{
	NSData* data = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObjects:@"UPDATE", message, nil]];
	[self sendMessage:data];
//	[myHandle writeData:data];
}

-(void) sendNotice:(NSArray*)message	{
	NSData* data = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObjects:@"NOTICE", message, nil]];	
	[self sendMessage:data];
//	[myHandle writeData:data];
	
}
-(id) sendRequest:(NSArray*)message	{
//	NSLog(@"sending request on thread, %@", [NSThread currentThread]);
	NSData* data = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObjects:@"REQUEST", message, nil]];
//	[myHandle writeData:data];

	[self sendMessage:data];
	
	const float TIMEOUT_INTERVAL = 15.0;
	NSDate* timeout = [NSDate date];
    /* !!!!! used to be -[timeout timeIntervalSinceNow] ... in 10.8, timeIntervalSinceNow apparently returns positive numbers same with the comparison for reply timeout*/
	while (THE_NETWORK_REPLY == nil && [timeout timeIntervalSinceNow] < TIMEOUT_INTERVAL)	{
		NSLog(@"waiting for reply");
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
	}
	if ( [timeout timeIntervalSinceNow] >= TIMEOUT_INTERVAL)	{
		NSLog(@"REPLY TIMEOUT");
//		THE_NETWORK_REPLY = [NSNull null];
	}
		
//	NSLog(@"got reply");
	id returnObj = THE_NETWORK_REPLY;

	[THE_NETWORK_REPLY autorelease];
	THE_NETWORK_REPLY = nil;
	
	return returnObj;
}


-(void) close	{
	[myHandle closeFile];
	[myHandle release];
	myHandle = nil;
}



@end

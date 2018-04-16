//
//  AbstractConnection.m
//  catan
//
//  Created by James Burke on 6/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AbstractConnection.h"

//static NSString* updateMessageAttributesKey = @"UPDATE_MESSAGE_ATTRIBUTE_KEY";
//static NSString* updateMessageValuesKey = @"UPDATE_MESSAGE_VALUES_KEY";


@implementation AbstractConnection

-(NSString*) updateMessageAttributesKey	{
	return @"UPDATE_MESSAGE_ATTRIBUTE_KEY";
}
-(NSString*) updateMessageValuesKey	{
	return @"UPDATE_MESSAGE_VALUES_KEY";
}
-(id) init	{
	self = [super init];
	if (self)	{
		myOwner = nil;
		infoDictionary = [NSMutableDictionary dictionary];
		[infoDictionary retain];
	}
	return self;
}

-(void) dealloc	{
	myOwner = nil;
	[infoDictionary release];
	
	[super dealloc];
}
-(void) setOwner:(id)obj	{
	myOwner = obj;
}

-(id) owner	{
	return myOwner;
}

-(void) handleStartupInfo:(NSDictionary*)dict	{
	[self updateInfo:dict];
	return;
/*
	NSArray* keys = [message objectForKey:[self updateMessageAttributesKey]];
	NSArray* objects = [message objectForKey:[self updateMessageValuesKey]];
*/
	NSArray* keys = [dict allKeys];
	NSMutableArray* objects = [NSMutableArray array];
	
	int i;
	for (i = 0; i < [keys count]; i++)	{
		[objects addObject:[dict objectForKey:[keys objectAtIndex:i]]];
	}
	
	[self updateInfo:[NSDictionary dictionaryWithObjectsAndKeys:keys, [self updateMessageAttributesKey], objects,  [self updateMessageValuesKey], nil]];
}

-(NSInvocation*) invocationForMessage:(NSArray*)message	{
	if ([message count] != 2)	{
		NSLog(@"%s, illegal message, %@", __FUNCTION__, message);
		return nil;	
	}
	SEL sel = NSSelectorFromString([message objectAtIndex:0]);
	NSArray* args = [message objectAtIndex:1];
	if (sel == @selector(receiveStartupInfo:))	{
		NSLog(@"RECEIVE STARTUP INFO SELECTOR IS RECOGNIZED");
		NSLog(@"args = %@, %@, %d", args, NSStringFromClass([args class]), [args count]);
		[self handleStartupInfo:[args objectAtIndex:0]];
		return nil;
	}

	NSMethodSignature* sig = [[myOwner class] instanceMethodSignatureForSelector:sel];
	NSInvocation* inv = [NSInvocation invocationWithMethodSignature:sig];
	NSLog(@"getting invocation for message, %@, owner = %@", message, myOwner);
	[inv setTarget:myOwner];
	[inv setSelector:sel];
	
	int i;
	id anArg;
	for (i = 0; i < [args count]; i++)	{
		anArg = [args objectAtIndex:i];
		[inv setArgument:&anArg atIndex:2 + i];
	}
	

	
//	NSLog(@"now, target = %@", [inv target]);
	return inv;
}


-(id) handleNetworkRequest:(NSArray*)message sender:(ConnectionEndpoint*)c	{
	NSLog(@"%s, THIS SHOULD'VE BEEN OVERRIDDEN", __FUNCTION__);
	return nil;
}
-(void) handleNetworkNotice:(NSArray*)message sender:(ConnectionEndpoint*)c	{
	NSLog(@"%s, THIS SHOULD'VE BEEN OVERRIDDEN", __FUNCTION__);
}
-(void) handleNetworkDisconnect:(ConnectionEndpoint*)c	{
	NSLog(@"%s, THIS SHOULD'VE BEEN OVERRIDDEN", __FUNCTION__);
}

-(void) handleNetworkUpdate:(id)message sender:(ConnectionEndpoint*)c	{
	NSLog(@"%s, THIS SHOULD'VE BEEN OVERRIDDEN", __FUNCTION__);
}

/*
-(BOOL) handlesUpdates	{
	return NO;
}	
*/

-(NSDictionary*) infoDictionary	{
//	NSLog(@"getting infoDictionary, %@", infoDictionary);
	return infoDictionary;
}

-(NSArray*) updateInfo:(NSDictionary*)message	{
//	NSArray* keys = [message objectForKey:[self updateMessageAttributesKey]];
//	NSArray* objects = [message objectForKey:[self updateMessageValuesKey]];
	
	NSArray* keys = [message allKeys];
	int i;
	for (i = 0; i < [keys count]; i++)	{
		//[infoDictionary setValue:[objects objectAtIndex:i] forKey:[keys objectAtIndex:i]];
		[infoDictionary setValue:[message objectForKey:[keys objectAtIndex:i]] forKey:[keys objectAtIndex:i]];
	}
	
	return keys;
}



+(NSString*) addressForSocket:(int)fd	{
	struct sockaddr address;
	unsigned int len = sizeof(address);
	
	getpeername(fd, &address, &len);
	NSData* data = [NSData dataWithBytes:&address length:len];
	unsigned char buffer[100];
	[data getBytes:buffer];
//	int i;
	
	NSString* str = [NSString stringWithFormat:@"%d.%d.%d.%d:%d", buffer[4], buffer[5], buffer[6], buffer[7], 256 * buffer[2] + buffer[3]];
	return str;
}

-(int) indexOfUpdateSender:(NSDictionary*)message	{
//	NSArray* keys = [message objectForKey:[self updateMessageAttributesKey]];
	NSArray* keys = [message allKeys];
	if ([keys count] == 0)	{
		NSLog(@"ERROR: %s, there are no keys", __FUNCTION__);
		return -1;
	}
	
	NSString* key = [keys objectAtIndex:0];
	NSArray* pieces = [key componentsSeparatedByString:@":"];
	if ([pieces count] == 0)	{
		NSLog(@"ERROR: %s, there are no pieces for key %@, keys = %@", __FUNCTION__, key, keys);
		return -1;
	}
	
	int index = [[pieces objectAtIndex:0] intValue];
	if (index == 0 && [[pieces objectAtIndex:0] isEqualToString:@"0"] == NO)	{
		NSLog(@"ERROR: %s first piece is %@, key = %@, keys = %@", __FUNCTION__, [pieces objectAtIndex:0], key, keys);
		return -1;
	}
		
	return index;	
	
}

@end

	
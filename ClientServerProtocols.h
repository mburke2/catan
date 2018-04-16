/*
 *  ClientServerProtocols.h
 *  catan
 *
 *  Created by James Burke on 1/18/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>


@protocol serverProtocol

//-(oneway void) notify:(NSString*)sel args:(NSArray*)args;

-(oneway void) forwardMessage:(NSData*)msg sender:(int)index;
-(oneway void) clientIsActive:(NSNumber*)n;
//-(oneway void) forwardSetupMessage:(NSData*)msg sender:(int)index;
-(NSData*) newPlayerJoined;
-(oneway void) infoChanged;
-(NSData*) boardInfo;
-(NSData*) gamePrefs;
//-(oneway void) forwardGamePrefs:(NSData*)data;
@end


@protocol clientProtocol


-(oneway void) setActive:(NSNumber*)flag forIndex:(NSNumber*)n;
-(NSData*) boardInfo;
-(NSData*) gamePrefs;
-(oneway void) updateGamePrefs:(NSData*)data;
-(oneway void) setInfo:(NSData*)data;
-(NSString*) name;
-(NSColor*) color;
-(NSNumber*) index;
-(NSNumber*) ready;
-(oneway void) setIndex:(int)n;
-(oneway void) setColor:(NSColor*)color;
-(oneway void) receiveMessage:(NSData*)data sender:(int)sender;
-(oneway void) startGameWithBoardInfo:(NSData*)data players:(NSArray*)array localPlayer:(int)index devCards:(NSArray*)devCards gamePrefs:(NSDictionary*)gamePrefs;
//		[[[clientConnections objectAtIndex:i] rootProxy] startGameWithBoardInfo:boardInfo players:players localPlayer:i devCards:devCards gamePrefs:gamePrefs];

//-(oneway void) receiveSetupMessage:(NSData*)data sender:(int)sender;

@end
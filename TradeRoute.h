//
//  TradeRoute.h
//  catan
//
//  Created by James Burke on 1/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TradeRoute : NSObject {
	NSString* resource;
	NSPoint location;
	
	NSPoint offset;
	NSArray* vertices;
	
	NSImage* myImage;
}

+(TradeRoute*) tradeRouteWithResource:(NSString*)r;
-(void) setLocation:(NSPoint)p;
-(void) buildImage;
-(NSPoint) location;
-(void) setResource:(NSString*)str;
-(NSString*) resource;
-(NSArray*) vertices;
-(NSPoint) offset;
-(NSImage*) image;


@end

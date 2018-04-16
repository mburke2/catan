//
//  BankView.h
//  catan
//
//  Created by James Burke on 1/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GameController.h"
#import "NSBezierPath-Additions.h"

@interface BankView : NSView {
	BOOL isActive;
	int tradeValue;
	BOOL monopolize;
	
	
	BOOL highlight;
	
	NSRect resourceRects[5];
	NSArray* resources;
	
	BOOL draggingInProgress;
	
//	NSRect brickRect;
//	NSRect woodRect;
//	NSRect sheepRect;
//	NSRect grainRect;
//	NSRet oreRect;
}

-(NSRect) rectForResource:(NSString*)res;

@end

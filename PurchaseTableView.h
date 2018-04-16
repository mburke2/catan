//
//  PurchaseTable.h
//  catan
//
//  Created by James Burke on 12/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PurchaseTableView : NSTableView {

	NSImage* roadImage;
	NSImage* settlementImage;
	NSImage* cityImage;
	NSImage* devCardImage;
}

-(NSImage*) roadImage;
-(NSImage*) settlementImage;
-(NSImage*) cityImage;
-(NSImage*) devCardImage;

-(NSImage*) itemImageForRow:(int)r;

@end

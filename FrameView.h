//
//  FrameView.h
//  catan
//
//  Created by James Burke on 1/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FrameView : NSView {
	int frameStyle;
	NSColor* frameColor;
	BOOL increasing;
	float alpha;
	NSTimer* timer;
}

-(void) setFrameStyle:(int)s;
-(void) setFrameColor:(NSColor*)c;

@end

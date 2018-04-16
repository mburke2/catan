//
//  SelectionView.h
//  catan better resource view
//
//  Created by James Burke on 2/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SelectionView : NSView {
	NSRect rectToDraw;
	BOOL shouldDraw;
}	

-(void) setShouldDraw:(BOOL)flag;
-(void) setRect:(NSRect)r;

-(NSBezierPath*) thinRect:(NSRect)r;
@end

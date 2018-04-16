//
//  SelectionView.m
//  catan better resource view
//
//  Created by James Burke on 2/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SelectionView.h"
#import "NSBezierPath-Additions.h"

@implementation SelectionView

-(id) initWithFrame:(NSRect)frame	{
	self = [super initWithFrame:frame];
	if (self)	{
		shouldDraw = NO;
		rectToDraw = NSMakeRect(0, 0, 0, 0);
		[self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	}
	return self;
}
-(void) setShouldDraw:(BOOL)flag	{
	shouldDraw = flag;
}	
-(void) setRect:(NSRect)r	{
	rectToDraw = r;
}


-(void) drawRect:(NSRect)r	{
	if (shouldDraw == NO)
		return;
	[[[NSColor lightGrayColor] colorWithAlphaComponent:0.5] set];
	[NSBezierPath fillRect:rectToDraw];
	[[NSColor whiteColor] set];
		//[NSBezierPath strokeRect:r];
//	[[self thinRect:rectToDraw] fill];
	[[NSBezierPath thinRect:rectToDraw] fill];
	
}


-(NSBezierPath*) thinRect:(NSRect)rect	{
	NSPoint p = rect.origin;
	NSSize sz = rect.size;
	NSBezierPath* path = [NSBezierPath bezierPath];
	[path appendBezierPathWithRect:NSMakeRect(p.x, p.y, sz.width, 1)];
	[path appendBezierPathWithRect:NSMakeRect(p.x + sz.width, p.y, 1, sz.height)];
	[path appendBezierPathWithRect:NSMakeRect(p.x, p.y + sz.height, sz.width, 1)];
	[path appendBezierPathWithRect:NSMakeRect(p.x, p.y, 1, sz.height)];
	
	return path;
}
@end

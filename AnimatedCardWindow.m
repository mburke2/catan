//
//  AnimatedCardWindow.m
//  catan
//
//  Created by James Burke on 2/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AnimatedCardWindow.h"
#import "AnimatedCardView.h"

@implementation AnimatedCardWindow

-(id) initWithWindow:(NSWindow*)window	{
	NSRect frame = [window frame];
	NSRect cRect = [NSWindow contentRectForFrameRect:frame styleMask:[window styleMask]];
	self = [super initWithContentRect:cRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	if (self)	{
//		primaryWindow = window;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameChanged:) name:NSWindowDidMoveNotification object:window];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameChanged:) name:NSWindowDidResizeNotification object:window];
//		[self setLevel:NSFloatingWindowLevel];
		[self setOpaque:NO];
		[self useOptimizedDrawing:YES];
		AnimatedCardView* acv = [[AnimatedCardView alloc] initWithFrame:frame];
		[self setBackgroundColor:[NSColor clearColor]];
		[self setContentView:acv];
		[window addChildWindow:self ordered:NSWindowAbove];
	}
//	NSLog(@"returning window");
	return self;
}

-(void) frameChanged:(NSNotification*)note	{
	NSWindow* win = [note object];
	NSRect cRect = [NSWindow contentRectForFrameRect:[win frame] styleMask:[win styleMask]];
	[self setFrame:cRect display:YES];
}
@end

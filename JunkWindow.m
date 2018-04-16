//
//  JunkWindow.m
//  catan
//
//  Created by James Burke on 2/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "JunkWindow.h"


@implementation JunkWindow

-(id) initWithImage:(NSImage*)image	{
	self = [super initWithContentRect:NSMakeRect(0, 0, 100, 100) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	if (self)	{
		[self setOpaque:NO];
		[self setBackgroundColor:[NSColor clearColor]];
		NSImageView* iv = [[[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)] autorelease];
//		[iv setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[iv setImageScaling:NSScaleToFit];
		[iv setImage:image];
		[self setHasShadow:YES];
		[self setContentView:iv];
	}
	return self;
}	
@end

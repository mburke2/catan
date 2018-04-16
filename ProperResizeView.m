//
//  ProperResizeView.m
//  catan
//
//  Created by James Burke on 3/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ProperResizeView.h"


@implementation ProperResizeView

-(id) initWithFrame:(NSRect)frame	{
	self = [super initWithFrame:frame];
	if (self)	{
		originalFrame = frame;
		subviews = [[NSMutableArray array] retain];
		originalSubviewFrames = [[NSMutableArray array] retain];
		[self setPostsFrameChangedNotifications:YES];
		[self setAutoresizesSubviews:NO];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameChanged:) name:NSViewFrameDidChangeNotification object:self];
		
	}
	return self;
}

-(void) frameChanged:(NSNotification*)note	{
	int i;
	NSRect svFrame;
	NSPoint center;
	NSSize sizeFactor = NSMakeSize([self frame].size.width / originalFrame.size.width, [self frame].size.height / originalFrame.size.height);
	NSPoint scaledCenter;
	NSSize newSize;
	for (i = 0; i < [subviews count]; i++)	{
		svFrame = [[originalSubviewFrames objectAtIndex:i] rectValue];
		center = NSMakePoint(svFrame.origin.x + (svFrame.size.width / 2), svFrame.origin.y + (svFrame.size.height / 2));
		center.x += (originalFrame.origin.x - [self frame].origin.x);
		center.y += ( originalFrame.origin.y - [self frame].origin.y);
//		scaledCenter = NSMakePoint(center.x / originalFrame.size.width, center.y / originalFrame.size.height);
//		center = NSMakePoint(scaledCenter.x * [self frame].size.width, scaledCenter.y * [self frame].size.height);
		newSize = NSMakeSize(sizeFactor.width * svFrame.size.width, sizeFactor.height * svFrame.size.height);
		svFrame = NSMakeRect(center.x - (newSize.width / 2), center.y - (newSize.height / 2), newSize.width, newSize.height);
		[[subviews objectAtIndex:i] setFrame:svFrame];
	}
}

-(void) dealloc	{
	[subviews release];
	[originalSubviewFrames release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

-(void) addSubview:(NSView*)sv	{
	[subviews addObject:sv];
	[originalSubviewFrames addObject:[NSValue valueWithRect:[sv frame]]];
	[super addSubview:sv];
}

/*
-(void) drawRect:(NSRect)rect	{
	[[NSColor blackColor] set];
	[NSBezierPath strokeRect:[self bounds]];
}*/
@end

//
//  FrameView.m
//  catan
//
//  Created by James Burke on 1/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FrameView.h"
#import "GameController.h"

@implementation FrameView
/*
-(id) init	{
	self = [super init];
	if (self)	{
		frameStyle = 0;
		frameColor = nil;
		[self setOpaque:NO];
	}
	return self;
}
*/
-(id) initWithFrame:(NSRect)r	{
	self = [super initWithFrame:r];
	if (self)	{
//		NSLog(@"%s", __FUNCTION__);
//		NSLog(@"frame = %@", NSStringFromRect(r));
		frameStyle = 0;
		frameColor = nil;
		increasing = NO;
		timer = nil;
		alpha = 0.6;
		[self registerForDraggedTypes:[NSArray arrayWithObject:@"CATAN_RESOURCE_TYPE"]];
//		[self setPostsFrameChangedNotification:YES];
//		[[NSNotificiationCenter defaultCenter] addObserver:self selector:@selector(frameChanged:) name:NSViewFrameDidChangeNotification object:self];
		
//		thinFrame = nil;
//		thickFrame = nil;
//		[self frameChanged:nil];
	}
	return self;
}

-(void) frameChanged:(NSNotification*)note	{
//	thinFrame = 
}	

-(void) drawRect:(NSRect)r	{
	return;
	if (frameStyle > 0 && frameColor != nil)	{
		[[frameColor colorWithAlphaComponent:alpha] set];
		NSBezierPath* framePath = [NSBezierPath bezierPathWithRect:[self bounds]];
		if (frameStyle == 2)
			[framePath setLineWidth:8];
		else
			[framePath setLineWidth:4];
			
		[framePath stroke];
	}
}
-(void) setFrameStyle:(int)s	{
	frameStyle = s;
//	[self setNeedsDisplay:YES];
	if (timer)	{
		[timer invalidate];
		timer = nil;
		alpha = 0.7;
//		[frameColor autorelease];
//		frameColor = [frameColor colorWithAlphaComponent:0.6];
//		[frameColor retain];
	}
	
//	else if (s == 2)	{
//		timer = [NSTimer scheduledTimerWithTimeInterval:0.08 target:self selector:@selector(changeAlpha:) userInfo:nil repeats:YES];
//	}
}

-(void) changeAlpha:(NSTimer*)timer	{
	if (increasing)
		alpha += .03;
	else
		alpha -= .03;
		
	if (alpha > 0.70)
		increasing = NO;
	if (alpha < 0.30)
		increasing = YES;
	
	[self setNeedsDisplay:YES];
}

-(void) setFrameColor:(NSColor*)c	{
	[frameColor release];
	frameColor = [c retain];
//	frameColor = [[c colorWithAlphaComponent:0.6] retain];
}

-(void) step	{
	frameStyle++;
	if (frameStyle >= 3)
		frameStyle = 0;
		
	[self setNeedsDisplay:YES];
}
/*
-(BOOL) isOpaque	{
	return NO;
}
*/
//CATAN_RESOURCE_TYPE
-(NSDragOperation)	draggingEntered:(id <NSDraggingInfo>)sender	{
//	NSLog(@"dragging entered frame view");
	if ([[GameController gameController] localPlayerMustDiscard])
		return NSDragOperationLink;
	
	return NSDragOperationNone;
}

-(BOOL) performDragOperation:(id <NSDraggingInfo>)sender	{
	[[GameController gameController] player:[[GameController gameController] localPlayer] discarded:[[sender draggingPasteboard] propertyListForType:@"CATAN_RESOURCE_TYPE"]];
	return YES;
}
@end

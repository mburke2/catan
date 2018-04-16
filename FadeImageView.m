//
//  FadeImageView.m
//  catan
//
//  Created by James Burke on 2/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FadeImageView.h"


@implementation FadeImageView

-(id) initWithFrame:(NSRect)rect	{
	self = [super initWithFrame:rect];
	if (self)	{
		myImage = nil;
		myAlpha = 0.0;
	}
	return self;
}
-(void) setImage:(NSImage*)image	{
	[myImage release];
	myImage = nil;
	if (image)
		myImage = [image retain];
}
-(void) setAlpha:(float)alpha	{
	myAlpha = alpha;
	[self setNeedsDisplay:YES];
}

-(void) drawRect:(NSRect)rect	{
	if (myImage)	{
		NSSize sz = [myImage size];
		[myImage drawInRect:[self bounds] fromRect:NSMakeRect(0, 0, sz.width, sz.height) operation:NSCompositeSourceOver fraction:myAlpha];
	}
}

@end

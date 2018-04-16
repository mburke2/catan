//
//  SimpleImageView.m
//  catan
//
//  Created by James Burke on 2/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SimpleImageView.h"


@implementation SimpleImageView


-(id) initWithFrame:(NSRect)frame	{
	self = [super initWithFrame:frame];
	if (self)	{
		myImage = nil;
		myAlphaValue = 1.0;
		drawFlag = YES;
	}	
	return self;
}

-(void) dealloc	{
//	NSLog(@"deallocing image view");
	[myImage release];
	[super dealloc];
}
/*
-(void) removeFromSuperview	{
	NSLog(@"removing from superview");
	[super removeFromSuperview];
}*/
-(void) setShouldDraw:(BOOL)flag	{
	drawFlag = flag;
	[self display];
}

-(void) setImage:(NSImage*)image	{
	[myImage release];
	myImage = [image retain];
	imageSize = [myImage size];
}

-(void) setAlphaValue:(float)f	{
	myAlphaValue = f;
	[self setNeedsDisplay:YES];
}	

-(void) drawRect:(NSRect)rect	{
	if (myImage == nil || drawFlag == NO)
		return;
		
	NSRect bounds = [self bounds];
	float w = rect.size.width / bounds.size.width;
	float h = rect.size.height / bounds.size.height;
	float x = rect.origin.x / bounds.size.width;
	float y = rect.origin.y / bounds.size.height;
	
	
	[myImage drawInRect:rect fromRect:NSMakeRect(x * imageSize.width, y * imageSize.height, w * imageSize.width, h * imageSize.height) operation:NSCompositeSourceOver fraction:myAlphaValue];
}	
@end

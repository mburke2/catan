//
//  GLAnimation.m
//  GLCard Flip
//
//  Created by James Burke on 3/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GLAnimation.h"
#define NSLog //


@implementation GLAnimation


-(id) init	{
	self = [super init];
	if (self)	{
		myDelegate = nil;
		duration = 1.25;
		startDate = nil;
	}
	return self;
}


-(void) setDuration:(float)f	{
	duration = f;
}
-(void) setView:(NSOpenGLView*)v	{
	glView = [v retain];
}
-(void) setDelegate:(id)delegate	{
	myDelegate = [delegate retain];
}
-(void) startAnimation	{
	NSLog(@"starting GLANimation");
	startDate = [NSDate date];
	[startDate retain];
//	[glView setHidden:NO];
	[glView setProgress:0];
	if (myDelegate && [myDelegate animationShouldStart:self])
	[NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(fire:) userInfo:nil repeats:YES];
}

/*
	x = 0.2 -> y = 0
	x = 0.8 -> y = 1
	
	m = (1 - 0) / (0.8 - 0.2)
	m = 1 / (0.6)
	m = 5 / 3
	
	
	y - 0 = (5/3) * (x - (1/5))
	
	y = (5/3)x - (1/3)
	
*/

-(void) fire:(NSTimer*)t	{
	float tInt = -[startDate timeIntervalSinceNow];
	float progress = tInt / duration;
	BOOL shouldStop = NO;
//	NSLog(@"progress = %f", progress);
	if (progress >= 1.0)	{	
		progress = 1.0;
		shouldStop = YES;
	}
	if (progress < 0.2)
		progress = 0;
	else if (progress > 0.8)
		progress = 1.0;
	else
		progress = (5/3.0) * progress - (1/3.0);
		
	[glView setProgress:progress];
	[glView drawRect:[glView bounds]];
	
	if (shouldStop)	{
		[t invalidate];
		[startDate release];
		startDate = nil;
		[myDelegate animationDidEnd:self];
//		[myDelegate glAnimationEnded:self];
	}
}

-(NSView*) view	{
	return glView;
}

@end

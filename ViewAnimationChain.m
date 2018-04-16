//
//  ViewAnimationChain.m
//  catan
//
//  Created by James Burke on 3/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ViewAnimationChain.h"
#define NSLog //

@implementation ViewAnimationChain


-(id) initWithChainArray:(NSArray*)arr	{
	self = [super init];
	if (self)	{
		int i;
		NSViewAnimation* ani;
		NSMutableArray* mArr = [NSMutableArray array];
		for (i = 0; i < [arr count]; i++)	{
			ani = [[[NSViewAnimation alloc] initWithViewAnimations:[arr objectAtIndex:i]] autorelease];
			[ani setDelegate:self];
			[mArr addObject:ani];
		}
		animations = [NSArray arrayWithArray:mArr];
		[animations retain];
	}
	return self;
}	
-(NSArray*) viewAnimations	{
	return [NSArray array];
}

-(void) animationDidEnd:(NSAnimation*)anAni	{
//	NSLog(@"ending piece");
	if ([anAni isKindOfClass:[NSViewAnimation class]])	{
		NSViewAnimation* ani = anAni;
		NSArray* vas = [ani viewAnimations];
		int i;
		for (i = 0; i < [vas count]; i++)	{
			if ([[[vas objectAtIndex:i] objectForKey:@"SHOULD_HIDE_VIEW"] boolValue] == YES)
				[[[vas objectAtIndex:i] objectForKey:NSViewAnimationTargetKey] setHidden:YES];
			else if ([[[vas objectAtIndex:i] objectForKey:@"SHOULD_REMOVE_VIEW"] boolValue] == YES)
				[[[vas objectAtIndex:i] objectForKey:NSViewAnimationTargetKey] removeFromSuperview];
		}
	}
	
	int index = [animations indexOfObject:anAni];
	index++;
	if (index >= [animations count])	{
		if ([myDelegate respondsToSelector:@selector(animationDidEnd:)])
			[myDelegate animationDidEnd:self];
//		[myDelegate animationDidEnd:self];
//		NSLog(@"releasing animations");
//		[animations autorelease];
//		NSLog(@"released");
	}
	else
		[[animations objectAtIndex:index] startAnimation];
}

-(void) setDuration:(float)f	{
	float pd = f / [animations count];
	[self setPieceDuration:pd];
}


-(BOOL) animationShouldStart:(NSAnimation*)anAni	{
//	NSLog(@"starting piece");
	if ([anAni isKindOfClass:[NSViewAnimation class]])	{
		NSViewAnimation* ani = anAni;
		NSArray* vas = [ani viewAnimations];
		int i;
		for (i = 0; i < [vas count]; i++)	{
			if ([[[vas objectAtIndex:i] objectForKey:@"SHOULD_UNHIDE_VIEW"] boolValue] == YES)
				[[[vas objectAtIndex:i] objectForKey:NSViewAnimationTargetKey] setHidden:NO];
		}
	}
	
	return YES;
}
-(void) startAnimation	{
	if ([myDelegate respondsToSelector:@selector(animationShouldStart:)])
		if ([myDelegate animationShouldStart:self] == NO)
			return;
			
	[[animations objectAtIndex:0] startAnimation];
}
-(void) setPieceDuration:(float)f	{
	pieceDuration = f;
	int i;
	for (i = 0; i < [animations count]; i++)	{
		[[animations objectAtIndex:i] setDuration:f];
	}
}

-(void) setDelegate:(id)del	{
	myDelegate = del;
}
@end

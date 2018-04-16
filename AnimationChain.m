//
//  AnimationChain.m
//  catan
//
//  Created by James Burke on 2/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AnimationChain.h"


@implementation AnimationChain

-(id) initWithAnimations:(NSArray*)arr	{
	self = [super init];
	if (self)	{
		myAnimations = [arr retain];
		int i;
		for (i = 1; i < [myAnimations count]; i++)	{
			[[myAnimations objectAtIndex:i] startWhenAnimation:[myAnimations objectAtIndex:i] reachesProgress:1.0];
		}
		myDelegate = nil;
	}
	return self;
}
-(void) startAnimation	{
	[[myAnimations objectAtIndex:[myAnimations count] - 1] setDelegate:self];
	[[myAnimations objectAtIndex:0] startAnimation];
}
-(void) setDelegate:(id)del	{
	myDelegate = nil;
}

-(void) animationDidEnd:(NSAnimation*)ani	{
	[myDelegate animationDidEnd:ani];
}	

@end

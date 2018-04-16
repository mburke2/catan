//
//  NSShadow-Additions.m
//  catan
//
//  Created by James Burke on 2/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSShadow-Additions.h"


@implementation NSShadow (Additions)

+(NSShadow*) standardShadow	{
	NSShadow* shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowOffset:NSMakeSize(10, -10)];
	[shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.6]];
	[shadow setShadowBlurRadius:0.0];
	
	return shadow;
}


+(NSShadow*) noShadow	{
	NSShadow* shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowOffset:NSMakeSize(0, 0)];
	[shadow setShadowColor:[NSColor clearColor]];
	[shadow setBlurRadius:0.0];
	
}

@end

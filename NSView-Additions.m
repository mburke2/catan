//
//  NSView-Additions.m
//  catan
//
//  Created by James Burke on 3/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSView-Additions.h"


@implementation NSView (Additions)
-(void) hide	{
	[self setHidden:YES];
}	
-(void) unhide	{
	[self setHidden:NO];
}
-(void) unhideNow	{
	[self setHidden:NO];
	[self display];
}

@end

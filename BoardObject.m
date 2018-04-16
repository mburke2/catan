//
//  BoardObject.m
//  catan
//
//  Created by James Burke on 12/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BoardObject.h"


@implementation BoardObject

-(id) init	{
	self = [super init];
	if (self)	{
		myToken = nil;
	}
	return self;
}
-(void) setTag:(int)t	{
	myTag = t;
}

-(int) tag	{
	return myTag;
}

-(BoardToken*) item	{
	return myToken;
}	

-(NSRect) imageRect	{
	NSLog(@"BOARD OBJECT IMAGE RECT< THIS SHOULD NOT GET CALLED");
	return NSMakeRect(0, 0, 0, 0);
}	

-(void) setItem:(BoardToken*)token	{
	myToken = [token retain];
}
@end

//
//  NSMutableArray-shuffle.m
//  catan
//
//  Created by James Burke on 1/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArray-Shuffle.h"
static BOOL seedSet = NO;

@implementation NSMutableArray (Shuffle)

-(void) shuffle	{
//	NSLog(@"shuffling");
	if (seedSet == NO)	{
		srand(time(0));
		seedSet = YES;
	}
	int i, j;
	for (j = 0; j < 10; j++)	{
		for (i = 0; i < [self count]; i++)	{
			[self exchangeObjectAtIndex:i withObjectAtIndex:rand() % [self count]];
		}
	}
}

@end

//
//  NSArray-Additions.m
//  catan
//
//  Created by James Burke on 3/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSArray-Additions.h"


@implementation NSArray (Additions)

-(int) countForObject:(id)obj	{
	int count = 0;
//	NSLog(@"getting count for %@ in %@", obj, self);
	NSMutableArray* mutable = [NSMutableArray arrayWithArray:self];
	
//	int index;
	while ([mutable indexOfObject:obj] != NSNotFound)	{
		count++;
		[mutable removeObjectAtIndex:[mutable indexOfObject:obj]];
	}
	
//	NSLog(@"returning %d", count);
	return count;
}

@end

//
//  RollFrequencyController.m
//  catan
//
//  Created by James Burke on 2/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RollFrequencyController.h"


@implementation RollFrequencyController

-(id) init	{
	self = [super init];
	if (self)	{
		int i;
		for (i = 0; i < 11; i++)	{
			theRolls[i] = 0;
		}
	}
	return self;
}

-(void) addRoll:(int)r	{
//	NSLog(@"adding %d", r);
	theRolls[r - 2]++;
	[graphView update];
//	NSLog(@"adding roll");
}

//-(void) getRolls:(int[11])tmpRolls	{

-(NSArray*) getRolls	{
	NSMutableArray* tmp = [NSMutableArray array];
//	NSLog(@"requesting rolls");
	int i;
	for (i = 0; i < 11; i++)	{
		[tmp addObject:[NSNumber numberWithInt:theRolls[i]]];
//		NSLog(@"val = %d, freq = %d", i + 2, theRolls[i]);
	}
	
	return tmp;
}


-(void)windowWillClose:(NSNotification *)aNotification	{
	[graphView removeFromSuperview];
//	[graphView release];
	graphView = nil;
}



-(void) awakeFromNib	{
//	NSLog(@"waking");
	[graphView update];
}
@end

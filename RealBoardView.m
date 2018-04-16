//
//  RealBoardView.m
//  catan
//
//  Created by James Burke on 1/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RealBoardView.h"


@implementation RealBoardView


-(void) drawRect:(NSRect)rect	{
//	NSLog(@"HOPEFULLY THIS ONLY HAPPENS ONCE, %s", __FUNCTION__);
	[self drawTiles];
}

-(void) setBoard:(Board*)b	{
	theBoard = [b retain];
	[self setNeedsDisplay:YES];
}
-(void) drawTiles	{
	int i;
	BoardHexagon* hex;
//	NSAttributedString* resString;
//	NSAttributedString* numString;
//	NSDictionary* atts;
//	NSPoint p;
	NSImage* image;
//	NSRect rect;
	NSArray* theHexagons = [theBoard tiles];
	int chipSize = 25;
	for (i = 0; i < [theHexagons count]; i++)	{
		hex = [theHexagons objectAtIndex:i];
		
//		if ([hex resource] == nil)
//			image = [NSImage imageNamed:@"Desert.png"];
//		else
//			image = [NSImage imageNamed:[NSString stringWithFormat:@"%@.png", [hex resource]]];
	//	image = [hex image];	
//		if (NSIntersectsRect([hex bounds], inRect))	{
			image = [hex image];
			[image drawInRect:[hex bounds] fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
		
			image = [DiceValueChips imageForValue:[hex diceValue] size:NSMakeSize(chipSize, chipSize)];
			[image drawInRect:NSMakeRect([hex center].x - (chipSize / 2), [hex center].y - (chipSize / 2), chipSize, chipSize) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
//		}
	/*
		atts = nil;
		if ([hex diceValue] == 6 || [hex diceValue] == 8)
			atts = [NSDictionary dictionaryWithObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
		resString = [[[NSAttributedString alloc] initWithString:[hex resource] attributes:atts] autorelease];
		numString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", [hex diceValue]] attributes:atts] autorelease];
		p = [hex center];
		[resString drawAtPoint:NSMakePoint(p.x - [resString size].width / 2, p.y)];
		[numString drawAtPoint:NSMakePoint(p.x - [numString size].width / 2, p.y - [numString size].height)];*/
	}
}

@end

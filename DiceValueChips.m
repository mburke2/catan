//
//  DiceValueChips.m
//  catan
//
//  Created by James Burke on 1/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DiceValueChips.h"


static NSSize staticSize;

@implementation DiceValueChips


int abs(int n)	{
	if (n >= 0)
		return n;
	return -1 * n;
}

NSBezierPath* pathForValue(int n)	{
	NSBezierPath* path = [NSBezierPath bezierPath];
	n = 6 - abs(7 - n);
	float distance = 4;
	int size = 2;
	float x1, x2;
	int i;
	if (n % 2 == 0)	{
		x1 = staticSize.width / 2 + (distance / 2);
		x2 = staticSize.width / 2 - (distance / 2);
		for (i = 0; i < (n / 2); i++)	{
			[path appendBezierPathWithOvalInRect:NSMakeRect(x1 - size / 2, staticSize.height / 2 - (distance + (size / 2)), size, size)];
			[path appendBezierPathWithOvalInRect:NSMakeRect(x2 - size / 2, staticSize.height / 2 - (distance + (size / 2)), size, size)];
			x1 += distance;
			x2 -= distance;
		}
	}	
	else	{
		[path appendBezierPathWithOvalInRect:NSMakeRect(staticSize.width / 2 - size / 2, staticSize.height / 2 - (distance + (size / 2)), size, size)];
		x1 = staticSize.width / 2 + distance;
		x2 = staticSize.width / 2 - distance;
		
		for (i = 0; i < (n - 1) / 2; i++)	{
			[path appendBezierPathWithOvalInRect:NSMakeRect(x1 - size / 2, staticSize.height / 2 - (distance + (size / 2)), size, size)];
			[path appendBezierPathWithOvalInRect:NSMakeRect(x2 - size / 2, staticSize.height / 2 - (distance + (size / 2)), size, size)];
			x1 += distance;
			x2 -= distance;	
		}
	}
	
	return path;
}
+(NSImage*) imageForValue:(int)n size:(NSSize)sizez letter:(char)letter	{
	staticSize = sizez;
//    staticSize = NSMakeSize(100, 100);
	if (n == 0)
		return nil;
	NSImage* image = [[[NSImage alloc] initWithSize:staticSize] autorelease];
	[image lockFocus];
	[[NSColor whiteColor] set];
	[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(1, 1, staticSize.width - 2, staticSize.height - 2)] fill];
	[[NSColor blackColor] set];
	[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(1, 1, staticSize.width -2, staticSize.height - 2)] stroke];
	
	NSColor* color;
	if (n == 6 || n == 8)
		color = [NSColor redColor];
	else
		color = [NSColor blackColor];
	
	NSDictionary* colorAtt = [NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName,
		[NSFont fontWithName:@"Helvetica" size:9], NSFontAttributeName, nil];

//	NSAttributedString* attStr = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d:%c", n, letter] attributes:colorAtt] autorelease];
	NSAttributedString* attStr = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", n] attributes:colorAtt] autorelease];

	[attStr drawAtPoint:NSMakePoint(staticSize.width / 2 - ([attStr size].width / 2), staticSize.height / 2 - ([attStr size].height / 4))];
	[pathForValue(n) fill];
	[image unlockFocus];

    NSImage* result = [[[NSImage alloc] initWithSize:sizez] autorelease];
    [result lockFocus];
    [image drawInRect:NSMakeRect(0, 0, sizez.width, sizez.height) fromRect:NSMakeRect(0, 0, staticSize.width, staticSize.height) operation:NSCompositeSourceOver fraction:1.0];
    
    [result unlockFocus];
    
    [[image TIFFRepresentation] writeToFile:[NSString stringWithFormat:@"/users/mikeburke/desktop/catanChits/%d.TIFF", n] atomically:YES];
    return result;
                       
    
    
	return image;
}



@end

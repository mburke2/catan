//
//  NSImage-Additions.m
//  catan
//
//  Created by James Burke on 2/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSImage-Additions.h"


@implementation NSImage (Additions)

-(NSImage*) imageByFlippingHorizontally	{
	NSImage* newImage = [[self imageByFlippingVertically] imageByRotatingDegrees:180];
	return newImage;
}

-(NSImage*) imageByFlippingVertically	{
	NSSize mySize = [self size];
	NSRect rect = NSMakeRect(0, 0, mySize.width, mySize.height);
	
	NSImage* canvas = [[[NSImage alloc] initWithSize:mySize] autorelease];
	[canvas setFlipped:YES];
	[canvas lockFocus];
	[self drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	[canvas unlockFocus];
	
	NSImage* newImage = [[[NSImage alloc] initWithSize:mySize] autorelease];
	[newImage lockFocus];
	[canvas drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	[newImage unlockFocus];
	
	
	return newImage;
}

-(NSImage*) imageByRotatingDegrees:(int)degrees	{
//	NSLog(@"rotating %d", degrees);
	NSSize mySize = [self size];
	NSImage* canvas = [[[NSImage alloc] initWithSize:NSMakeSize(2 * mySize.width, 2 * mySize.height)] autorelease];

	[canvas lockFocus];
	NSAffineTransform* transform = [NSAffineTransform transform];
	[transform translateXBy:mySize.width / 2 yBy:mySize.height / 2];
	[transform rotateByDegrees:degrees];
//	[transform rotateByDegrees:(60 * (rand() % 6))];
//	[transform rotateByDegrees:180];
	[transform translateXBy:-mySize.width / 2 yBy:-mySize.height / 2];
    [transform scaleBy:1.0];
	[transform set];
	[self drawInRect:NSMakeRect(0, 0, mySize.width, mySize.height) fromRect:NSMakeRect(0, 0, mySize.width, mySize.height) operation:NSCompositeSourceOver fraction:1.0];
	[canvas unlockFocus];
	
//	[myImage release];
//	myImage = [[NSImage alloc] initWithSize:baseSize];

	NSImage* newImage = [[[NSImage alloc] initWithSize:mySize] autorelease];
	[newImage lockFocus];
	[canvas drawInRect:NSMakeRect(0, 0, mySize.width, mySize.height) fromRect:NSMakeRect(0, 0, mySize.width, mySize.height) operation:NSCompositeSourceOver fraction:1.0];
	[newImage unlockFocus];
	
	return newImage;

}

-(NSImage*) shadowedImage	{
	return [NSImage shadowedImageWithImage:self];
}

+(NSImage*) shadowedImageWithImage:(NSImage*)image	{
	NSShadow* shadow = [NSShadow standardShadow];
	NSSize offset = [shadow shadowOffset];
	NSSize sz = NSMakeSize([image size].width + abs(offset.width), [image size].height + abs(offset.height));
	NSPoint p = NSMakePoint(0, 0);
	if (offset.width < 0)
		p.x = -offset.width;
	if (offset.height < 0)
		p.y = -offset.height;
		
//	NSRect imageRect = NSMakeRect(
	NSImage* newImage = [[[NSImage alloc] initWithSize:sz] autorelease];
	[newImage lockFocus];
	[shadow set];
	[image drawInRect:NSMakeRect(p.x, p.y, [image size].width, [image size].height) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
	[newImage unlockFocus];
	
	
	return newImage;
}


@end

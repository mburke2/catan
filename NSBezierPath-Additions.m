//
//  NSBezierPath-Additions.m
//  catan
//
//  Created by James Burke on 2/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSBezierPath-Additions.h"


NSPoint convertPointForFlippingHorizontally(NSPoint p, float xMin, float xMax)	{
	return NSMakePoint(xMin + (xMax - p.x), p.y);
}

@implementation NSBezierPath (Additions)


+(NSBezierPath*) bezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)rad	{

	NSPoint points[8];
	points[0] = NSMakePoint(rect.origin.x, rect.origin.y + rad);
	points[1] = NSMakePoint(rect.origin.x, rect.origin.y + rect.size.height - rad);
	points[2] = NSMakePoint(rect.origin.x + rad, rect.origin.y + rect.size.height);
	points[3] = NSMakePoint(rect.origin.x + rect.size.width - rad, rect.origin.y + rect.size.height);
	points[4] = NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - rad);
	points[5] = NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + rad);
	points[6] = NSMakePoint(rect.origin.x + rect.size.width - rad, rect.origin.y);
	points[7] = NSMakePoint(rect.origin.x + rad, rect.origin.y);
	
	NSPoint corners[4];
	corners[0] = NSMakePoint(rect.origin.x, rect.origin.y + rect.size.height);
	corners[1] = NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
	corners[2] = NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y);
	corners[3] = NSMakePoint(rect.origin.x, rect.origin.y);
	
	NSBezierPath* path = [NSBezierPath bezierPath];
	
	[path moveToPoint:points[0]];

	[path lineToPoint:points[1]];
	[path curveToPoint:points[2] controlPoint1:corners[0] controlPoint2:points[2]];

	[path lineToPoint:points[3]];
	[path curveToPoint:points[4] controlPoint1:corners[1] controlPoint2:points[4]];
	
	[path lineToPoint:points[5]];
	[path curveToPoint:points[6] controlPoint1:corners[2] controlPoint2:points[6]];
	
	[path lineToPoint:points[7]];
	[path curveToPoint:points[0] controlPoint1:corners[3] controlPoint2:points[0]];
	
	
	return path;
		
}

+(NSBezierPath*) thinRect:(NSRect)rect	{
	NSPoint p = rect.origin;
	NSSize sz = rect.size;
	NSBezierPath* path = [NSBezierPath bezierPath];
	[path appendBezierPathWithRect:NSMakeRect(p.x, p.y, sz.width, 1)];
	[path appendBezierPathWithRect:NSMakeRect(p.x + sz.width, p.y, 1, sz.height)];
	[path appendBezierPathWithRect:NSMakeRect(p.x, p.y + sz.height, sz.width, 1)];
	[path appendBezierPathWithRect:NSMakeRect(p.x, p.y, 1, sz.height)];
	
	return path;
}

-(NSBezierPath*) bezierPathByFlippingHorizontally	{
	NSRect bounds = [self bounds];
	float xMin = bounds.origin.x;
	float xMax = bounds.origin.x + bounds.size.width;
	
	NSPoint points[3];
	NSBezierPathElement element;
	NSBezierPath* newPath = [NSBezierPath bezierPath];
	int i, j;
	for (i = 0; i < [self elementCount]; i++)	{
		element = [self elementAtIndex:i associatedPoints:points];
		if (element == NSClosePathBezierPathElement)
			[newPath closePath];
		else if (element == NSCurveToBezierPathElement)	{
			for (j = 0; j < 3; j++)	{
				points[j] = convertPointForFlippingHorizontally(points[j], xMin, xMax);
			}
			[newPath curveToPoint:points[2] controlPoint1:points[0] controlPoint2:points[1]];
		}
		else	{
			points[0] = convertPointForFlippingHorizontally(points[0], xMin, xMax);
			if (element == NSMoveToBezierPathElement)
				[newPath moveToPoint:points[0]];
			else 
				[newPath lineToPoint:points[0]];
		}
	}
	
	return newPath;
}

@end



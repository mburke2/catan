//
//  ResView.m
//  catan better resource view
//
//  Created by James Burke on 2/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ResView.h"
#import "NSBezierPath-Additions.h"

@implementation ResView

-(id) initWithFrame:(NSRect)frame	{
	self = [super initWithFrame:frame];
	if (self)	{
		type = nil;
		image = nil;
		selectedImage = nil;
		selected = NO;
		myAlphaValue = 1.0;
	}
	return self;
}

-(void) dealloc	{
	[type release];
	[image release];
	[selectedImage release];
	
	[super dealloc];
}



-(void) drawRect:(NSRect)rect	{
	NSImage* imageToDraw;
	if (selected)
		imageToDraw = selectedImage;
	else
		imageToDraw = image;
	
//	NSRect bounds = [self bounds];
//	NSRect srcRect = NSMakeRect(rect.origin.x / bounds.size.width, rect.origin.y / bounds.size.height
//	[imageToDraw drawInRect:[self bounds] fromRect:NSMakeRect(0, 0, [imageToDraw size].width, [imageToDraw size].height) operation:NSCompositeSourceOver fraction:1.0];
	NSRect bounds = [self bounds];
	NSSize imageSize = [imageToDraw size];
	float w = (int)(rect.size.width / bounds.size.width);
	float h = (int)(rect.size.height / bounds.size.height);
	float x = (int)(rect.origin.x / bounds.size.width);
	float y = (int)(rect.origin.y / bounds.size.height);
	
//	NSLog(@"rect = %@, bounds = %@", NSStringFromRect(rect), NSStringFromRect([self bounds]));
	[imageToDraw drawInRect:rect fromRect:NSMakeRect(x * imageSize.width, y * imageSize.height, w * imageSize.width, h * imageSize.height) operation:NSCompositeSourceOver fraction:myAlphaValue];

}

-(void) setAlpha:(float)a	{
//	NSLog(@"setting alpha, %f", a);
	myAlphaValue = a;
	[self setNeedsDisplay:YES];
//	[self display];
}
-(void) olddrawRect:(NSRect)rect	{
	NSBezierPath* path;
	[image drawInRect:[self bounds] fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
	
	if (selected)	{
		[[[NSColor blackColor] colorWithAlphaComponent:0.4] set];
		path = [self bezierPathWithRoundedRect:NSMakeRect(0, 0, [image size].width, [image size].height) cornerRadius:[image size].width /10];
		[path fill];
	//	[NSBezierPath fillRect:[self bounds]];
	}
}

-(NSString*) type		{
	return type;
}
-(void) toggleSelected	{
	if (selected == YES)
		selected = NO;
	else
		selected = YES;
}


-(BOOL) selected	{
	return selected;
}


-(void) setType:(NSString*)str	{
	[type release];
	type = [str copy];
	[type retain];
	[self setImage];
}

-(NSImage*) image	{
	return image;
}	


-(void) setImage	{
	[image release];
//	NSString* imgName = [NSString stringWithFormat:@"%@Res.tiff", type];
	NSString* imgName = [NSString stringWithFormat:@"%@ResSmall", type];
	image = [NSImage imageNamed:imgName];
	[image retain];
	
	[selectedImage release];
	selectedImage = [[NSImage alloc] initWithSize:[image size]];
	[selectedImage lockFocus];
	[image drawInRect:NSMakeRect(0, 0, [image size].width, [image size].height) fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
	[[[NSColor blackColor] colorWithAlphaComponent:0.4] set];
//	NSBezierPath* path = [self bezierPathWithRoundedRect:NSMakeRect(0, 0, [image size].width, [image size].height) cornerRadius:[image size].width /10];
	NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, [image size].width, [image size].height) cornerRadius:[image size].width / 10];
	[path fill];
	[selectedImage unlockFocus];

//	[[selectedImage TIFFRepresentation] writeToFile:@"/selectedImage.tiff" atomically:NO];
}

-(void) setSelected:(BOOL)flag	{
	selected = flag;
}	

-(NSBezierPath*) bezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)rad	{

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


@end

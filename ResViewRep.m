//
//  ResViewRep.m
//  catan better resource view
//
//  Created by James Burke on 2/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ResViewRep.h"

//static int THE_STATIC_COUNTER = 0;

@implementation ResViewRep

-(id) init	{
	self = [super init];
	if (self)	{
//		THE_STATIC_COUNTER++;
//		NSLog(@"INIT, THE_STATIC_COUNTER = %d", THE_STATIC_COUNTER);
		selected = NO;
		type = nil;
		image = nil;
		selectedImage = nil;
		frame = NSMakeRect(-1.0, -1.0, 0, 0);
//		frame = 
	}
	return self;
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
-(void) dealloc	{
//	NSLog(@"dealloing resViewRep, %@, image count = %d, type count = %d", type, [image retainCount], [type retainCount]);
//	THE_STATIC_COUNTER--;
//	NSLog(@"dealloc, THE_STATIC_COUNTER = %d", THE_STATIC_COUNTER);
	[image release];
	[type release];
	
	[super dealloc];
}

-(void) setType:(NSString*)str	{
	[type release];
	type = [str copy];
	[type retain];
	[self setImage];
}


-(void) setImage	{
	[image release];
	NSString* imgName = [NSString stringWithFormat:@"%@Res.tiff", type];
//	NSImage* baseImage = [[NSImage imageNamed:imgName] autorelease];
	NSImage* baseImage = [NSImage imageNamed:imgName];

	image = [[[NSImage alloc] initWithSize:[baseImage size]] autorelease];
//	image = [NSImage imageNamed:imgName];

	[image lockFocus];
	[baseImage compositeToPoint:NSMakePoint(0, 0) operation:NSCompositeSourceOver];
	[image unlockFocus];
	[image retain];

	
	NSRect rect = NSMakeRect(0, 0, [image size].width, [image size].height);
	NSBezierPath* path;
	[selectedImage release];
	selectedImage = [[[NSImage alloc] initWithSize:[image size]] autorelease];

	[selectedImage lockFocus];
	[image drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	[[[NSColor blackColor] colorWithAlphaComponent:0.4] set];
	path = [NSBezierPath bezierPathWithRoundedRect:rect cornerRadius:rect.size.width / 6];
	[path fill];
	[selectedImage unlockFocus];
	
	[selectedImage retain];
	
	
}

-(void) setSelected:(BOOL)flag	{
	selected = flag;
}	

-(NSRect) frame	{
	return frame;
}
-(void) setFrame:(NSRect)f	{
	frame = f;
}
-(NSImage*) image	{
	if (selected)
		return selectedImage;
	return image;
}


@end

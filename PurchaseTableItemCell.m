//
//  PurchaseItemCell.m
//  catan
//
//  Created by James Burke on 12/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PurchaseTableItemCell.h"

#define PP NSLog(@"%s", __FUNCTION__)

@implementation PurchaseTableItemCell

-(id) init	{
	self = [super init];
	if (self)	{
		myString = nil;
		myImage = nil;
		enabled = YES;
		selected = NO;
	}
	return self;
}

-(void) dealloc	{
	[myImage release];
	[super dealloc];
}	
-(void) setString:(NSString*)str	{
	[myString release];
	myString = [str copy];
	[myString retain];
}

-(void) setImage:(NSImage*)image	{
	PP;
//	NSLog(@"newImage, %@", image);
//	NSLog(@"myImage, %@", myImage);
	[myImage release];
	myImage = [[NSImage alloc] initWithSize:[image size]];
	[myImage setFlipped:YES];
	[myImage lockFocus];
	[image drawInRect:NSMakeRect(0, 0, 18, 18) fromRect:NSMakeRect(0, 0, 18, 18) operation:NSCompositeSourceOver fraction:1.0];
	[myImage unlockFocus];
//	myImage = [image copy];

//	[myImage setFlipped:YES];
//	[myImage retain];
}	

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
//	NSDictionary* atts;
	NSColor* color;

	if (enabled == NO)
		color = [NSColor grayColor];
	else if (selected == YES)
		color = [NSColor whiteColor];
	else
		color = [NSColor blackColor];
		
	NSAttributedString* attString = [[[NSAttributedString alloc] initWithString:myString attributes:[NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName]] autorelease];
//	NSLog(@"attSring = %@", attString);
	float yMargin = (18 - [attString size].height) / 2.0;
	NSRect imageRect = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, 18, 18);
	NSRect stringRect = NSMakeRect(cellFrame.origin.x + 24, cellFrame.origin.y + yMargin, [attString size].width, [attString size].height);
	
	[attString drawInRect:stringRect];
	[myImage drawInRect:imageRect fromRect:NSMakeRect(0, 0, 18, 18) operation:NSCompositeSourceOver fraction:1.0];
//	NSLog(@"drew");
}

-(void) setSelected:(BOOL)flag	{
	selected = flag;
}
-(void) setEnabled:(BOOL)flag;	{
	enabled = flag;
}
@end

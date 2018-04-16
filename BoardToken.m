//
//  BoardToken.m
//  catan
//
//  Created by James Burke on 1/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BoardToken.h"
#import "Player.h"

#define NSLog //

@implementation BoardToken

-(id) initWithOwner:(Player*)owner	{
	self = [super init];
	if (self)	{
		myOwner = [owner retain];
		myImage = nil;
		[self buildImage];
		highlightFlag = NO;
		highlightImage = nil;
	}
	return self;
}
-(Player*) owner	{
	return myOwner;
}


-(NSImage*) image	{
//	PP;
//	NSLog(@"image size = %@", NSStringFromSize([myImage size]));
	if (highlightFlag == YES)	{
		if (highlightImage == nil)
			[self buildHighlightImage];
		
		return highlightImage;
	}	
	return myImage;
//	NSLog(@"THIS SHOULD NOT HAVE BEEN CALLED, %s", __FUNCTION__);
//	return [[[NSImage alloc] initWithSize:NSMakeSize(0, 0)] autorelease];
}



-(int) perspectives	{
	return 0;
}

-(NSString*) imagePrefix	{
	return @"";
}
-(NSSize) size	{
	return NSMakeSize(0, 0);
}

-(void) buildImage	{
	if (myImage)
		return;
	if ([self perspectives] == 0)
		return;
	int randomPerspective = 1 + rand() % [self perspectives];
	NSString* colorName = [[myOwner color] description];
	NSString* imageName = [NSString stringWithFormat:@"%@%dColor:%@", [self imagePrefix], randomPerspective, colorName];
	myImage = [NSImage imageNamed:imageName];
	if (myImage)	{
		[myImage retain];
		return;
	}
	
//	NSLog(@"building image for %@, %d", [self imagePrefix], randomPerspective, 
	NSLog(@"building image for %@", imageName);
	NSImage* base = [NSImage imageNamed:[NSString stringWithFormat:@"%@%dNewBuilding.png", [self imagePrefix], randomPerspective]];
	NSRect baseRect = NSMakeRect(0, 0, [base size].width, [base size].height);
	NSImage* shadow = [NSImage imageNamed:[NSString stringWithFormat:@"%@%dNewShadow.png", [self imagePrefix], randomPerspective]];

	NSImage* color = [[[NSImage alloc] initWithSize:[base size]] autorelease];
	[color lockFocus];
	[[myOwner color] set];
	[NSBezierPath fillRect:baseRect];
	[color unlockFocus];
	
	NSImage* coloredBuilding = [[[NSImage alloc] initWithSize:baseRect.size] autorelease];
	[coloredBuilding lockFocus];
	[base drawInRect:baseRect fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[color drawInRect:baseRect fromRect:baseRect operation:NSCompositeSourceAtop fraction:0.35];
	[coloredBuilding unlockFocus];
	
	NSLog(@"got colored building");
	myImage = [[[NSImage alloc] initWithSize:[base size]] autorelease];
	[myImage lockFocus];
	[shadow drawInRect:baseRect fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[coloredBuilding drawInRect:baseRect fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[myImage unlockFocus];

	NSLog(@"got image");
//	[myImage release];
//	myImage = [returnImage retain];
	[myImage retain];
	BOOL flag = [myImage setName:imageName];
	NSLog(@"retained it");
	NSLog(@"set it's name, %d", flag);
}
-(void) oldbuildImage	{
	if ([self perspectives] == 0)
		return;
	int randomPerspective = 1 + rand() % [self perspectives];
//	int randomPerspective = 
	NSImage* returnImage = [[[NSImage alloc] initWithSize:[self size]] autorelease];
	NSRect retRect = NSMakeRect(0, 0, [returnImage size].width, [returnImage size].height);
	
	NSImage* buildingBase;
	NSImage* shadowBase;
//	if ([[self imagePrefix] isEqualToString:@"city"])
//		buildingBase = [NSImage imageNamed:@"TestCity.png"];
//	else
		buildingBase = [NSImage imageNamed:[NSString stringWithFormat:@"%@%dNewBuilding.png", [self imagePrefix], randomPerspective]];
	//@"Perspective1_Building.png"];
	NSRect rect = NSMakeRect(0, 0, [buildingBase size].width, [buildingBase size].height);
//	NSImage* shadowBase = [NSImage imageNamed:@"Perspective1_Shadow.png"];
//	if ([[self imagePrefix] isEqualToString:@"city"])
//		shadowBase = [[[NSImage alloc] initWithSize:[self size]] autorelease];
//	else  
		shadowBase = [NSImage imageNamed:[NSString stringWithFormat:@"%@%dNewShadow.png", [self imagePrefix], randomPerspective]];
	//	NSLog(@"shadowBase = %@", shadowBase);
	NSImage* colorBase = [[[NSImage alloc] initWithSize:rect.size] autorelease];

	NSColor* color = [[myOwner color] blendedColorWithFraction:0.35 ofColor:[NSColor blackColor]];
	[colorBase lockFocus];
	[color set];
//	[[myOwner color] set];
	[NSBezierPath fillRect:rect];
	[colorBase unlockFocus];

	NSImage* coloredBuilding = [[[NSImage alloc] initWithSize:rect.size] autorelease];
	[coloredBuilding lockFocus];
	[buildingBase drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	[colorBase drawInRect:rect fromRect:rect operation:NSCompositeSourceAtop fraction:0.35];
	[coloredBuilding unlockFocus];
	
	[returnImage lockFocus];
	[shadowBase drawInRect:retRect fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	[coloredBuilding drawInRect:retRect fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	[returnImage unlockFocus];

	[myImage release];
	myImage = [returnImage retain];
//	NSLog(@"built image, it's %@", returnImage);
//	return returnImage;
}

-(void) buildHighlightImage	{
	highlightImage = [[NSImage alloc] initWithSize:[myImage size]];
	NSRect rect = NSMakeRect(0, 0, [myImage size].width, [myImage size].height);
	[highlightImage lockFocus];
	[myImage drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
//	[[NSColor blackColor] set];
//	[NSBezierPath fillRect:rect];
	[[NSColor greenColor] set];
	[[NSBezierPath bezierPathWithOvalInRect:rect] stroke];
	[highlightImage unlockFocus];

}

-(void) setHighlight:(BOOL)flag	{
	highlightFlag = flag;
	if (flag == YES)
		NSLog(@"highlihgting %@", self);
}

@end

//
//  CardFlipAnimation.m
//  catan
//
//  Created by James Burke on 3/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CardFlipAnimation.h"
#define NSLog //

@implementation CardFlipAnimation
/*2008-03-17 13:44:58.765 catan[424] *** 
-[CardFlipAnimation initWithImageName:
fromRect:
toRect:
withInfo:
animationLayer:
glLayer:]: 

selector not recognized [self = 0x6711540]
*/
-(id) initWithImageName:(NSString*)imageName fromRect:(NSRect)sRect toRect:(NSRect)eRect withInfo:(NSDictionary*)dict animationLayer:(NSView*)view glLayer:(NSView*)glView {
	self = [super init];
	if (self)	{
		myImage = [[NSImage imageNamed:imageName] shadowedImage];
		[myImage retain];
		myImageName = [imageName retain];
//		myImage = [image retain];
		animationLayer = view;
		glLayer = glView;
		startRect = sRect;
		endRect = eRect;
		infoDict = [dict retain];
		[self buildAnimations];
	}
	return self;
}

-(void) buildAnimations	{
//	NSLog(@"BUILDING ANIMATIONS");
	animatedView = [[[SimpleImageView alloc] initWithFrame:startRect] autorelease];
	NSImage* shadowedImage = [NSImage imageNamed:@"BackRes"];
//	[[shadowedImage TIFFRepresentation] writeToFile:@"/shadow1.tiff" atomically:NO];
	shadowedImage = [shadowedImage shadowedImage];
//	[[shadowedImage TIFFRepresentation] writeToFile:@"/shadow2.tiff" atomically:NO];
	
//	[[[[NSImage imageNamed:@"BackRes"] shadowedImage] TIFFRepresentation] writeToFile:@"/shadowedBack.tiff" atomically:NO];

	[animatedView setImage:shadowedImage];
//	[animatedView setHidden:YES];
	[animatedView setShouldDraw:NO];
	[animationLayer addSubview:animatedView];

	NSSize sz = [[NSImage imageNamed:@"BrickRes"] size];
	NSRect windowBounds = [animationLayer bounds];
	NSRect midRect = NSMakeRect((windowBounds.size.width - sz.width) / 2, (windowBounds.size.height - sz.height) / 2, sz.width, sz.height);
	midRect.size.width += 10;
	midRect.size.height += 10;
	midRect.origin.y -= 10;
//	NSLog(@"startRect = %@, midRect = %@, endRect = %@", NSStringFromRect(startRect), NSStringFromRect(midRect), NSStringFromRect(endRect));
	ani1 = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
		[NSDictionary dictionaryWithObjectsAndKeys:
			animatedView, NSViewAnimationTargetKey,
			[NSValue valueWithRect:startRect], NSViewAnimationStartFrameKey,
			[NSValue valueWithRect:midRect], NSViewAnimationEndFrameKey,
			nil]]];
	
	ani2 = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
		[NSDictionary dictionaryWithObjectsAndKeys:
			animatedView, NSViewAnimationTargetKey,
			[NSValue valueWithRect:midRect], NSViewAnimationStartFrameKey,
			[NSValue valueWithRect:endRect], NSViewAnimationEndFrameKey,
			nil]]];
			
	glAni = [[GLAnimation alloc] init];
	[glAni setView:glLayer];
	[glLayer setImage:myImageName];
	
	
	[ani1 setDelegate:self];
	[ani2 setDelegate:self];
	[ani1 setDuration:0.5];
	[ani2 setDuration:0.5];
	[glAni setDuration:1.2];
	[glAni setDelegate:self];
}
-(void) startAnimation	{
	[ani1 startAnimation];
}

-(BOOL) animationShouldStart:(NSAnimation*)ani	{
//	NSLog(@"starting card flip piece");	
	if (ani == ani1)	{
//		NSLog(@"first piece");
		[animatedView setShouldDraw:YES];
//		[animatedView setHidden:NO];
	}
	
	if (ani == glAni)	{
		[glLayer setProgress:0.0];
		[glLayer drawScene];
		[glLayer setHidden:NO];
	}
//		[animated
	
	return YES;
}

-(void) animationDidEnd:(NSAnimation*)ani	{
	if (ani == ani1)	{
		[glLayer setProgress:0.0];
		[glLayer drawScene];
		[glLayer setHidden:NO];
//		[animatedView setHidden:YES];
		[animatedView setShouldDraw:NO];
		[animatedView setImage:myImage];
//		NSLog(@"end frame = %@", NSStringFromRect([animatedView frame]));
		[glAni startAnimation];
	}
	else if (ani == glAni)	{
//		[animatedView setHidden:NO];
		[animatedView setShouldDraw:YES];
		[animatedView display];
		[glLayer setHidden:YES];

		[ani2 startAnimation];
	}
	else if (ani == ani2)	{
		[myDelegate animationDidEnd:self];
	}
}
-(void) setDelegate:(id)obj	{
	myDelegate = obj;
}


-(NSArray*) viewAnimations	{
	NSMutableDictionary* aniDict = [NSMutableDictionary dictionaryWithDictionary:infoDict];
	[aniDict setObject:animatedView forKey:NSViewAnimationTargetKey];
	[aniDict setObject:[NSNumber numberWithBool:YES] forKey:@"SHOULD_REMOVE_VIEW"];
	return [NSArray arrayWithObject:aniDict];

}



@end

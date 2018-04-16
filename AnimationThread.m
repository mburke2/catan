//
//  AnimationThread.m
//  catan
//
//  Created by James Burke on 2/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AnimationThread.h"
#import "AnimatedCardView.h"
#import "BoardView.h"
#import "BankView.h"
#import "CollectionView.h"

#define PP NSLog(@"%s", __FUNCTION__)

@implementation AnimationThread
+(NSDistantObject*) createAnimationThread	{
	[NSThread detachNewThreadSelector:@selector(createThread:) toTarget:self withObject:nil];
	
//	[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
//	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	NSConnection* connection = nil;
	while (connection == nil)	{
//		NSLog(@"getting connection");
//	animationThreadProtocol
		connection = [NSConnection connectionWithRegisteredName:@"AnimationConnection" host:nil];
	}
	
	return [connection rootProxy];
}


+(void) createThread:(id)sender	{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSConnection* connection = [NSConnection defaultConnection];
	[connection registerName:@"AnimationConnection"];
	AnimationThread* at = [[AnimationThread alloc] init];
	[connection setRootObject:at];
	
	[[NSRunLoop currentRunLoop] run];
	
	[pool release];
}




-(void) setAnimatedCardView:(AnimatedCardView*)acv boardView:(BoardView*)board collectionView:(CollectionView*)cv bankView:(BankView*)bank shadeView:(FadeImageView*)shade	{
	animationView = [acv retain];
	boardView = [board retain];
	collectionView = [cv retain];
	bankView = [bank retain];
	boardShadeView = [shade retain];
}

-(void) startAnimations:(NSArray*)anis	{
	PP;
	return;
//	[anis retain];
//	while (blocking == YES)	{
//		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
//		NSLog(@"delaying animations");
//	}
	
	[animationView startAnimations:anis];
//	[anis release];
}

-(void) blankfadeImageIn:(NSImage*)image	{
	return;
}

-(void) fadeImageIn:(NSImage*)image	{
	PP;
//	NSLog(@"thread = %@", [NSThread currentThread]);
	NSViewAnimation* va = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
		[NSDictionary dictionaryWithObjectsAndKeys:
			boardShadeView, NSViewAnimationTargetKey,
			[NSValue valueWithRect:[boardShadeView frame]], NSViewAnimationStartFrameKey,
			NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil]]];
//	NSLog(@"Made animation");
	[boardShadeView setImage:image];
//	NSLog(@"set image");
	[va setDuration:5.0];
//	NSLog(@"set duration");
	[va retain];
//	[va startAnimation];
	[va performSelectorOnMainThread:@selector(startAnimation) withObject:nil waitUntilDone:NO];
//	NSLog(@"starting");
//	NSLog(@"endDate = %@", [NSDate date
	while ([va isAnimating])	{
//		NSLog(@"blocking");
		[[NSRunLoop currentRunLoop] runMode:@"CATAN_ANIMATION_MODE" beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
	}
	
	[va release];
//	NSLog(@"done with animation");
}
-(void) oldfadeImageIn:(NSImage*)image	{
	PP;
//	blocking = YES;

//	NSImageView* iv = [[[NSImageView alloc] initWithFrame:[boardView bounds]] autorelease];
//	[iv setHidden:YES];
//	[iv setImage:image];
//	[boardShadeView setImage:image];
	
//	NSLog(@"going to print image");
//	NSLog(@"image = %@", image);
//	NSLog(@"going to write image");
//	[[image TIFFRepresentation] writeToFile:@"/image.tiff" atomically:NO];
//	[boardView addSubview:iv];
	
//	NSViewAnimation* va = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
//		[NSDictionary dictionaryWithObjectsAndKeys:
//			iv, NSViewAnimationTargetKey,
//			[NSValue valueWithRect:[iv frame]], NSViewAnimationStartFrameKey,
//			[NSValue valueWithRect:[iv frame]], NSViewAnimationEndFrameKey,
	//		NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil]]] autorelease];
//			nil]]] autorelease];
//	[va setDuration:4.0];
//	[va setDelegate:self];
//	[va startAnimation];
	NSRect rect = NSMakeRect(0, 0, [image size].width, [image size].height);

//	NSImage* canvas = [[NSImage alloc] initWithSize:[image size]];
//	[canvas lockFocus];
//	[image drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
//	[canvas unlockFocus];
//	NSLog(@"boardShadeView = %@",boardShadeView);
//	NSLog(@"superview = %@", [boardShadeView superview]);
//	NSLog(@"board view = %@", boardView);
//	NSLog(@"writing canvas");
//	[[canvas TIFFRepresentation] writeToFile:@"/canvas.tiff" atomically:NO];
	[boardShadeView setHidden:NO];
	[boardShadeView setImage:image];
	[boardShadeView setAlpha:0.0];
//	[boardShadeView display];
	NSDate* startDate = [NSDate date];
	float alpha = 0.0;
	float duration = 0.5;
	float tStep = 0.1;
	float alphaStep = 0.1;
//	float alphaStep =

//	NSLog(@"starting b
	while (blocking == YES)	{
//		NSLog(@"blocking");
	//	[[NSRunLoop currentRunLoop] runMode:@"NonsenseMode" beforeDate:[NSDate dateWithTimeIntervalSinceNow:tStep]];
		alpha = -[startDate timeIntervalSinceNow] / duration;
		[boardShadeView setAlpha:alpha];
		if (alpha >= 1.0)
			blocking = NO;
	//	if (-[startDate timeIntervalSinceNow] > duration)
	//		blocking = NO;
	}
//	NSLog(@"done blocking");
}

-(void) animationDidEnd:(NSAnimation*)ani	{
//	NSLog(@"fade animation ended");
	blocking = NO;
//	[[[[ani viewAnimations] objectAtIndex:0] objectForKey:NSViewAnimationTargetKey] removeFromSuperview];
}




@end

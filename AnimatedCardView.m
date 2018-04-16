//
//  AnimatedCardView.m
//  catan
//
//  Created by James Burke on 2/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AnimatedCardView.h"
#define PP NSLog(@"%s", __FUNCTION__)
#import "JunkWindow.h"
#import "SimpleImageView.h"
#import "ResourceManager.h"
//static NSAnimation* THE_STATIC_ANIMATION = nil;
//static NSDate* THE_STATIC_DATE = nil;
@implementation AnimatedCardView


-(id) initWithFrame:(NSRect)rect	{
	self = [super initWithFrame:rect];
	if (self)	{
//		NSLog(@"%s", __FUNCTION__);
		/*
		animationTimer = nil;
		myImage = nil;
		currentFrame = NSMakeRect(0, 0, 0, 0);
		endFrame = NSMakeRect(0, 0, 0, 0);
		startFrame = NSMakeRect(0, 0, 0, 0);
		startDate = nil;
		*/
//		frames = [[NSMutableArray alloc] init];
//		images = [[NSMutableArray alloc] init];
		
		animations = [[NSMutableArray alloc] init];
		mAnimations = [[NSMutableArray alloc] init];
		callbacks = [[NSMutableArray alloc] init];
//		[self registerForDraggedTypes:[NSArray arrayWithObject:@"CATAN_RESOURCE_TYPE"]];
	}
	return self;
}
/*
-(void) drawRect:(NSRect)rect	{
//	NSLog(@"drawing, %@", NSStringFromRect(currentFrame));
//	[myImage drawInRect:currentFrame fromRect:NSMakeRect(0, 0, [myImage size].width, [myImage size].height) operation:NSCompositeSourceOver fraction:1.0];
	[[NSColor redColor] set];
	NSBezierPath* path = [NSBezierPath bezierPathWithRect:[self bounds]];
	[path setLineWidth:5];
	[path stroke];
//	[NSBezierPath strokeRect:[self bounds]];
	int i;
	NSImage* image;
	for (i = 0; i < [images count]; i++)	{
		image = [images objectAtIndex:i];
		[image drawInRect:[[frames objectAtIndex:i] rectValue] fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeSourceOver fraction:1.0];
	}

}
*/

/*
-(void) setDelegate:(id)delegate	{
	myDelegate = [delegate retain];
}
*/

-(void) startAnimations:(NSArray*)anis	{
//	NSLog(@"starting animations on thread %@", [NSThread currentThread]);
	if ([anis count] <= 0)
		return;
	int i;
	NSMutableArray* middleRects = [NSMutableArray array];
	NSMutableArray* views = [NSMutableArray array];
//	NSSize sz = [[[NSImage imageNamed:@"BrickRes.tiff"] autorelease] size];
	NSSize sz = [[NSImage imageNamed:@"BrickRes.tiff"] size];

	sz.width = sz.width;
	sz.height = sz.height;
	float middleMargin = 4;
	NSSize middleSize = NSMakeSize([anis count] * (sz.width + middleMargin), sz.height);
	NSRect middleRect = NSMakeRect( ([self bounds].size.width - middleSize.width) / 2, ([self bounds].size.height - middleSize.height) / 2, middleSize.width, middleSize.height);
	NSRect tmpRect = NSMakeRect(middleRect.origin.x, middleRect.origin.y, sz.width, sz.height);
//	tmpRect.origin = [[self window] convertBaseToScreen:tmpRect.origin];
	NSImageView* iv;
//	NSWindow* win;
//	NSPoint pt;
//	NSRect junkRect;
	NSShadow* shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowOffset:NSMakeSize(4, -10)];
	[shadow setShadowBlurRadius:3.0];
	[shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.6]];
	for (i = 0; i < [anis count]; i++)	{
		iv = [[[SimpleImageView alloc] initWithFrame:[[[anis objectAtIndex:i] objectForKey:@"StartFrame"] rectValue]] autorelease];
//		junkRect = [[[anis objectAtIndex:i] objectForKey:@"StartFrame"] rectValue];
//		pt = junkRect.origin;
//		iv = [[[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, junkRect.size.width, junkRect.size.height)] autorelease];
		NSImage* newImage = [[[NSImage alloc] initWithSize:NSMakeSize(sz.width + 6, sz.height + 12)] autorelease];
		[newImage lockFocus];
		[shadow set];
		[[[anis objectAtIndex:i] objectForKey:@"Image"] compositeToPoint:NSMakePoint(6, 12) operation:NSCompositeSourceOver];
		[newImage unlockFocus];
//		[iv setImage:[[anis objectAtIndex:i] objectForKey:@"Image"]];
		[iv setImage:newImage];
//		[[newImage TIFFRepresentation] writeToFile:[NSString stringWithFormat:@"/res%d.tiff", i] atomically:NO];
//		[iv setImageScaling:NSScaleToFit];
		
//		junkRect.origin = [[self window] convertBaseToScreen:junkRect.origin];
//		win = [[NSWindow alloc] initWithContentRect:junkRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
//		win = [[JunkWindow alloc] initWithImage:[[anis objectAtIndex:i] objectForKey:@"Image"]];

//		[win setOpaque:NO];
//		[win setBackgroundColor:[NSColor clearColor]];
//		[win setContentView:iv];
//		[win setHasShadow:YES];

//		[[win contentView] addSubview:iv];
//		[views addObject:win];
		[views addObject:iv];
		[middleRects addObject:[NSValue valueWithRect:tmpRect]];
		tmpRect.origin.x += (sz.width + middleMargin);
	}
	middleRects = [self middleRectsForResources:anis];
	NSMutableArray* vas = [NSMutableArray array];
	NSDictionary* dict;
	for (i = 0; i < [anis count]; i++)	{
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
			[views objectAtIndex:i], NSViewAnimationTargetKey,
			[[anis  objectAtIndex:i] objectForKey:@"StartFrame"], NSViewAnimationStartFrameKey,
			[middleRects objectAtIndex:i], NSViewAnimationEndFrameKey, nil];
		[vas addObject:dict];
	}
	
	NSViewAnimation* startAnimation = [[NSViewAnimation alloc] initWithViewAnimations:vas];
	vas = [NSMutableArray array];
	for (i = 0; i < [anis count]; i++)	{
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
			[views objectAtIndex:i], NSViewAnimationTargetKey,
			[middleRects objectAtIndex:i], NSViewAnimationStartFrameKey, nil];
//			[middleRects objectAtIndex:i], NSViewAnimationEndFrameKey, nil];
		[vas addObject:dict];
	}
	
	NSViewAnimation* middleAnimation = [[NSViewAnimation alloc] initWithViewAnimations:vas];
	
	vas = [NSMutableArray array];
	for (i = 0; i < [anis count]; i++)	{
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
			[views objectAtIndex:i], NSViewAnimationTargetKey, 
			[middleRects objectAtIndex:i], NSViewAnimationStartFrameKey,
			[[anis objectAtIndex:i] objectForKey:@"EndFrame"], NSViewAnimationEndFrameKey, nil];
		[vas addObject:dict];
//		[delegates addObject:[[anis objectAtIndex:i] objectForKey:@"Delegate"]];
	}
	
	NSViewAnimation* endAnimation = [[NSViewAnimation alloc] initWithViewAnimations:vas];
	
	[startAnimation setDuration:0.5];
	[middleAnimation setDuration:0.5];
	[endAnimation setDuration:0.35];
	[endAnimation setAnimationCurve:NSAnimationLinear];


	[endAnimation setDelegate:self];
	[middleAnimation setDelegate:self];

	for (i = 0; i < [views count]; i++)	{
		[self addSubview:[views objectAtIndex:i]];
		//[[views objectAtIndex:i] orderFront:nil];
	}
	NSAnimationBlockingMode blockMode = NSAnimationNonblocking;

	[startAnimation setAnimationBlockingMode:blockMode];
	[middleAnimation setAnimationBlockingMode:blockMode];
	[endAnimation setAnimationBlockingMode:blockMode];



//	[middleAnimation startWhenAnimation:startAnimation reachesProgress:endProgress];
//	[endAnimation startWhenAnimation:middleAnimation reachesProgress:endProgress];
	[animations addObject:endAnimation];
	[mAnimations addObject:middleAnimation];
	[callbacks addObject:[[anis objectAtIndex:0] objectForKey:@"CallbackInfo"]];

//	[startAnimation setDelegate:self];
//	THE_STATIC_ANIMATION = startAnimation;
	[middleAnimation startWhenAnimation:startAnimation reachesProgress:1.0];
	[endAnimation startWhenAnimation:middleAnimation reachesProgress:1.0];

//	[startAnimation startAnimation];
	[startAnimation performSelector:@selector(startAnimation) withObject:nil afterDelay:0.1];

//	[endAnimation performSelector:@selector(startAnimation) withObject:nil afterDelay:[startAnimation duration] + 0.75];
	[self setNeedsDisplay:YES];
//	while ([endAnimation currentProgress] < 1)	{
//		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
//		[[NSRunLoop currentRunLoop] runMode:@"CATAN_ANIMATION_MODE" beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
//
//	}
	
//	[animations addObject:endAnimation];

	//int i;


//	[endAnimation startWhenAnimation:middleAnimation reachesProgress:1.0];
//	[endAnimation startWhenAnimation:startAnimation reachesProgress:0.01];

}
- (BOOL)animationShouldStart:(NSAnimation*)animation	{
	PP;
	int index;
//	NSLog(@"animation = %@", animation);
	NSArray* viewAnimations = [animation viewAnimations];
	if ([viewAnimations count] > 0)		{
		if ([[viewAnimations objectAtIndex:0] objectForKey:NSViewAnimationEndFrameKey] == nil)	{
			index = [mAnimations indexOfObject:animation];
			NSDictionary* callbackInfo = [callbacks objectAtIndex:index];
			float delay = [(ResourceManager*)[callbackInfo objectForKey:@"Object"] delayMiddleAnimation:[callbackInfo objectForKey:@"Parameter"]];
			[animation setDuration:delay + [animation duration]];
			//NSLog(@"starting middle animation");
		}
	}
	
	return YES;
}	


/*
-(void) startAnimation:(NSDictionary*)dict	{
	PP;
	NSViewAnimation* animation = [[[NSViewAnimation alloc] init] autorelease];
	[animation setAnimationBlockingMode:NSAnimationNonblocking];
	[animations addObject:animation];
	[delegates addObject:[NSDictionary dictionaryWithObjectsAndKeys:
		[dict objectForKey:@"Delegate"], @"Delegate",
		[dict objectForKey:@"CallbackParam"], @"CallbackParam", nil]];
		
	NSImageView* iv = [[[NSImageView alloc] initWithFrame:[[dict objectForKey:@"StartFrame"] rectValue]] autorelease];
	[iv setImage:[dict objectForKey:@"Image"]];
	[self addSubview:iv];
	NSDictionary* aniDict = [NSDictionary dictionaryWithObjectsAndKeys:
		iv, NSViewAnimationTargetKey,
		[dict objectForKey:@"StartFrame"], NSViewAnimationStartFrameKey,
		[dict objectForKey:@"EndFrame"], NSViewAnimationEndFrameKey, nil];
		
	[animation setViewAnimations:[NSArray arrayWithObject:aniDict]];
	[animation setDuration:0.5];
	[animation setDelegate:self];
	
	[animation startAnimation];
}
*/
/*
-(void) drawRect:(NSRect)rect	{
	int i, j;
	NSArray* arr;
	[[NSColor redColor] set];
	for (i = 0; i < [animations count]; i++)	{
		arr = [[animations objectAtIndex:i] viewAnimations];
		for (j = 0; j < [arr count]; j++)	{
			[NSBezierPath strokeRect:[[[arr objectAtIndex:j] objectForKey:NSViewAnimationEndFrameKey] rectValue]];
		}
	}
}*/
- (void)animationDidEnd:(NSAnimation*)animation	{
	PP;
	int index = [animations indexOfObject:animation];
	if (index == NSNotFound)
		return;
//	NSLog(@"index = %d", index);
	NSDictionary* callbackDict = [callbacks objectAtIndex:index];
	
	id object = [callbackDict objectForKey:@"Object"];
	id param = [callbackDict objectForKey:@"Parameter"];
	SEL selector = NSSelectorFromString([callbackDict objectForKey:@"Selector"]);
//	NSLog(@"object = %@, param = %@, sel = %@", object, param, NSStringFromSelector(selector));
	[object performSelector:selector withObject:param afterDelay:0.01];
//	[object performSelector:selector withObject:param];
//	[del animationFinished:param];

	NSArray* views = [animation viewAnimations];
	NSView* view;
	int i;
	for (i = 0; i < [views count]; i++)	{
		view = [[views objectAtIndex:i] objectForKey:NSViewAnimationTargetKey];
//		NSLog(@"current frame = %@, targetFrame = %@", NSStringFromRect([view frame]), NSStringFromRect([[[views objectAtIndex:i] objectForKey:NSViewAnimationEndFrameKey] rectValue]));
//		[view removeFromSuperviewWithoutNeedingDisplay];
//		[view removeFromSuperview];
		[view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.05];
//		[view performSelector:@selector(orderOut:) withObject:nil afterDelay:0.05];
//		[view removeFromSuperview];
	}	
//	[[[callbacks objectAtIndex:index] retain] autorelease];
	[[[animations objectAtIndex:index] retain] autorelease];

	[callbacks removeObjectAtIndex:index];
	[animations removeObjectAtIndex:index];
	[mAnimations removeObjectAtIndex:index];
	[self setNeedsDisplay:YES];
}



-(void) oldstartAnimation:(NSDictionary*)dict	{
	PP;
//	NSImage* img = [dict objectForKey:@"Image"];
//	NSRect sFrame = [[dict objectForKey:@"StartFrame"] rectValue];
//	NSRect eFrame = [[dict objectForKey:@"EndFrame"] rectValue];
//	float l = [[dict objectForKey:@"AnimationLength"] floatValue];
//	id del = [dict objectForKey:@"Delegate"];
//	[self animateImage:img fromFrame:sFrame toFrame:eFrame time:l delegate:del];
//	[images addObject:[dict objectForKey:@"Image"]];
//	[frames addObject:[dict objectForKey:@"StartFrame"]];
	NSRect start = [[dict objectForKey:@"StartFrame"] rectValue];
	NSImageView* sub = [[[NSImageView alloc] initWithFrame:start] autorelease];
	[self addSubview:sub];
	[sub setImage:[dict objectForKey:@"Image"]];
	NSMutableDictionary* mDict = [NSMutableDictionary dictionaryWithDictionary:dict];
	[mDict setObject:[NSDate date] forKey:@"StartTime"];
	[mDict setObject:sub forKey:@"Subview"];
	[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(update:) userInfo:mDict repeats:YES];
}
/*
-(void) animateImage:(NSImage*)image fromFrame:(NSRect)f1 toFrame:(NSRect)f2 time:(float)time delegate:(id)delegate {
	myImage = [image retain];
	currentFrame = f1;
	startFrame = f1;
	endFrame = f2;
	animationLength = time;
	[self setNeedsDisplay:YES];
	startDate = [[NSDate date] retain];
	myDelegate = delegate;
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(update:) userInfo:nil repeats:YES];
}*/

-(void) update:(NSTimer*)t		{
//	[self setNeedsDisplay:YES];

//	NSLog(@"timer fired");
	NSDictionary* info = [t userInfo];
	NSView* subview = [info objectForKey:@"Subview"];
	NSRect endFrame = [[info objectForKey:@"EndFrame"] rectValue];
	NSRect startFrame = [[info objectForKey:@"StartFrame"] rectValue];
	NSRect currentFrame;

//	NSImage* image = [info objectForKey:@"Image"];
//	int index = [images indexOfObject:image];
	NSDate* startDate = [info objectForKey:@"StartTime"];
	float animationLength = [[info objectForKey:@"AnimationLength"] floatValue];
	id delegate = [info objectForKey:@"Delegate"];
	float percent = (-[startDate timeIntervalSinceNow] / animationLength);
//	if (-[startDate timeIntervalSinceNow] > animationLength)	{
	if (percent > 1)	{
		[delegate animationFinished:[info objectForKey:@"CallbackParam"]];
//		myDelegate = nil;
//		[myImage release];
//		myImage = nil;
		[t invalidate];
		t = nil;
//		return;
//		[images removeObjectAtIndex:index];
//		[frames removeObjectAtIndex:index];
		currentFrame = [subview frame];
		[subview removeFromSuperview];
		[self setNeedsDisplayInRect:currentFrame];
//		percent = 1.0;
		return;
	}
	
	
	currentFrame.origin.x = startFrame.origin.x + percent * (endFrame.origin.x - startFrame.origin.x);
	currentFrame.origin.y = startFrame.origin.y + percent * (endFrame.origin.y - startFrame.origin.y);
	currentFrame.size.width = startFrame.size.width + percent * (endFrame.size.width - startFrame.size.width);
	currentFrame.size.height = startFrame.size.height + percent * (endFrame.size.height - startFrame.size.height);
	[self setNeedsDisplayInRect:[subview frame]];
	[subview setFrame:currentFrame];
	[self setNeedsDisplayInRect:currentFrame];
//	[frames replaceObjectAtIndex:index withObject:[NSValue valueWithRect:currentFrame]];
}

-(NSDragOperation) draggingEntered:(id <NSDraggingInfo>)sender	{
//	NSLog(@"dragging entered");
	return NSDragOperationNone;
}

-(NSMutableArray*) middleRectsForResources:(NSArray*)res	{
	NSSize sz = [[NSImage imageNamed:@"BrickRes.tiff"] size];
	float margin = 4.0;
	if (sz.width * [res count] + margin * ([res count] - 1) > [self bounds].size.width)	{
		float newWidth = ([self bounds].size.width - ([res count] - 1) * margin) / [res count];
		float factor = newWidth / sz.width;
		sz.width = (int) (factor * sz.width);
		sz.height = (int) (factor * sz.height);
	}
	
	NSSize netSize = NSMakeSize(margin * [res count] + sz.width * [res count], sz.height);
	NSPoint p = NSMakePoint( ([self bounds].size.width - netSize.width) / 2, ([self bounds].size.height - netSize.height) / 2);
	
	NSMutableArray* result = [NSMutableArray array];
	int i;
	for (i = 0; i < [res count]; i++)	{
		[result addObject:[NSValue valueWithRect:NSMakeRect(p.x, p.y, sz.width, sz.height)]];
		p.x += (margin + sz.width);
	}
	
	return result;
}

@end

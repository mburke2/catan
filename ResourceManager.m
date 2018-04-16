//
//  ResourceManager.m
//  catan
//
//  Created by James Burke on 2/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ResourceManager.h"
#import "DEBUG.h"
#define PP NSLog(@"%s", __FUNCTION__)
//#define NSLog //
#import "FadeImageView.h"
#import "NSShadow-Additions.h"
#import "PlayerView.h"
#import "Edge.h"
@implementation ResourceManager
-(id) initWithAnimationLayer:(AnimatedCardView*)acv playerViews:(NSArray*)arr bankView:(BankView*)bank boardView:(BoardView*)board resourceView:(CollectionView*)cv	{
//	PP;
	self = [super init];
	if (self)	{
		confettiView = nil;
		animatingFlag = NO;
		fadeInAnimation = nil;
		endAni = nil;
	//	FadeImageView* shadeView = [[FadeImageView alloc] initWithFrame:[board bounds]];
	//	[board addSubview:shadeView];
		NSRect shadeFrame = [board bounds];
		shadeFrame.origin = [[[board window] contentView] convertPoint:shadeFrame.origin fromView:board];
		boardShadeView = [[[SimpleImageView alloc] initWithFrame:shadeFrame] autorelease];
		[board setPostsFrameChangedNotifications:YES];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boardFrameChanged:) name:NSViewFrameDidChangeNotification object:board];
//		[boardShadeView setImageScaling:NSScaleToFit];
//		[board addSubview:boardShadeView];
//		[boardShadeView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[boardShadeView setAlphaValue:0.0];
		[boardShadeView setHidden:YES];
//		[shadeView setAu
//		animationThread = [AnimationThread createAnimationThread];
//		[animationThread setProtocolForProxy:@protocol(animationThreadProtocol)];
//		[animationThread setAnimatedCardView:acv boardView:board collectionView:cv bankView:bank shadeView:boardShadeView];
//		[animationThread retain];
//		NSLog(@"Animation thread = %@", animationThread);
		animationLayer = [acv retain];
		[animationLayer addSubview:boardShadeView];
	
		cardFlipView = [[CardFlipView alloc] initWithFrame:[animationLayer frame]];
		[cardFlipView setHidden:YES];
		[cardFlipView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[animationLayer addSubview:cardFlipView];

		playerViews = [arr retain];
		boardView = [board retain];
		bankView = [bank retain];
		localResView = [cv retain];
		theAnimationChain = [[NSMutableArray alloc] init];
	}
//	NSLog(@"returning res manager");
	return self;
}

-(void) boardFrameChanged:(NSNotification*)Note	{
	NSRect shadeFrame = [boardView bounds];
	shadeFrame.origin = [[[boardView window] contentView] convertPoint:shadeFrame.origin fromView:boardView];
	[boardShadeView setFrame:shadeFrame];
//	NSLog(@"BOARD FRAME CHANGED");
//	printf("boardFrameChanged\n");
}
/*
-(void) stealResource:(NSString*)str fromPlayer:(Player*)fromPlayer toPlayer:(Player*)toPlayer	{
	[toPlayer addResource:str];
	if (fromPlayer == [[GameController gameController] localPlayer])
		return;
	NSView* originView = [self viewForPlayer:fromPlayer];
	NSView* targetView = [self viewForPlayer:toPlayer];
	NSArray* arr = [originView reserveFramesForResources:[NSArray arrayWithObject:str]];
	NSRect sRect = [[arr objectAtIndex:0] rectValue];
	sRect.origin = [[[originView window] contentView] convertPoint:sRect.origin fromView:originView];
	arr = [targetView reserveFramesForResources:[NSArray arrayWithObject:str]];
	NSRect eRect = [[arr objectAtIndex:0] rectValue];
	eRect.origin = [[[targetView window] contentView] convertPoint:eRect.origin fromView:targetView];
	
	if (toPlayer != [[GameController gameController] localPlayer])	{
		[self runAnimationForImages:[NSArray arrayWithObject:[NSImage imageNamed:@"BackRes"]]
			fromRects:[NSArray arrayWithObject:[NSValue valueWithRect:sRect]]
			toRects:[NSArray arrayWithObject:[NSValue valueWithRect:eRect]]];
	}
	else	{
		[self runLocalStealAnimationForResource:res fromRect:sRect toRect:eRect];
	}
}*/


-(void) stealResource:(NSString*)res fromPlayer:(Player*)fromPlayer toPlayer:(Player*)toPlayer	{
	[fromPlayer incrementStolenResources:1];
	NSView* originView = [self viewForPlayer:fromPlayer];
	NSView* targetView = [self viewForPlayer:toPlayer];

	NSRect startRect = [[[originView reserveFramesForResources:[NSArray arrayWithObject:res]] objectAtIndex:0] rectValue]; 
	NSRect endRect = [[[targetView reserveFramesForResources:[NSArray arrayWithObject:res]] objectAtIndex:0] rectValue];
	NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
		toPlayer, @"PLAYER",
		res, @"TYPE",
		[NSValue valueWithRect:endRect], @"TARGET_FRAME",
		nil];
	
	startRect.origin = [[[originView window] contentView] convertPoint:startRect.origin fromView:originView];
	endRect.origin = [[[targetView window] contentView] convertPoint:endRect.origin fromView:targetView];
	
	if (fromPlayer != [[GameController gameController] localPlayer] && [[GameController gameController] localPlayer] != toPlayer)	{
			[self runAnimationForImages:[NSArray arrayWithObject:[NSImage imageNamed:@"BackRes"]]
				fromRects:[NSArray arrayWithObject:[NSValue valueWithRect:startRect]]
				 toRects:[NSArray arrayWithObject:[NSValue valueWithRect:endRect]]
				  withInfo:[NSArray arrayWithObject:infoDict]];
	}
	
	else if (fromPlayer == [[GameController gameController] localPlayer])	{
		[self runAnimationForImages:[NSArray arrayWithObject:[NSImage imageNamed:[NSString stringWithFormat:@"%@Res", res]]]
				fromRects:[NSArray arrayWithObject:[NSValue valueWithRect:startRect]]
				 toRects:[NSArray arrayWithObject:[NSValue valueWithRect:endRect]]
				  withInfo:[NSArray arrayWithObject:infoDict]];
	}
	
	else	{
		CardFlipAnimation* ani = [[[CardFlipAnimation alloc] initWithImageName:[NSString stringWithFormat:@"%@Res", res]
			fromRect:startRect
			toRect:endRect
			withInfo:infoDict
			animationLayer:animationLayer
			glLayer:cardFlipView
			] autorelease];
		[ani setDelegate:self];
		[theAnimationChain addObject:ani];
		[self startChainIfNessecary];
	}
		
}

/*
-(void) tradedResources:(int)n;
-(void) receivedResourcesViaTrade:(int)n;

*/
//-(void) runLocalStealAnimationForResource:(NSString*)res
-(void) tradeResources:(NSArray*)resArr fromPlayer:(Player*)fromPlayer toPlayer:(Player*)toPlayer	{
	[fromPlayer tradedResources:[resArr count]];
	[toPlayer receivedResourcesViaTrade:[resArr count]];
	resArr = [self sortResources:resArr];
	int i;
//	for (i = 0; i < [resArr count]; i++)	{
//		[toPlayer addResource:[resArr objectAtIndex:i]];
//	}
	
//	if (fromPlayer == [[GameController gameController] localPlayer])
//		return;
	
	NSView* originView = [self viewForPlayer:fromPlayer];
	NSView* targetView = [self viewForPlayer:toPlayer];
	NSMutableArray* startRects = [NSMutableArray arrayWithArray:[originView reserveFramesForResources:resArr]];
	NSMutableArray* endRects = [NSMutableArray arrayWithArray:[targetView reserveFramesForResources:resArr]];

	NSMutableArray* images = [NSMutableArray array];
//	int i;
	NSMutableArray* infoArray = [NSMutableArray array];

	NSRect rect;
	for (i = 0; i < [startRects count]; i++)	{
		[infoArray addObject:[NSMutableDictionary dictionary]];
		[[infoArray objectAtIndex:i] setObject:toPlayer forKey:@"PLAYER"];
		[[infoArray objectAtIndex:i] setObject:[resArr objectAtIndex:i] forKey:@"TYPE"];
		rect = [[startRects objectAtIndex:i] rectValue];
		rect.origin = [[[originView window] contentView] convertPoint:rect.origin fromView:originView];
		[startRects replaceObjectAtIndex:i withObject:[NSValue valueWithRect:rect]];
	}
	for (i = 0; i < [endRects count]; i++)	{

		rect = [[endRects objectAtIndex:i] rectValue];
		[[infoArray objectAtIndex:i] setObject:[NSValue valueWithRect:rect] forKey:@"TARGET_FRAME"];
	
		rect.origin = [[[targetView window] contentView] convertPoint:rect.origin fromView:targetView];
		[endRects replaceObjectAtIndex:i withObject:[NSValue valueWithRect:rect]];
	}
	for (i = 0; i < [resArr count]; i++)	{
		[images addObject:[NSImage imageNamed:[NSString stringWithFormat:@"%@Res", [resArr objectAtIndex:i]]]];
	}
//	NSLog(@"got to here, images = %@", images);
	
	NSViewAnimation* ani = [targetView animationToMakeRoomForNewResourcesOfType:resArr];
	[theAnimationChain addObject:ani];
	[ani setDelegate:self];
	[self runAnimationForImages:images fromRects:startRects toRects:endRects withInfo:infoArray];
}


-(void) runAnimationForImages:(NSArray*)images fromRects:(NSArray*)sFrames toRects:(NSArray*)eFrames withInfo:(NSArray*)info	{
	NSMutableArray* views = [NSMutableArray array];
	SimpleImageView* v;
	int i;
	for (i = 0; i < [images count]; i++)	{
		v = [[[SimpleImageView alloc] initWithFrame:[[sFrames objectAtIndex:i] rectValue]] autorelease];
		[v setImage:[images objectAtIndex:i]];
		[v setHidden:YES];
		[views addObject:v];
		[animationLayer addSubview:v];
	}
	
	NSMutableArray* vas = [NSMutableArray array];
	NSMutableDictionary* theDict;
	for (i = 0; i < [views count]; i++)	{
		theDict = [NSMutableDictionary dictionaryWithDictionary:[info objectAtIndex:i]];
		[theDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
			[views objectAtIndex:i], NSViewAnimationTargetKey,
			[sFrames objectAtIndex:i], NSViewAnimationStartFrameKey,
			[eFrames objectAtIndex:i], NSViewAnimationEndFrameKey,
			[NSNumber numberWithBool:YES], @"SHOULD_UNHIDE_VIEW", //nil]];
			[NSNumber numberWithBool:YES], @"SHOULD_REMOVE_VIEW",
			nil]];
		[vas addObject:theDict];
			/*
			[[info objectAtIndex:i] objectForKey:@"PLAYER"], @"PLAYER",
			[[info objectAtIndex:i] objectForKey:@"TARGET_FRAME"], @"TARGET_FRAME",
			[[info objectAtIndex:i] objectForKey:@"TYPE"], @"TYPE",
			nil]];*/
	}
	
	NSViewAnimation* ani = [[NSViewAnimation alloc] initWithViewAnimations:vas];
	[ani setDuration:1.2];
	[ani setDelegate:self];
	
//	NSLog(@"adding %@", ani);
	
	[theAnimationChain addObject:ani];
	[self startChainIfNessecary];
}

-(NSViewAnimation*) animationForImages:(NSArray*)images fromRects:(NSArray*)sFrames toRects:(NSArray*)eFrames withInfo:(NSArray*)info	{
	NSMutableArray* views = [NSMutableArray array];
	SimpleImageView* v;
	int i;
	for (i = 0; i < [images count]; i++)	{
		v = [[[SimpleImageView alloc] initWithFrame:[[sFrames objectAtIndex:i] rectValue]] autorelease];
		[v setImage:[images objectAtIndex:i]];
		[v setHidden:YES];
		[views addObject:v];
		[animationLayer addSubview:v];
	}
	
	NSMutableArray* vas = [NSMutableArray array];
	NSMutableDictionary* theDict;
	for (i = 0; i < [views count]; i++)	{
		theDict = [NSMutableDictionary dictionaryWithDictionary:[info objectAtIndex:i]];
		[theDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
			[views objectAtIndex:i], NSViewAnimationTargetKey,
			[sFrames objectAtIndex:i], NSViewAnimationStartFrameKey,
			[eFrames objectAtIndex:i], NSViewAnimationEndFrameKey,
			[NSNumber numberWithBool:YES], @"SHOULD_UNHIDE_VIEW", //nil]];
			[NSNumber numberWithBool:YES], @"SHOULD_REMOVE_VIEW",
			nil]];
		[vas addObject:theDict];
			/*
			[[info objectAtIndex:i] objectForKey:@"PLAYER"], @"PLAYER",
			[[info objectAtIndex:i] objectForKey:@"TARGET_FRAME"], @"TARGET_FRAME",
			[[info objectAtIndex:i] objectForKey:@"TYPE"], @"TYPE",
			nil]];*/
	}
	
	NSViewAnimation* ani = [[[NSViewAnimation alloc] initWithViewAnimations:vas] autorelease];
	return ani;
//	[ani setDuration:1.2];
//	[ani setDelegate:self];
	
//	NSLog(@"adding %@", ani);
	
//	[theAnimationChain addObject:ani];
//	[self startChainIfNessecary];
}



-(void) tradeResources:(NSArray*)resArray fromBankToPlayer:(Player*)p	{
	PP;
//	NSLog(@"resARray = %@", resArray);
//	[[players objectAtIndex:turnIndex] addResource:res];
	NSMutableArray* startRects = [NSMutableArray array];
	NSView* targetView = [self viewForPlayer:p];
	NSArray* targetRects = [targetView reserveFramesForResources:resArray];
	NSMutableArray* endRects = [NSMutableArray array];
	NSMutableArray* info = [NSMutableArray array];
	NSMutableArray* images = [NSMutableArray array];
	NSRect rect;
	int i;
	for (i = 0; i < [resArray count]; i++)	{
		[images addObject:[NSImage imageNamed:[NSString stringWithFormat:@"%@Res", [resArray objectAtIndex:i]]]];
		rect = [bankView rectForResource:[resArray objectAtIndex:i]];
		rect.origin = [[[bankView window] contentView] convertPoint:rect.origin fromView:bankView];
		[startRects addObject:[NSValue valueWithRect:rect]];

		rect = [[targetRects objectAtIndex:i] rectValue];
		rect.origin = [[[targetView window] contentView] convertPoint:rect.origin fromView:targetView];
		[endRects addObject:[NSValue valueWithRect:rect]];
		
		[info addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			p, @"PLAYER",
			[targetRects objectAtIndex:i], @"TARGET_FRAME",
			[resArray objectAtIndex:i], @"TYPE",
			nil]];
	}
	NSViewAnimation* ani = [targetView animationToMakeRoomForNewResourcesOfType:resArray];
	[ani setDelegate:self];
	[theAnimationChain addObject:ani];
	ani = [self animationForImages:images fromRects:startRects toRects:endRects withInfo:info];
	[ani setDuration:0.4];
	[ani setDelegate:self];
	[theAnimationChain addObject:ani];
	[self startChainIfNessecary];
//	[self runAnimationForImages:images fromRects:startRects toRects:endRects withInfo:info];
}
-(void) tradeResources:(NSArray*)resArr toBankFromPlayer:(Player*)p	{
	PP;
}

-(NSArray*) sortResources:(NSArray*)res	{
//	NSLog(@"sorting %@", res);
	NSMutableArray* arr = [NSMutableArray arrayWithArray:res];
	NSArray* base = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	int i, j;
	for (i = 0; i < [arr count]; i++)	{
		if ([base indexOfObject:[arr objectAtIndex:i]] == NSNotFound)	{
			NSLog(@"couldn't find %@", [arr objectAtIndex:i]);
		}
		for (j = i + 1; j < [arr count]; j++)	{
			if ([base indexOfObject:[arr objectAtIndex:j]] < [base indexOfObject:[arr objectAtIndex:i]])
				[arr exchangeObjectAtIndex:i withObjectAtIndex:j];
		}
	}
//	NSLog(@"sorted, %@", arr);
	return [NSArray arrayWithArray:arr];
}

-(void) newdistributeBoardResources:(NSArray*)boardResInfo	{
//	[fadeInAnimation release];
	fadeInAnimation = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
		[NSDictionary dictionaryWithObjectsAndKeys:
			boardShadeView, NSViewAnimationTargetKey, 
			[NSValue valueWithRect:[boardShadeView frame]], NSViewAnimationStartFrameKey,
			[NSValue valueWithRect:[boardShadeView frame]], NSViewAnimationEndFrameKey,
			NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil]]] autorelease];
			
	[fadeInAnimation setDelegate:self];
	[fadeInAnimation setDuration:0.35];
	NSDictionary* dict = [boardResInfo objectAtIndex:0];
	if ([dict objectForKey:@"Tiles"] && [[dict objectForKey:@"Tiles"] count] > 0)	{
		[boardShadeView setImage:[boardView shadeImageForTiles:[dict objectForKey:@"Tiles"]]];
		[fadeInAnimation startAnimation];
	}
			
}

-(BOOL) animationShouldStart:(NSAnimation*)ani	{
//	PP;
	if ([ani isKindOfClass:[NSViewAnimation class]])	{
		NSArray* vas = [(NSViewAnimation*)ani viewAnimations];
		int i;
		for (i = 0; i < [vas count]; i++)	{
			if ([[[vas objectAtIndex:i] objectForKey:@"SHOULD_UNHIDE_VIEW"] boolValue] == YES)	{
//				NSLog(@"unhiding");
				[[[vas objectAtIndex:i] objectForKey:NSViewAnimationTargetKey] setHidden:NO];
			}
		}
	}
	
	return YES;
}
- (BOOL)oldanimationShouldStart:(NSAnimation*)animation	{
	PP;
//	NSLog(@"animation = %@", animation);
	
	BOOL delayFlag = NO;
//	[animation setDuration:4.0];
	if ([animation isKindOfClass:[NSViewAnimation class]])	{
		NSArray* vas = [animation viewAnimations];
		NSDictionary* va;
		int i;
		for (i = 0; i < [vas count]; i++)	{
			va = [vas objectAtIndex:i];
			if ([[va objectForKey:@"SHOULD_ADD_VIEW"] boolValue] == YES)	{
				delayFlag = YES;
			//	[animationLayer addSubview:[va objectForKey:NSViewAnimationTargetKey]];
			}
			
		}
	}

			
//	if (delayFlag)	{
//		[animationLayer display];
//		NSDate* startDate = [NSDate date];
//		while (-[startDate timeIntervalSinceNow] < 2.5)	{
//			NSLog(@"delaying");
//			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
//		}
//	}
	return YES;
}


-(void) animationDidEnd:(NSAnimation*)ani	{
//	PP;
	[self handleEnd:ani];
	int index = [theAnimationChain indexOfObject:ani];
	if (index == NSNotFound)	{
		PP;
		NSLog(@"this should not have happened");
	}
	if (index < [theAnimationChain count] - 1)	{
		[[theAnimationChain objectAtIndex:index + 1] performSelector:@selector(startAnimation) withObject:nil afterDelay:0.01];
	}
	else	{
		//[theAnimationChain release];
		[theAnimationChain removeAllObjects];
		[[GameController gameController] endRoll];
		animatingFlag = NO;
	}
}
-(void) handleEnd:(NSAnimation*)ani	{
//	PP;
//	NSLog(@"animation = %@", ani);
	if (ani == endAni)
		[self runEndGameAnimation];
//	NSLog(@"handling end");
	if ([ani isKindOfClass:[NSViewAnimation class]] || [ani isKindOfClass:[CardFlipAnimation class]])	{
		NSArray* vas = [ani viewAnimations];
//		NSLog(@"vas = %@", vas);
	//	NSMutableArray8 
		int i;
		NSString* res;
		NSRect frame;
		Player* p;
		NSDictionary* va;
		NSView* targetView;
		for (i = 0; i < [vas count]; i++)	{
			va = [vas objectAtIndex:i];
				
			p = [va objectForKey:@"PLAYER"];
			if (p)	{
				res = [va objectForKey:@"TYPE"];
				[p addResourceNotifyingItemTableOnly:res];
				targetView = [self viewForPlayer:p];
				if ([va objectForKey:@"TARGET_FRAME"])	{
					frame = [[va objectForKey:@"TARGET_FRAME"] rectValue];
					[targetView addResource:res inRect:frame];
				
				}
			}
			
//			if ([[va objectForKey:@"EFFECT"] isEqualToString:@"FADE_OUT"])
//				[[[va objectForKey:NSViewAnimationTargetKey
			if ([[va objectForKey:@"SHOULD_REMOVE_VIEW"] boolValue] == YES)
				[[va objectForKey:NSViewAnimationTargetKey] performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2];
				
			if ([va objectForKey:@"CALLBACK_INFO"])	{
				NSDictionary* callback = [va objectForKey:@"CALLBACK_INFO"];
				SEL selector = NSSelectorFromString([callback objectForKey:@"SELECTOR"]);
				[[callback objectForKey:@"TARGET"] performSelector:selector withObject:[callback objectForKey:@"PARAMETER"] afterDelay:0.1];
			
			}
				
		}
	}
	else	{
	//	NSLog(@"didn't get VA's");
	}
	
//	[ani setCurrentProgress:1.5];
}
/*
-(void) distributeBoardResources:(NSArray*)boardResInfo	{
	PP;
	[NSThread detachNewThreadSelector:@selector(distributeBoardResourcesInOtherThread:) toTarget:self withObject:boardResInfo];	
}*/

-(void) distributeBoardResources:(NSDictionary*)boardResInfo	{
//    NSLog(@"%s, %@", __FUNCTION__, boardResInfo);
//	PP;
	int i, j;
	BOOL fade = NO;
//	if ([boardResInfo count] == 0)
//		return;
//	NSDictionary* dict = [boardResInfo objectAtIndex:0];
	NSArray* tiles = [boardResInfo objectForKey:@"Tiles"];
	NSArray* playerInfo = [boardResInfo objectForKey:@"PlayerInfo"];
	if ([playerInfo count] == 0)	{
		[[GameController gameController] endRoll];
		return;
	}
//	if ([dict objectForKey:@"Tiles"] && [[dict objectForKey:@"Tiles"] count] > 0)	{
//		[animationChain addObject:[self fadeInImageAnimation:[boardView shadeImageForTiles:[dict objectForKey:@"Tiles"]]]];
//		fade = YES;
//	}
	NSMutableArray* animationChain = [NSMutableArray array];

	if ([tiles count] > 0)	{
		[animationChain addObject:[self fadeInImageAnimation:[boardView shadeImageForTiles:tiles]]];
		fade = YES;
	}
	Player* p;
	NSArray* resources;
	NSAnimation* ani;
	NSView* targetView;
	NSArray* views;
	NSDictionary* dict;
	NSAnimation* bombardment;
	for (i = 0; i < [playerInfo count]; i++)	{
		dict = [playerInfo objectAtIndex:i];
		p = [dict objectForKey:@"Player"];
		resources = [dict objectForKey:@"Resources"];
		[p incrementEarnedResources:[resources count]];
		resources = [self sortResources:resources];
		
		ani = [self animationForResourcesFromBankToCenter:resources];
		bombardment = ani;
//		NSLog(@"got animation to middle");
		[ani setDuration:0.5];
		[animationChain addObject:ani];
		views = [self viewsForAnimation:ani];
		if (DEBUG_MODE == 0)	{
			for (j = 0; j < [views count]; j++)	{
				[[views objectAtIndex:j] setHidden:YES];
				[animationLayer addSubview:[views objectAtIndex:j]];
			}
		}
		ani = [self fillerAnimationWithDuration:0.65];
		[animationChain addObject:ani];
//		NSLog(@"got filler");
		targetView = [self viewForPlayer:p];
		ani = [targetView animationToMakeRoomForNewResourcesOfType:resources];
		[ani setDuration:0.2];
		[animationChain addObject:ani];
//		NSLog(@"got make room");
		ani = [self animationForViews:views types:resources fromCenterToPlayer:p];
		if (DEBUG_MODE == 1)
			[self handleEnd:ani];
		[ani setDuration:0.25];
		[animationChain addObject:ani];
//		NSLog(@"got last");
		//[animationChain addObject:[self 
	}
	
	if (fade)	{
		[animationChain addObject:[self fadeOutAnimation]];
//		NSLog(@"added fade out");
	}	
	
	for (i = 0; i < [animationChain count]; i++)	{
//		[[animationChain objectAtIndex:i] startWhenAnimation:[animationChain objectAtIndex:i - 1] reachesProgress:1.2];
		[[animationChain objectAtIndex:i] setDelegate:self];
	}
	
//	theAnimationChain = [NSArray arrayWithArray:animationChain];
//	[theAnimationChain retain];
	[theAnimationChain addObjectsFromArray:animationChain];
//	[[animationChain objectAtIndex:0] setDelegate:self];
	[animationLayer setNeedsDisplay:YES];
	if (DEBUG_MODE == 0)	{
		[self startChainIfNessecary];
		//[[animationChain objectAtIndex:0] performSelector:@selector(startAnimation) withObject:nil afterDelay:0.2];
	}
	else	{
		[self animationDidEnd:[theAnimationChain objectAtIndex:[theAnimationChain count] - 1]];
	}
//	[bombardment setDuration:4.0];
//	[bombardment startAnimation];
	
}

-(void) startChainIfNessecary	{
	if (animatingFlag == NO)	{
		animatingFlag = YES;
//		NSLog(@"starting animation");
		[[theAnimationChain objectAtIndex:0] performSelector:@selector(startAnimation) withObject:nil afterDelay:0.1];
	}
}

-(void) olddistributeBoardResources:(NSArray*)boardResInfo	{
//	NSAutoreleasePool* threadPool = [[NSAutoreleasePool alloc] init];
	PP;
//	NSLog(@"distributing %@", boardResInfo);
	NSMutableArray* cardAnimations = [NSMutableArray array];
	int i, j;
	NSDictionary* aniDict;
	NSDictionary* dict;
	Player* p;
	NSArray* resources;
//	NSArray* points;
	
	NSRect sRect;
	NSRect eRect;
//	NSPoint center;
//	float duration = 0.5;
//	NSDictionary* callbackDict;
	NSString* res;
	NSImage* image;
	NSMutableArray* theArray;// = [NSMutableArray array];
	NSMutableArray* endRects;
//	NSRect tmp;
	for (i = 0; i < [boardResInfo count]; i++)	{
		dict = [boardResInfo objectAtIndex:i];
		p = [dict objectForKey:@"Player"];
		resources = [dict objectForKey:@"Resources"];
		resources = [self sortResources:resources];
//		points = [dict objectForKey:@"Origins"];
//		[boardView shadeAllTilesExcept:[dict objectForKey:@"Tiles"]];
		if ([dict objectForKey:@"Tiles"] && [[dict objectForKey:@"Tiles"] count] > 0)	{
//			NSLog(@"going to shade tiles on boardView = %@", boardView);
			NSViewAnimation* fin = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
				[NSDictionary dictionaryWithObjectsAndKeys:
					boardShadeView, NSViewAnimationTargetKey,
					[NSValue valueWithRect:[boardShadeView frame]], NSViewAnimationStartFrameKey,
					NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil]]];
			[boardShadeView setImage:[boardView shadeImageForTiles:[dict objectForKey:@"Tiles"]]];
		//	[boardShadeView performSelectorOnMainThread:@selector(setImage:) withObject:[boardView shadeImageForTiles:[dict objectForKey:@"Tiles"]] waitUntilDone:NO];
			[fin setDuration:0.35];
			[fin startAnimation];
			while ([fin isAnimating])	{
//				NSLog(@"blocking");
//				[[NSRunLoop currentRunLoop] runMode:@"CATAN_ANIMATION_MODE" beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
			}
//			fadeInAnimation = [self fadeInImageAnimation:[boardView shadeImageForTiles:[dict objectForKey:@"Tiles"]]];
	//		[animationThread fadeImageIn:[boardView shadeImageForTiles:[dict objectForKey:@"Tiles"]]];
		}

		theArray = [NSMutableArray array];
//		float delay = [localResView makeRoomForResourcesOfType:resources];
//		NSDate* lkhsdg = [NSDate date];
//		NSDate* lkhdfhds = [NSDate dateWithTimeIntervalSinceNow:delay];
//		while (-[lkhsdg timeIntervalSinceNow] <= delay)	{
//		while ([localResView animating])
//			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:lkhdfhds];
		endRects = [localResView reserveFramesForResources:resources];
//		endRects = [NSMutableArray array];
//		callbackDict = [NSDictionary dictionaryWithObjectsAndKeys:p, @"Player", res, @"Resource", nil];
		
		for (j = 0; j < [resources count]; j++)	{
//			NSLog(@"endRect %d = %@", j, NSStringFromRect([[endRects objectAtIndex:j] rectValue]));
			res = [resources objectAtIndex:j];
//			center = [[points objectAtIndex:j] pointValue];
//			center = [[[boardView window] contentView] convertPoint:center fromView:boardView];
			//sRect = NSMakeRect(center.x, center.y, 0, 0);
			sRect = [bankView rectForResource:[resources objectAtIndex:j]];
			sRect.origin = [[[bankView window] contentView] convertPoint:sRect.origin fromView:bankView];
			eRect = [[endRects objectAtIndex:j] rectValue];
			eRect.origin = [[[localResView window] contentView] convertPoint:eRect.origin fromView:localResView];
//			eRect = [self rectForPlayer:p resource:res];
//			tmp = eRect;
//			tmp.origin = [localResView convertPoint:tmp.origin fromView:[[localResView window] contentView]];
//			[endRects addObject:[NSValue valueWithRect:tmp]];

//			image = [[NSImage imageNamed:[NSString stringWithFormat:@"%@Res.tiff", res]] autorelease];
			image = [NSImage imageNamed:[NSString stringWithFormat:@"%@Res", res]];

			aniDict = [NSDictionary dictionaryWithObjectsAndKeys:
				image, @"Image", 
				[NSValue valueWithRect:sRect], @"StartFrame", 
				[NSValue valueWithRect:eRect], @"EndFrame", 
				nil];
			[theArray addObject:aniDict];
		}
//		[theArray 
		if ([theArray count] > 0)	{
			aniDict = [theArray objectAtIndex:0];
			NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithDictionary:aniDict];
//			[newDict setObject:self forKey:@"Object"];
//			[newDict setObject:NSStringFromSelector(@selector(animationFinished:)) forKey:@"Selector"];
			NSDictionary* paramDict = [NSDictionary dictionaryWithObjectsAndKeys:
				p, @"Player", resources, @"Resources", endRects, @"TargetFrames",  nil];
			[newDict setObject:
				[NSDictionary dictionaryWithObjectsAndKeys:
					self, @"Object",
					NSStringFromSelector(@selector(animationFinished:)), @"Selector",
					paramDict, @"Parameter", nil]
				forKey:@"CallbackInfo"];
		
			[theArray replaceObjectAtIndex:0 withObject:newDict];
		
			if (SHOULD_ANIMATE)	{
				//[cardAnimations addObject:theArray];
				//[animationThread startAnimations:theArray];
				[animationLayer startAnimations:theArray];
//				[animationLayer performSelector:@selector(startAnimations:) withObject:theArray afterDelay:delay];
			}
			else	{
				[self animationFinished:paramDict];
			}

		}
		
	}
	
//	[threadPool release];
//	fadeInAnimation = [self fadeInImageAnimation:[];
//	[fadeInAnimation startAnimation];
}


-(NSAnimation*) fadeOutAnimation	{
	NSViewAnimation* ani = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
		[NSDictionary dictionaryWithObjectsAndKeys:
			boardShadeView, NSViewAnimationTargetKey,
			[NSValue valueWithRect:[boardShadeView frame]], NSViewAnimationStartFrameKey,
			@"FADE_OUT", @"EFECT",
			[NSNumber numberWithBool:YES], @"SHOULD_HIDE_VIEW",
//			NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, 
			nil]]];
	int i;
	for (i = 0; i < 21; i++)	{
		[ani addProgressMark:i / 21.0];
	}
	[ani setDuration:0.35];
	return ani;
}

- (void)animation:(NSAnimation*)animation didReachProgressMark:(NSAnimationProgress)progress	{
	NSString* effect = [[[animation viewAnimations] objectAtIndex:0] objectForKey:@"EFFECT"];
	float opacity;
	if ([effect isEqualToString:@"FADE_IN"])
		opacity = progress;
	else
		opacity = 1.0 - progress;
		
	[boardShadeView setAlphaValue:opacity];
}

-(NSAnimation*) fadeInImageAnimation:(NSImage*)image	{
	[boardShadeView setImage:image];
	NSViewAnimation* ani = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
		[NSDictionary dictionaryWithObjectsAndKeys:
			boardShadeView, NSViewAnimationTargetKey,
			[NSValue valueWithRect:[boardShadeView frame]], NSViewAnimationStartFrameKey,
			[NSNumber numberWithBool:YES], @"SHOULD_UNHIDE_VIEW",
			@"FADE_IN", @"EFFECT",
//			NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, 
			nil]]];
	int i;
	for (i = 0; i < 21; i++)	{
		[ani addProgressMark:i / 21.0];
	}
	[ani setDuration:0.35];
	return ani;
}

-(PlayerView*) realViewForPlayer:(Player*)p	{
	int i;
	for (i = 0; i < [playerViews count]; i++)	{
		if ([[playerViews objectAtIndex:i] player] == p)
			return [playerViews objectAtIndex:i];
	}

}	

-(NSView*) viewForPlayer:(Player*)p	{
	int i;
	if (p == [[GameController gameController] localPlayer])
		return localResView;
	for (i = 0; i < [playerViews count]; i++)	{
		if ([[playerViews objectAtIndex:i] player] == p)
			return [playerViews objectAtIndex:i];
	}
	
	
	NSLog(@"THIS SHOULD NOT HAVE HAPPENED");
	PP;
	return nil;
}

-(NSRect) rectForPlayer:(Player*)p resource:(NSString*)res	{
	NSView* view = nil;
	NSRect rect;
	if (p == [[GameController gameController] localPlayer])	{
		view = localResView;
		rect = [localResView frameForNewResourceOfType:res];
	}
	else	{
		int i;
		for (i = 0; i < [playerViews count]; i++)	{
			if ([[playerViews objectAtIndex:i] player] == p)	{
				view = [playerViews objectAtIndex:i];
				rect = [[playerViews objectAtIndex:i] bounds];
			}
		}
	}

	if (view == nil)	{
		NSLog(@"view = nil, this shouldn't have happened");
		return NSMakeRect(0, 0, 100, 100);
	}
	else
		rect.origin = [[[view window] contentView] convertPoint:rect.origin fromView:view];
	
	return rect;
}

-(float) delayMiddleAnimation:(NSDictionary*)dict	{
	Player* p = [dict objectForKey:@"Player"];
	NSArray* resArr = [dict objectForKey:@"Resources"];
	
	if (p == [[GameController gameController] localPlayer])	{
		return [localResView makeRoomForResourcesOfType:resArr];
	}
	
	return 0;
}


-(void) animationFinished:(NSDictionary*)dict	{
	PP;
	//NSLog(@"callback was called");
	Player* p = [dict objectForKey:@"Player"];
	NSArray* frameArr = [dict objectForKey:@"TargetFrames"];
	NSArray* resArr = [dict objectForKey:@"Resources"];
//	NSLog(@"player = %@, resArr = %@", p, resArr);
	NSString* res;
	int i;
	for (i = 0; i < [resArr count]; i++)	{
		res = [resArr objectAtIndex:i];
		[localResView addResource:res inRect:[[frameArr objectAtIndex:i] rectValue]];
		[p addResourceNotifyingItemTableOnly:res];
	}
	NSViewAnimation* fout = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
		[NSDictionary dictionaryWithObjectsAndKeys:
			boardShadeView, NSViewAnimationTargetKey,
			[NSValue valueWithRect:[boardShadeView frame]], NSViewAnimationStartFrameKey,
			NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil]]] autorelease];
//	[fout setDuration:2.5];
	[fout setDuration:0.35];
	[fout performSelector:@selector(startAnimation) withObject:nil afterDelay:0.01];
//	[fout startAnimation];
//	while ([fout isAnimating])
//		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
//	[boardView unshadeAllTiles];
//	[fout release];
}


/*
-(NSAnimation*) animationForInfo:(NSDictionary*)dict	{
	int i;
	NSArray* resources = [dict objectForKey:@"Resources"];
	NSArray* endRects;
	if ([dict objectForKey:@"Player"] == [[GameController gameController] localPlayer])
		endRects = [localResView reserveFramesForResources:resources];
	else	{
		for (i = 0; i < [resources count]; i++)	{
			
		}
	}
	NSMutableArray* midRects = [animatedCardView middleRectsForResources:resources];
	for (i = 0; i < [resources count]; i++)	{
		res = [resources objectAtIndex:i];
		sRect = [bankView rectForResource:[resources objectAtIndex:i]];
		sRect.origin = [[[bankView window] contentView] convertPoint:sRect.origin fromView:bankView];
			
		eRect = [[endRects objectAtIndex:j] rectValue];
		eRect.origin = [[[localResView window] contentView] convertPoint:eRect.origin fromView:localResView];
//			eRect = [self rectForPlayer:p resource:res];
//			tmp = eRect;
//			tmp.origin = [localResView convertPoint:tmp.origin fromView:[[localResView window] contentView]];
//			[endRects addObject:[NSValue valueWithRect:tmp]];

//			image = [[NSImage imageNamed:[NSString stringWithFormat:@"%@Res.tiff", res]] autorelease];
			image = [NSImage imageNamed:[NSString stringWithFormat:@"%@Res.tiff", res]];

			aniDict = [NSDictionary dictionaryWithObjectsAndKeys:
				image, @"Image", 
				[NSValue valueWithRect:sRect], @"StartFrame", 
				[NSValue valueWithRect:eRect], @"EndFrame", 
				nil];
			[theArray addObject:aniDict];
		}

}

*/


-(NSImage*) shadowedImageForResource:(NSString*)res	{
	NSImage* base = [NSImage imageNamed:[NSString stringWithFormat:@"%@Res", res]];
	NSSize sz = [base size];
//	NSShadow* shadow = [[[NSShadow alloc] init] autorelease];
//	[shadow setShadowOffset:NSMakeSize(10, -10)];
//	[shadow setShadowBlurRadius:3.0];
//	[shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.6]];
	NSShadow* shadow = [NSShadow standardShadow];
	NSImage* newImage = [[[NSImage alloc] initWithSize:NSMakeSize(sz.width + 10, sz.height + 10)] autorelease];
	[newImage lockFocus];
//	[[NSColor whiteColor] set];
//	[NSBezierPath fillRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height)];
	[shadow set];
	[base compositeToPoint:NSMakePoint(0, 10) operation:NSCompositeSourceOver];
	[newImage unlockFocus];
//	[[newImage TIFFRepresentation] 
	return newImage;
}

-(NSAnimation*) animationForResourcesFromBankToCenter:(NSArray*)resArr	{
	int i;
	resArr = [self sortResources:resArr];
	NSMutableArray* startRects = [NSMutableArray array];
	NSRect rect;
	for (i = 0; i < [resArr count]; i++)	{
		rect = [bankView rectForResource:[resArr objectAtIndex:i]];
		rect.origin = [[[bankView window] contentView] convertPoint:rect.origin fromView:bankView];
		[startRects addObject:[NSValue valueWithRect:rect]];
	}
	NSMutableArray* endRects = [animationLayer middleRectsForResources:resArr];
	NSMutableArray* vas = [NSMutableArray array];
	SimpleImageView* imageView;
	for (i = 0; i < [resArr count]; i++)	{
		imageView = [[[SimpleImageView alloc] initWithFrame:[[startRects objectAtIndex:i] rectValue]] autorelease];
//		[imageView setImage:[NSImage imageNamed:[NSString stringWithFormat:@"%@Res.tiff", [resArr objectAtIndex:i]]]];
		[imageView setImage:[self shadowedImageForResource:[resArr objectAtIndex:i]]];
		[vas addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			imageView, NSViewAnimationTargetKey,
			[startRects objectAtIndex:i], NSViewAnimationStartFrameKey,
			[endRects objectAtIndex:i], NSViewAnimationEndFrameKey, 
			[NSNumber numberWithBool:YES], @"SHOULD_UNHIDE_VIEW", nil]];
	}
	
	NSViewAnimation* ani = [[[NSViewAnimation alloc] initWithViewAnimations:vas] autorelease];
	return ani;
}

-(NSArray*) viewsForAnimation:(NSViewAnimation*)animation	{
	NSMutableArray* array = [NSMutableArray array];
	NSArray* vas = [animation viewAnimations];
	int i;
	for (i = 0; i < [vas count]; i++)	{
		[array addObject:[[vas objectAtIndex:i] objectForKey:NSViewAnimationTargetKey]];
	}
	return array;
}

-(NSAnimation*) fillerAnimationWithDuration:(float)f	{
	NSAnimation* ani = [[[NSAnimation alloc] init] autorelease];
	[ani setDuration:f];
	
	return ani;
}

-(NSAnimation*) animationForViews:(NSArray*)views types:(NSArray*)types fromCenterToPlayer:(Player*)p	{
	NSArray* startFrames = [animationLayer middleRectsForResources:views];
	int i;
	NSView* theResourceView;
	if (p == [[GameController gameController] localPlayer])
		theResourceView = localResView;
	else
		theResourceView = [self viewForPlayer:p];
		

	NSArray* targetFrames = [theResourceView reserveFramesForResources:types];
	NSMutableArray* endFrames = [NSMutableArray arrayWithArray:targetFrames];
	NSRect eRect;
	for (i = 0; i < [endFrames count]; i++)	{
		eRect = [[endFrames objectAtIndex:i] rectValue];
		eRect.origin = [[[theResourceView window] contentView] convertPoint:eRect.origin fromView:theResourceView];
		[endFrames replaceObjectAtIndex:i withObject:[NSValue valueWithRect:eRect]];
	}
	
	NSMutableArray* vas = [NSMutableArray array];
	
	for (i = 0; i < [views count]; i++)	{
		[vas addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			[views objectAtIndex:i], NSViewAnimationTargetKey,
			[startFrames objectAtIndex:i], NSViewAnimationStartFrameKey,
			[endFrames objectAtIndex:i], NSViewAnimationEndFrameKey,
			[targetFrames objectAtIndex:i], @"TARGET_FRAME",
			[types objectAtIndex:i], @"TYPE",
			p, @"PLAYER",
			[NSNumber numberWithBool:YES], @"SHOULD_REMOVE_VIEW",
			 nil]];
	}
	
	NSViewAnimation* ani = [[[NSViewAnimation alloc] initWithViewAnimations:vas] autorelease];
	return ani;
}



-(NSViewAnimation*) expandingAnimationForEdge:(Edge*)e	{
	NSRect frame = [e imageRect];
	NSRect bigFrame = frame;
	frame.origin = [[[boardView window] contentView] convertPoint:frame.origin fromView:boardView];
	bigFrame.size.width += (0.5 * frame.size.width);
	bigFrame.size.height += (0.5 * frame.size.height);
	SimpleImageView* view = [[[SimpleImageView alloc] initWithFrame:frame] autorelease];
}
-(void) oldanimateLongRoad:(NSArray*)road	{
	int i;
	Edge* roadPiece;
	SimpleImageView* view;
	NSViewAnimation* ani;
	NSMutableArray* chain = [NSMutableArray array];
	NSRect frame;
	NSRect bigFrame;
	NSMutableArray* views = [NSMutableArray array];
	for (i = 0; i < [road count]; i++)	{
		roadPiece = [road objectAtIndex:i];
		frame = [roadPiece imageRect];
		frame.origin = [[[boardView window] contentView] convertPoint:frame.origin fromView:boardView];
		view = [[[SimpleImageView alloc] initWithFrame:frame] autorelease];
		[view setImage:[[roadPiece item] image]];
		if ([[animationLayer subviews] count] > 0)
			[animationLayer addSubview:view positioned:NSWindowBelow relativeTo:[[animationLayer subviews] objectAtIndex:0]];
		else
			[animationLayer addSubview:view];

//		[animationLayer addSubview:view];
	}
	
	NSView* prevView;
	
	view = [views objectAtIndex:i];
	frame = [view frame];
	bigFrame = frame;
	bigFrame.size.height += (0.75 * bigFrame.size.height);
	bigFrame.size.width += (0.75 * bigFrame.size.width);
	bigFrame.origin.x -= (bigFrame.size.width - frame.size.width) / 2;
	bigFrame.origin.y -= (bigFrame.size.height - frame.size.height) / 2;
	ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
		[NSDictionary dictionaryWithObjectsAndKeys:
			view, NSViewAnimationTargetKey,
			[NSValue valueWithRect:frame], NSViewAnimationStartFrameKey,
			[NSValue valueWithRect:bigFrame], NSViewAnimationEndFrameKey,
			nil]]] autorelease];
	[ani setDuration:0.2];
	[ani setDelegate:self];
	[chain addObject:ani];

	for (i = 1; i < [views count]; i++)	{
		prevView = [views objectAtIndex:i - 1];
		view = [views objectAtIndex:i];
		frame = [view frame];
		bigFrame = frame;
		bigFrame.size.height += (0.75 * bigFrame.size.height);
		bigFrame.size.width += (0.75 * bigFrame.size.width);
		bigFrame.origin.x -= (bigFrame.size.width - frame.size.width) / 2;
		bigFrame.origin.y -= (bigFrame.size.height - frame.size.height) / 2;
		ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
			[NSDictionary dictionaryWithObjectsAndKeys:
				view, NSViewAnimationTargetKey,
				[NSValue valueWithRect:frame], NSViewAnimationStartFrameKey,
				[NSValue valueWithRect:bigFrame], NSViewAnimationEndFrameKey,
				nil]]] autorelease];
		[ani setDuration:0.2];
		[ani setDelegate:self];
		[chain addObject:ani];
		
		ani = [self fillerAnimationWithDuration:0.15];
		[ani setDelegate:self];
		[chain addObject:ani];
		
		ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
			[NSDictionary dictionaryWithObjectsAndKeys:
				view, NSViewAnimationTargetKey,
				[NSValue valueWithRect:bigFrame], NSViewAnimationStartFrameKey,
				[NSValue valueWithRect:frame], NSViewAnimationEndFrameKey,
				[NSNumber numberWithBool:YES], @"SHOULD_REMOVE_VIEW",
				nil]]] autorelease];
		[ani setDuration:0.2];
		[ani setDelegate:self];

		[chain addObject:ani];
		
	}
	
	[theAnimationChain addObjectsFromArray:chain];
	[self startChainIfNessecary];
}

//-(NSView*) view


-(NSAnimation*) pulseAnimationForViews:(NSArray*)views pulseFactor:(float)factor removeViews:(BOOL)flag	{
	if ([views count] <= 0)
		return nil;
	
	int i;
	NSMutableArray* vas = [NSMutableArray array];
	NSMutableDictionary* dict;
	NSMutableArray* arr;
	NSRect frame;
	NSRect bigFrame;
	NSView* view;

	NSString* hideKey;
	if (flag)
		hideKey = @"SHOULD_REMOVE_VIEW";
	else
		hideKey = @"SHOULD_HIDE_VIEW";
	frame = [[views objectAtIndex:0] frame];
	bigFrame = [self scaledRectWithRect:frame factor:factor];

	dict = [NSDictionary dictionaryWithObjectsAndKeys:
		[views objectAtIndex:0], NSViewAnimationTargetKey,
		[NSValue valueWithRect:frame], NSViewAnimationStartFrameKey,
		[NSValue valueWithRect:bigFrame], NSViewAnimationEndFrameKey, 
//		[NSNumber numberWithBool:YES], hideKey,
		[NSNumber numberWithBool:YES], @"SHOULD_UNHIDE_VIEW",
		nil];
	[vas addObject:[NSArray arrayWithObject:dict]];
//	int j;
	for (i = 1; i < [views count]; i++)		{
//		for (j = 0; j 
		arr = [NSMutableArray array];
		view = [views objectAtIndex:i - 1];
		frame = [view frame];
		bigFrame = [self scaledRectWithRect:frame factor:factor];
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
			view, NSViewAnimationTargetKey,
			[NSValue valueWithRect:bigFrame], NSViewAnimationStartFrameKey,
			[NSValue valueWithRect:frame], NSViewAnimationEndFrameKey,
			[NSNumber numberWithBool:YES], hideKey,
			nil];
		[arr addObject:dict];
		
		view = [views objectAtIndex:i];
		frame = [view frame];
		bigFrame = [self scaledRectWithRect:frame factor:factor];
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
			view, NSViewAnimationTargetKey,
			[NSValue valueWithRect:frame], NSViewAnimationStartFrameKey,
			[NSValue valueWithRect:bigFrame], NSViewAnimationEndFrameKey,
			[NSNumber numberWithBool:YES], @"SHOULD_UNHIDE_VIEW",
			nil];
		[arr addObject:dict];
		
		[vas addObject:arr];
	}
	
	view = [views objectAtIndex:[views count] - 1];
	frame = [view frame];
	bigFrame = [self scaledRectWithRect:frame factor:factor];
	dict = [NSDictionary dictionaryWithObjectsAndKeys:
			view, NSViewAnimationTargetKey,
			[NSValue valueWithRect:frame], NSViewAnimationEndFrameKey,
			[NSValue valueWithRect:bigFrame], NSViewAnimationStartFrameKey,
			[NSNumber numberWithBool:YES], hideKey,
			nil];
			
	[vas addObject:[NSArray arrayWithObject:dict]];
	
	return [[[ViewAnimationChain alloc] initWithChainArray:vas] autorelease];
}

/*
	
*/

-(NSRect) scaledRectWithRect:(NSRect)rect factor:(float)factor	{
	NSRect bigRect = rect;
	NSPoint center = NSMakePoint(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
	bigRect.origin.x = center.x - (factor * rect.size.width / 2);
	bigRect.origin.y = center.y - (factor * rect.size.height / 2);
//	bigRect.origin.x -= (factor * rect.size.width) / 2;
//	bigRect.origin.y -= (factor * rect.size.height) / 2;
	
	bigRect.size.width = factor * rect.size.width;
	bigRect.size.height = factor * rect.size.height;
	
	return bigRect;
}
-(void) runEndGameAnimation	{

	Player*  winner = [[GameController gameController] winner];
	Player* local = [[GameController gameController] localPlayer];
	
	
	if (local == winner && confettiView == nil)	{
		NSRect confettiFrame = [animationLayer bounds];
		NSPoint bottom = [[[boardView window] contentView] convertPoint:[boardView bounds].origin fromView:boardView];
		confettiFrame.size.height -= bottom.y;
		confettiFrame.origin.y = bottom.y;
		confettiView = [[[ConfettiView alloc] initWithFrame:confettiFrame] autorelease];
		[confettiView setFrameReferenceView:boardView];
		[animationLayer addSubview:confettiView];
		
		
	}
	
	NSMutableArray* wVerts = [NSMutableArray array];
	NSArray* setts = [winner settlements];
	int i;
	for (i = 0; i < [setts count]; i++)	{
		if ([wVerts indexOfObject:[setts objectAtIndex:i]] == NSNotFound)
			[wVerts addObject:[setts objectAtIndex:i]];
	}
	NSMutableArray* views = [NSMutableArray array];
	NSView* view;
//	int i;
//	NSLog(@"wVerts count = %d", [wVerts count]);
	for (i = 0; i < [wVerts count]; i++)	{
		view = [self viewForTokens:[NSArray arrayWithObject:[wVerts objectAtIndex:i]]];	
		[view setHidden:YES];
		[animationLayer addSubview:view];
		[views addObject:view];
	}
	if ([[GameController gameController] playerHasLongestRoad:winner])	{
		view = [self viewForTokens:[[GameController gameController] longestRoad]];
		[view setHidden:YES];
		[animationLayer addSubview:view];
		[views addObject:view];
	}
	
	ViewAnimationChain* chain = [self pulseAnimationForViews:views pulseFactor:2.0 removeViews:YES];
	[chain setDuration:4.0];
	[chain setDelegate:self];
	endAni = chain;
	[theAnimationChain addObject:chain];
	[self startChainIfNessecary];
	
//	for (i = 0; i < 10; i++)	{
//		[self runPulseAnimation:wVerts];
//	}
//	[self 
	
}

-(NSView*) viewForTokens:(NSArray*)tokens	{
	int i;
//	NSLog(@"getting view for");
	if ([tokens count] <= 0)
		return [[[NSView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)] autorelease];
		
	NSRect frame = NSMakeRect(0, 0, 0, 0);//[[tokens objectAtIndex:0] imageRect];
	BoardObject* bObj;
	for (i = 0; i < [tokens count]; i++)	{
		bObj = [tokens objectAtIndex:i];
		frame = NSUnionRect(frame, [bObj imageRect]);
	}
	
//	NSImage* image = [[[NSImage alloc] initWithSize:frame.size] autorelease];
	NSPoint pt = [[[boardView window] contentView] convertPoint:frame.origin fromView:boardView];
//	frame.origin = [[[boardView window] contentView] convertPoint:frame.origin fromView:boardView];

	ProperResizeView* theView = [[[ProperResizeView alloc] initWithFrame:NSMakeRect(pt.x, pt.y, frame.size.width, frame.size.height)] autorelease];
	SimpleImageView* aView;
	NSImage* img;
	NSRect rect;
//	[image lockFocus];
	for (i = 0; i < [tokens count]; i++)	{
		bObj = [tokens objectAtIndex:i];
		img = [[bObj item] image];
		rect = [bObj imageRect];
		rect.origin.x -= frame.origin.x;
		rect.origin.y -= frame.origin.y;
		aView = [[[SimpleImageView alloc] initWithFrame:rect] autorelease];
		[aView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];// | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
		[aView setImage:img];
		[theView addSubview:aView];
//		[img drawInRect:rect fromRect:NSMakeRect(0, 0, [img size].width, [img size].height) operation:NSCompositeSourceOver fraction:1.0];
	}
	[theView setAutoresizesSubviews:YES];
	return theView;
//	[image unlockFocus];

//	SimpleImageView* siv = [[[SimpleImageView alloc] initWithFrame:frame] autorelease];
//	if ([tokens count] == 1)
//		image = [[[tokens objectAtIndex:0] item] image];
//	[siv setImage:image];
	
//	return siv;
}

-(void) animateLongRoad:(NSArray*) roadPieces	{
	NSMutableArray* views = [NSMutableArray array];
	NSView* view;
	int i;
	for (i = 0; i < [roadPieces count]; i++)	{
		view = [self viewForTokens:[NSArray arrayWithObject:[roadPieces objectAtIndex:i]]];
		[view setHidden:YES];
		[animationLayer addSubview:view];
		[views addObject:view];
	}
	
//	NSLog(@"getting chain");
	ViewAnimationChain* chain = [self pulseAnimationForViews:views pulseFactor:2.0 removeViews:YES];
	[chain setDelegate:self];
	[chain setDuration:2.0];
//	NSLog(@"got chain");
	[theAnimationChain addObject:chain];
	
	[self startChainIfNessecary];
}

-(void) otherAnimateLongRoad:(NSArray*)roadPieces	{
	float duration = 1.5 / [roadPieces count];
//	float duration = 0.21;
	NSMutableArray* views = [NSMutableArray array];
	
	Edge* roadPiece;
	NSRect frame;
	int i;
	SimpleImageView* view;
	for (i = 0; i < [roadPieces count]; i++)	{
		roadPiece = [roadPieces objectAtIndex:i];
		frame = [roadPiece imageRect];
		frame.origin = [[[boardView window] contentView] convertPoint:frame.origin fromView:boardView];
		view = [[[SimpleImageView alloc] initWithFrame:frame] autorelease];
		[view setImage:[[roadPiece item] image]];
		
		[views addObject:view];
		[view setHidden:YES];
		if ([[animationLayer subviews] count] > 0)
			[animationLayer addSubview:view positioned:NSWindowBelow relativeTo:[[animationLayer subviews] objectAtIndex:0]];
		else
			[animationLayer addSubview:view];
	}
	
	if ([views count] <= 0)
		return;
	NSViewAnimation* ani;
	SimpleImageView* prevView;
	view = [views objectAtIndex:0];
	frame = [view frame];
	NSRect bigFrame = [self largeFrameForPulsating:frame];
	NSMutableArray* chain = [NSMutableArray array];
	NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryForMovingView:view fromFrame:frame toFrame:bigFrame]];
	[newDict setObject:[NSNumber numberWithBool:YES] forKey:@"SHOULD_UNHIDE_VIEW"];
//	ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
//		[self dictionaryForMovingView:view fromFrame:frame toFrame:bigFrame]]] autorelease];
	ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
		newDict]] autorelease];
		
	[ani setDelegate:self];
	[ani setDuration:duration];
	[chain addObject:ani];
	NSMutableDictionary* oldDict;
//	NSMutableDictionary* newDict;

	for (i = 1; i < [views count]; i++)	{
		prevView = [views objectAtIndex:i - 1];
		oldDict = [NSMutableDictionary dictionaryWithDictionary:
			[self dictionaryForMovingView:prevView fromFrame:[self largeFrameForPulsating:[prevView frame]] toFrame:[prevView frame]]];
		
		[oldDict setObject:[NSNumber numberWithBool:YES] forKey:@"SHOULD_REMOVE_VIEW"];
		view = [views objectAtIndex:i];
		newDict = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryForMovingView:view fromFrame:[view frame] toFrame:[self largeFrameForPulsating:[view frame]]]];
		[newDict setObject:[NSNumber numberWithBool:YES] forKey:@"SHOULD_UNHIDE_VIEW"];
		ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:
			newDict, oldDict, nil]] autorelease];
		[ani setDelegate:self];
		[ani setDuration:duration];
		[chain addObject:ani];
	}

	view = [views objectAtIndex:[views count] - 1];
	oldDict = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryForMovingView:view fromFrame:[self largeFrameForPulsating:[view frame]] toFrame:[view frame]]];
	[oldDict setObject:[NSNumber numberWithBool:YES] forKey:@"SHOULD_REMOVE_VIEW"];
	ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:oldDict]] autorelease];
	[ani setDelegate:self];
	[ani setDuration:duration];
	
	[chain addObject:ani];
	
	[theAnimationChain addObjectsFromArray:chain];
	
	[self startChainIfNessecary];
}


-(void) runPulseAnimation:(NSArray*)boardObjects	{
	float duration = 1.5 / [boardObjects count];
//	float duration = 0.21;
	NSMutableArray* views = [NSMutableArray array];
	
	BoardObject* piece;
	NSRect frame;
	int i;
	SimpleImageView* view;
	for (i = 0; i < [boardObjects count]; i++)	{
		piece = [boardObjects objectAtIndex:i];
		frame = [piece imageRect];
		frame.origin = [[[boardView window] contentView] convertPoint:frame.origin fromView:boardView];
		view = [[[SimpleImageView alloc] initWithFrame:frame] autorelease];
		[view setImage:[[piece item] image]];
		
		[views addObject:view];
		[view setHidden:YES];
		if ([[animationLayer subviews] count] > 0)
			[animationLayer addSubview:view positioned:NSWindowBelow relativeTo:[[animationLayer subviews] objectAtIndex:0]];
		else
			[animationLayer addSubview:view];
	}
	
	if ([views count] <= 0)
		return;
	NSViewAnimation* ani;
	SimpleImageView* prevView;
	view = [views objectAtIndex:0];
	frame = [view frame];
	NSRect bigFrame = [self largeFrameForPulsating:frame];
	NSMutableArray* chain = [NSMutableArray array];
	NSMutableDictionary* newDict = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryForMovingView:view fromFrame:frame toFrame:bigFrame]];
	[newDict setObject:[NSNumber numberWithBool:YES] forKey:@"SHOULD_UNHIDE_VIEW"];
//	ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
//		[self dictionaryForMovingView:view fromFrame:frame toFrame:bigFrame]]] autorelease];
	ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
		newDict]] autorelease];
		
	[ani setDelegate:self];
	[ani setDuration:duration];
	[chain addObject:ani];
	NSMutableDictionary* oldDict;
//	NSMutableDictionary* newDict;

	for (i = 1; i < [views count]; i++)	{
		prevView = [views objectAtIndex:i - 1];
		oldDict = [NSMutableDictionary dictionaryWithDictionary:
			[self dictionaryForMovingView:prevView fromFrame:[self largeFrameForPulsating:[prevView frame]] toFrame:[prevView frame]]];
		
		[oldDict setObject:[NSNumber numberWithBool:YES] forKey:@"SHOULD_REMOVE_VIEW"];
		view = [views objectAtIndex:i];
		newDict = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryForMovingView:view fromFrame:[view frame] toFrame:[self largeFrameForPulsating:[view frame]]]];
		[newDict setObject:[NSNumber numberWithBool:YES] forKey:@"SHOULD_UNHIDE_VIEW"];
		ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:
			newDict, oldDict, nil]] autorelease];
		[ani setDelegate:self];
		[ani setDuration:duration];
		[chain addObject:ani];
	}

	view = [views objectAtIndex:[views count] - 1];
	oldDict = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryForMovingView:view fromFrame:[self largeFrameForPulsating:[view frame]] toFrame:[view frame]]];
	[oldDict setObject:[NSNumber numberWithBool:YES] forKey:@"SHOULD_REMOVE_VIEW"];
	ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:oldDict]] autorelease];
	[ani setDelegate:self];
	[ani setDuration:duration];
	
	[chain addObject:ani];
	
	[theAnimationChain addObjectsFromArray:chain];
	
	[self startChainIfNessecary];
}
-(NSDictionary*) dictionaryForMovingView:(NSView*)view fromFrame:(NSRect)oldFrame toFrame:(NSRect)newFrame	{
	return [NSDictionary dictionaryWithObjectsAndKeys:
		view, NSViewAnimationTargetKey,
		[NSValue valueWithRect:oldFrame], NSViewAnimationStartFrameKey,
		[NSValue valueWithRect:newFrame], NSViewAnimationEndFrameKey,
		nil];
		
	
}


-(NSRect) largeFrameForPulsating:(NSRect)startFrame	{
	NSRect newFrame = startFrame;
	newFrame.size.width += (0.5 * startFrame.size.width);
	newFrame.size.height += (0.5 * startFrame.size.height);
	newFrame.origin.x -= (newFrame.size.width - startFrame.size.width) / 2;
	newFrame.origin.y -= (newFrame.size.height - startFrame.size.height) / 2;
	
	return newFrame;
}
//-(NSDictionary*) dictionaryForMovingView:(NSView*)view fromFrame:(NSRect)oldFrame toFrame:(NSRect)newFrame;

/*
-(NSAnimation*) shrinkAnimationForView:(NSView*)view fromFrame:(NSRect)frame toFrame:(NSRect)frame	{
	NSViewAnimation* ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObj
}	
*/

-(void) animateIconForProperty:(NSString*)str fromPlayer:(Player*)fromPlayer toPlayer:(Player*)toPlayer	withCallback:(NSDictionary*)callback {
//	NSLog(@"animateIconForProperty, %@", str);
	NSMutableArray* chain = [NSMutableArray array];
	NSImage* image = [self animationImageForProperty:str];
//	NSLog(@"got image, %@", image);
//	[[image TIFFRepresentation] writeToFile:@"/animationImage.tiff" atomically:NO];
//	NSRect windowBounds = [animationLayer bounds];
	NSRect boardBounds = [boardView bounds];
	NSRect midRect = NSMakeRect(boardBounds.origin.x + (boardBounds.size.width - [image size].width) / 2, boardBounds.origin.y + (boardBounds.size.height - [image size].height) / 2, [image size].width, [image size].height);
	midRect.origin = [[[boardView window] contentView] convertPoint:midRect.origin fromView:boardView];
	NSRect startRect;
	PlayerView* pv;
	if (fromPlayer == nil)
		startRect = midRect;
	else	{
		pv = [self realViewForPlayer:fromPlayer];
		if ([str isEqualToString:@"LongestRoad"])
			startRect = [pv rectForFirstIcon];
		else
			startRect = [pv rectForSecondIcon];
		
		startRect.origin = [[[pv window] contentView] convertPoint:startRect.origin fromView:pv];
	}
	NSRect endRect;
	pv = [self realViewForPlayer:toPlayer];
	if ([str isEqualToString:@"LongestRoad"])
		endRect = [pv rectForFirstIcon];
	else
		endRect = [pv rectForSecondIcon];
		
	endRect.origin = [[[pv window] contentView] convertPoint:endRect.origin fromView:pv];
	
	SimpleImageView* iv = [[[SimpleImageView alloc] initWithFrame:startRect] autorelease];
	[iv setImage:image];
	
	NSViewAnimation* ani;
	if (fromPlayer == nil)	{
		ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
			[NSDictionary dictionaryWithObjectsAndKeys:
				iv, NSViewAnimationTargetKey,
				[NSValue valueWithRect:startRect], NSViewAnimationStartFrameKey,
				NSViewAnimationFadeInEffect, NSViewAnimationEffectKey,
				[NSNumber numberWithBool:YES], @"SHOULD_ADD_VIEW",
					nil]]] autorelease];
		[iv setHidden:YES];
	
	}
	else
		ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
			[NSDictionary dictionaryWithObjectsAndKeys:
				iv, NSViewAnimationTargetKey,
				[NSValue valueWithRect:startRect], NSViewAnimationStartFrameKey,
				[NSValue valueWithRect:midRect], NSViewAnimationEndFrameKey,
				[NSNumber numberWithBool:YES], @"SHOULD_ADD_VIEW",
				nil]]] autorelease];
		
	[animationLayer addSubview:iv];	
	if (fromPlayer == nil)
		[ani setDuration:1.2]
		;
	else
		[ani setDuration:0.5];
	[ani setDelegate:self];
	[chain addObject:ani];
	
	ani = [self fillerAnimationWithDuration:0.75];
	[ani setDelegate:self];
	[chain addObject:ani];
	
	ani = [[[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:
		[NSDictionary dictionaryWithObjectsAndKeys:
			iv, NSViewAnimationTargetKey,
			[NSValue valueWithRect:midRect], NSViewAnimationStartFrameKey,
			[NSValue valueWithRect:endRect], NSViewAnimationEndFrameKey,
			[NSNumber numberWithBool:YES], @"SHOULD_REMOVE_VIEW", 
			callback, @"CALLBACK_INFO", 
			nil]]] autorelease];
			
	[ani setDuration:0.5];
	[ani setDelegate:self];
	[chain addObject:ani];
	
	[theAnimationChain addObjectsFromArray:chain];
	[self startChainIfNessecary];
//	[[theAnimationChain objectAtIndex:0] performSelector:@selector(startAnimation) withObject:nil afterDelay:0.1];
}

-(NSImage*) animationImageForProperty:(NSString*)str	{
//	NSLog(@"animationImageForProperty");
	NSImage* baseImage = [NSImage imageNamed:[NSString stringWithFormat:@"%@Icon.png", str]];
//	NSLog(@"got base image");

	NSRect baseRect = NSMakeRect(0, 0, [baseImage size].width, [baseImage size].height);
	NSString* string;
	if ([str isEqualToString:@"LargestArmy"])
		string = @"Largest Army";
	else
		string = @"Longest Road";
		
	NSDictionary* atts = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont fontWithName:@"Helvetica" size:24], NSFontAttributeName,
		[NSColor blackColor], NSForegroundColorAttributeName, nil];

	NSAttributedString* attStr = [[[NSAttributedString alloc] initWithString:string attributes:atts] autorelease];
	
	float w;
	if ([attStr size].width > [baseImage size].width)
		w = [attStr size].width;
	else
		w = [baseImage size].width;
		
	NSImage* imageWithText = [[[NSImage alloc] initWithSize:NSMakeSize(w, [baseImage size].height)] autorelease];
	[imageWithText setScalesWhenResized:YES];
//	[imageWith

	[imageWithText lockFocus];
	[baseImage drawInRect:NSMakeRect( ([imageWithText size].width - baseRect.size.width) / 2, ([imageWithText size].height - baseRect.size.height) / 2, baseRect.size.width, baseRect.size.height) fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[attStr drawAtPoint:NSMakePoint(([imageWithText size].width - [attStr size].width) / 2, 0)];
	[imageWithText unlockFocus];
//	[[imageWithText TIFFRepresentation] writeToFile:@"/aaaIconWithText.tiff" atomically:NO];
//	NSLog(@"got image with text");
//	[[imageWithText TIFFRepresentation] writeToFile:@"/iconWithText" atomically:NO];
	NSShadow* shadow = [NSShadow standardShadow];
//	NSLog(@"got shadow");
	NSRect targetRect = NSMakeRect(0, 0, [imageWithText size].width, [imageWithText size].height + 10);
//	targetRect.origin.y += 10;
	NSImage* animationImage = [[[NSImage alloc] initWithSize:NSMakeSize([imageWithText size].width + 10, [imageWithText size].height + 10)] autorelease];

	[animationImage lockFocus];
	[shadow set];
//	[imageWithText drawInRect:targetRect fromRect:NSMakeRect(0, 0, [imageWithText size].width, [imageWithText size].height) operation:NSCompositeSourceOver fraction:1.0];
	[imageWithText compositeToPoint:NSMakePoint(0, 10) operation:NSCompositeSourceOver];
	
//	shadow = [NSShadow noShadow];
//	[shadow set];
//	[[NSColor blueColor] set];
//	[NSBezierPath strokeRect:NSMakeRect(0, 0, [animationImage size].width, [animationImage size].height)];
	
	[animationImage unlockFocus];
	
//	[[animationImage TIFFRepresentation] writeToFile:@"/aniImage.tiff" atomically:NO];

//	[baseImage lockFocus];
//	[[NSColor blueColor] set];
//	[NSBezierPath strokeRect:NSMakeRect(0, 0, [baseImage size].width, [baseImage size].height)];
//	[baseImage unlockFocus];
	
//	[[baseImage TIFFRepresentation] writeToFile:@"/aaaBase.tiff" atomically:NO];

	return animationImage;
}

-(NSImage*) oldanimationImageForProperty:(NSString*)str	{
//	NSLog(@"animationImageForProperty");
	NSImage* baseImage = [NSImage imageNamed:[NSString stringWithFormat:@"%@Icon.png", str]];
//	NSLog(@"got base image");
	NSRect baseRect = NSMakeRect(0, 0, [baseImage size].width, [baseImage size].height);
	NSString* string;
	if ([str isEqualToString:@"LargestArmy"])
		string = @"Largest Army";
	else
		string = @"Longest Road";
		
	NSDictionary* atts = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont fontWithName:@"Helvetica" size:24], NSFontAttributeName,
		[NSColor blackColor], NSForegroundColorAttributeName, nil];

	NSAttributedString* attStr = [[[NSAttributedString alloc] initWithString:string attributes:atts] autorelease];
	
	float w;
	if ([attStr size].width > [baseImage size].width)
		w = [attStr size].width;
	else
		w = [baseImage size].width;
		
	NSImage* imageWithText = [[[NSImage alloc] initWithSize:NSMakeSize(w, [baseImage size].height)] autorelease];
	NSImage* animationImage = [[[NSImage alloc] initWithSize:NSMakeSize([imageWithText size].width + 10, [imageWithText size].height + 10)] autorelease];

	[imageWithText lockFocus];
	[baseImage drawInRect:NSMakeRect( ([imageWithText size].width - baseRect.size.width) / 2, ([imageWithText size].height - baseRect.size.height) / 2, baseRect.size.width, baseRect.size.height) fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[attStr drawAtPoint:NSMakePoint((baseRect.size.width - [attStr size].width) / 2, 4)];
	[imageWithText unlockFocus];
//	NSLog(@"got image with text");
//	[[imageWithText TIFFRepresentation] writeToFile:@"/iconWithText" atomically:NO];
	NSShadow* shadow = [NSShadow standardShadow];
//	NSLog(@"got shadow");
	NSRect targetRect = baseRect;
	targetRect.origin.y += 10;
	[animationImage lockFocus];
	[shadow set];
	[imageWithText drawInRect:baseRect fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[animationImage unlockFocus];
	
	
	return animationImage;
}


@end

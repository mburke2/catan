//
//  ResourceManager.h
//  catan
//
//  Created by James Burke on 2/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AnimatedCardView.h"
#import "BankView.h"
#import "BoardView.h"
#import "Player.h"
#import "CollectionView.h"
#import "GameController.h"
#import "SimpleImageView.h"
#import "ConfettiView.h"
#import "ViewAnimationChain.h"
#import "ProperResizeView.h"
#import "CardFlipAnimation.h"
#import "CardFlipView.h"

//#import "AnimationThread.h"
@class PlayerView;
@interface ResourceManager : NSObject {
	AnimatedCardView* animationLayer;
	NSArray* playerViews;
	BoardView* boardView;
	SimpleImageView* boardShadeView;
	BankView* bankView;
	CollectionView* localResView;
	CardFlipView* cardFlipView;
	
	NSAnimation* fadeInAnimation;
	NSAnimation* fadeOutAnimation;
	NSArray* cardAnimations;
	
	BOOL animatingFlag;
	NSMutableArray* theAnimationChain;
	id endAni;
	ConfettiView* confettiView;
//	NSDistantObject <animationThreadProtocol> *animationThread;
}

-(void)startChainIfNessecary;
-(id) initWithAnimationLayer:(AnimatedCardView*)acv playerViews:(NSArray*)arr bankView:(BankView*)bank boardView:(BoardView*)board resourceView:(CollectionView*)cv;
-(NSRect) rectForPlayer:(Player*)p resource:(NSString*)res;
-(void) tradeResources:(NSArray*)resArr fromPlayer:(Player*)fromPlayer toPlayer:(Player*)toPlayer;
-(void) tradeResources:(NSArray*)resArr fromBankToPlayer:(Player*)p;
-(void) tradeResources:(NSArray*)resArr toBankFromPlayer:(Player*)p;
//	[resourceManager stealResource:res fromPlayer:p toPlayer:[players objectAtIndex:turnIndex]];
-(void) stealResource:(NSString*)str fromPlayer:(Player*)fromPlayer toPlayer:(Player*)toPlayer;
-(void) distributeBoardResources:(NSDictionary*)boardResInfo;
-(float) delayMiddleAnimation:(NSDictionary*)dict;
-(NSRect) scaledRectWithRect:(NSRect)rect factor:(float)factor;
-(PlayerView*) realViewForPlayer:(Player*)p;
-(void) animateIconForProperty:(NSString*)str fromPlayer:(Player*)fromPlayer toPlayer:(Player*)toPlayer;
-(NSRect) largeFrameForPulsating:(NSRect)startFrame;
-(NSDictionary*) dictionaryForMovingView:(NSView*)view fromFrame:(NSRect)oldFrame toFrame:(NSRect)newFrame;
//-(void) animateLargestArmyFromPlayer:(Player*)fromPlayer
-(NSAnimation*) pulseAnimationForViews:(NSArray*)views pulseFactor:(float)factor removeViews:(BOOL)flag;
@end

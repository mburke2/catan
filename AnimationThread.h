//
//  AnimationThread.h
//  catan
//
//  Created by James Burke on 2/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AnimatedCardView;
@class BoardView;
@class CollectionView;
@class BankView;
@class FadeImageView;

@protocol animationThreadProtocol


-(void) setAnimatedCardView:(AnimatedCardView*)acv boardView:(BoardView*)board collectionView:(CollectionView*)cv bankView:(BankView*)bank shadeView:(FadeImageView*)shade;
-(oneway void) startAnimations:(NSArray*)anis;
-(void) fadeImageIn:(NSImage*)image;
@end


@interface AnimationThread : NSObject <animationThreadProtocol> {
	AnimatedCardView* animationView;
	BoardView* boardView;
	CollectionView* collectionView;
	BankView* bankView;
	NSImageView* boardShadeView;
	
	BOOL blocking;
}

+(NSDistantObject*) createAnimationThread;


@end

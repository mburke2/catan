//
//  ViewAnimationChain.h
//  catan
//
//  Created by James Burke on 3/9/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol animationDelegateProtocol
-(BOOL) animationShouldStart:(id)sender;
-(void) animationDidEnd:(id)sender;
@end

@interface ViewAnimationChain : NSObject {
	NSArray* animations;
	id <animationDelegateProtocol> myDelegate;
	float pieceDuration;
//	float totalDuration;
}


-(id) initWithChainArray:(NSArray*)arr;
-(NSArray*) viewAnimations;
-(void) startAnimation;
-(void) setPieceDuration:(float)f;
-(void) setDuration:(float)f;
-(void) setDelegate:(id)del;
@end

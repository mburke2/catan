//
//  AnimationChain.h
//  catan
//
//  Created by James Burke on 2/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface AnimationChain : NSAnimation {
	id myDelegate;
	NSArray* myAnimations;
	NSAnimation* currentAnimation;
}

-(id) initWithAnimations:(NSArray*)arr;
-(void) startAnimation;
-(void) setDelegate:(id)del;

@end

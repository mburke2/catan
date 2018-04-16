//
//  GLAnimation.h
//  GLCard Flip
//
//  Created by James Burke on 3/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GLAnimation : NSObject {
	NSOpenGLView* glView;
	float duration;
	id myDelegate;
	NSDate* startDate;
}

-(NSView*) view;
-(void) setDuration:(float)f;
-(void) setView:(NSOpenGLView*)v;
-(void) setDelegate:(id)delegate;
-(void) startAnimation;

@end

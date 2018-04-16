//
//  AnimatedCardView.h
//  catan
//
//  Created by James Burke on 2/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AnimatedCardView : NSView {
//	id myDelegate;
//	NSTimer* animationTimer;
//	NSImage* myImage;
//	NSRect currentFrame;
//	NSRect startFrame;
//	NSRect endFrame;
//	float animationLength;
//	NSDate* startDate;

//	NSMutableArray* frames;
//	NSMutableArray* images;
	
	NSMutableArray* animations;
	NSMutableArray* mAnimations;
	NSMutableArray* callbacks;
	
//	NSAnimation* middleAnimation;
//	NSAnimation* startAnimation;
//	NSAnimation* endAnimation;
}

-(void) animateImage:(NSImage*)image fromFrame:(NSRect)f1 toFrame:(NSRect)f2 time:(float)time delegate:(id)delegate;
-(NSArray*) middleRectsForResources:(NSArray*)res;

@end

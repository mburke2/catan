//
//  CardFlipAnimation.h
//  catan
//
//  Created by James Burke on 3/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AnimatedCardView.h"
#import "CardFlipView.h"
#import "GLAnimation.h"
#import "SimpleImageView.h"
#import "NSImage-Additions.h"

@interface CardFlipAnimation : NSObject {
	
//	NSString* image
	NSImage* myImage;
	NSString* myImageName;
	SimpleImageView* animatedView;
	CardFlipView* glLayer;
	AnimatedCardView* animationLayer;

	NSViewAnimation* ani1;
	NSViewAnimation* ani2;
	GLAnimation* glAni;

	id myDelegate;
	NSDictionary* infoDict;
	
	NSRect startRect;
	NSRect endRect;
	
//	id myDelegate;
}

-(id) initWithImageName:(NSString*)imageName fromRect:(NSRect)sRect toRect:(NSRect)eRect withInfo:(NSDictionary*)dict animationLayer:(NSView*)view glLayer:(NSView*)glView;
-(void) startAnimation;
-(void) setDelegate:(id)obj;
-(NSArray*) viewAnimations;

@end

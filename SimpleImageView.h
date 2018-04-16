//
//  SimpleImageView.h
//  catan
//
//  Created by James Burke on 2/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SimpleImageView : NSView {
	NSImage* myImage;
	NSSize imageSize;
	float myAlphaValue;
	BOOL drawFlag;
}


-(void) setShouldDraw:(BOOL)flag;
-(void) setAlphaValue:(float)f;
-(void) setImage:(NSImage*)image;

@end

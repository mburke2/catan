//
//  FadeImageView.h
//  catan
//
//  Created by James Burke on 2/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FadeImageView : NSView {
	NSImage* myImage;
	float myAlpha;
}

-(void) setImage:(NSImage*)image;
-(void) setAlpha:(float)alpha;

@end

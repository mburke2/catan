//
//  ResViewRep.h
//  catan better resource view
//
//  Created by James Burke on 2/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSBezierPath-Additions.h"

@interface ResViewRep : NSObject {
	NSString* type;
	NSImage* image;
	NSImage* selectedImage;
	BOOL selected;
	NSRect frame;
//	NSRect animationStartFrame;
//	NSRect animationEndFrame;
}

-(NSRect) animationStartFrame;
-(NSRect) animationEndFrame;
-(NSRect) frame;
-(void) setType:(NSString*)str;
@end

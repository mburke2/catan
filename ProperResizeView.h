//
//  ProperResizeView.h
//  catan
//
//  Created by James Burke on 3/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ProperResizeView : NSView {
	NSRect originalFrame;
	NSMutableArray* subviews;
	NSMutableArray* originalSubviewFrames;
}


//-(void) addSubview:(NSView*)sv;

@end

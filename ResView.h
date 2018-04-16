//
//  ResView.h
//  catan better resource view
//
//  Created by James Burke on 2/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ResView : NSView {
	NSString* type;
	NSImage* image;
	NSImage* selectedImage;
	BOOL selected;
	float myAlphaValue;
}

-(void) setType:(NSString*)str;
-(NSString*) type;
-(void) setImage;
-(NSImage*) image;

-(BOOL) selected;
-(void) setSelected:(BOOL)flag;
-(void) toggleSelected;
-(void) setAlpha:(float)alpha;

@end

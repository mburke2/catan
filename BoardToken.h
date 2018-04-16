//
//  BoardToken.h
//  catan
//
//  Created by James Burke on 1/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class Player;
@interface BoardToken : NSObject {
	Player* myOwner;
	NSImage* myImage;
	NSImage* highlightImage;
//	BOOL flag;
	BOOL highlightFlag;
}


-(id) initWithOwner:(Player*)p;
-(Player*) owner;
-(NSImage*) image;
-(int) perspectives;
-(NSString*) imagePrefix;
-(NSSize) size;

-(void) setHighlight:(BOOL)flag;


@end

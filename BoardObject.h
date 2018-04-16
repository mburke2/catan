//
//  BoardObject.h
//  catan
//
//  Created by James Burke on 12/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BoardTokens.h"

@interface BoardObject : NSObject {
	int myTag;
	BoardToken* myToken;
}

-(void) setTag:(int)t;
-(int) tag;
-(BoardToken*) item;
-(void) setItem:(BoardToken*)token;
-(NSRect) imageRect;
@end

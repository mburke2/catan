//
//  RealBoardView.h
//  catan
//
//  Created by James Burke on 1/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Board.h"
#import "BoardHexagon.h"
#import "DiceValueChips.h"
@interface RealBoardView : NSView {
	Board* theBoard;
}

-(void) setBoard:(Board*)b;



@end

//
//  RollFrequencyController.h
//  catan
//
//  Created by James Burke on 2/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DiceGraphView.h"

@interface RollFrequencyController : NSObject {
	IBOutlet DiceGraphView* graphView;
	int theRolls[11];
}


//-(void) getRolls:(int[11])theRolls;
-(NSArray*) getRolls;
-(void) addRoll:(int)r;

@end

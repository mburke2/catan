//
//  PrefsController.h
//  catan
//
//  Created by James Burke on 6/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PrefsController : NSWindowController {
	IBOutlet NSTextField* pointField;
	IBOutlet NSTextField* cityField;
	IBOutlet NSTextField* settField;
	
	IBOutlet NSButton* tradeButton;
	IBOutlet NSButton* purchaseButton;
	IBOutlet NSButton* devCardUseButton;
	IBOutlet NSButton* knightOnlyDevCardButton;
	
	IBOutlet NSButton* oneDevCardPerTurnButton;
	IBOutlet NSButton* excludingVictoryPointsButton;
	IBOutlet NSButton* limitKnightsOnlyButton;


	IBOutlet NSTextField* noGameField;

}


-(IBAction) close:(id)sender;
-(IBAction) apply:(id)sender;

@end

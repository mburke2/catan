//
//  PrefsController.m
//  catan
//
//  Created by James Burke on 6/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PrefsController.h"
#import "GameController.h"

@implementation PrefsController


-(IBAction) close:(id)sender	{

	[[self window] close];
}

-(IBAction) apply:(id)sender	{

	[[self window] close];
}

/*
    "CAN_PLAY_DEV_CARD" = 1; 
    "CAN_PURCHASE" = 1; 
    "CAN_TRADE" = 1; 
    "CITY_TOKENS" = 4; 
    "EXCLUDE_VP" = 1; 
    "KNIGHT_BEFORE_ROLL" = 0; 
    "ONE_PER_TURN" = 1; 
    "ONLY_KNIGHT" = 0; 
    "POINT_TOTAL" = 10; 
    "SETTLEMENT_TOKENS" = 5; 
*/

-(void) showWindow:(id)sender	{
	if ([[GameController gameController] gameInProgress] == NO)
		[noGameField setHidden:NO];
	
	else	{
		[noGameField setHidden:YES];
		NSDictionary* prefs = [[GameController gameController] gamePrefs];
	
		NSLog(@"prefs = %@", prefs);
		
		[pointField setIntValue:[[prefs objectForKey:@"POINT_TOTAL"] intValue]];
		[cityField setIntValue:[[prefs objectForKey:@"CITY_TOKENS"] intValue]];
		[settField setIntValue:[[prefs objectForKey:@"SETTLEMENT_TOKENS"] intValue]];
		
		[tradeButton setState:[[prefs objectForKey:@"CAN_TRADE"] intValue]];
		[purchaseButton setState:[[prefs objectForKey:@"CAN_PURCHASE"] intValue]];
		[devCardUseButton setState:[[prefs objectForKey:@"CAN_PLAY_DEV_CARD"] intValue]];
		[knightOnlyDevCardButton setState:[[prefs objectForKey:@"KNIGHT_BEFORE_ROLL"] intValue]];
		
		[oneDevCardPerTurnButton setState:[[prefs objectForKey:@"ONE_PER_TURN"] intValue]];
		[excludingVictoryPointsButton setState:[[prefs objectForKey:@"EXCLUDE_VP"] intValue]];
		[limitKnightsOnlyButton setState:[[prefs objectForKey:@"ONLY_KNIGHT"] intValue]];
	}
	
	[super showWindow:sender];
	
}

/*
- (void)windowWillMove:(NSNotification *)aNotification	{
	NSLog(@"will move");
}
*/


@end

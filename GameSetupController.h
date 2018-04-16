//
//  GameSetupController.h
//  catan
//
//  Created by James Burke on 1/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Board.h"
#import "BoardView.h"
#import "BGClient.h"
#import "DevelopmentCard.h"
#import "GameController.h"
#import "Control.h"
#import "Player.h"
//@class GameClient;

@interface GameSetupController : NSObject {
	IBOutlet NSButton* readyButton;
	IBOutlet NSButton* startButton;
	IBOutlet NSTableView* playerTable;
	IBOutlet NSTextField* chatInputField;
	IBOutlet NSTextView* chatView;
	IBOutlet NSColorWell* colorWell;
	IBOutlet NSWindow* window;
	
	IBOutlet BoardView* boardPreview;
	IBOutlet NSMatrix* desertLocationSwitch;
	IBOutlet NSButton* devCardUseageBox;
	IBOutlet NSButton* excludeVPBox;
	IBOutlet NSButton* generateBoardButton;
	IBOutlet NSButton* knightBox;
	IBOutlet NSButton* onePerTurnBox;
	IBOutlet NSButton* purchaseBox;
	IBOutlet NSButton* tradeBox;
	IBOutlet NSTextField* portStatusField;
	IBOutlet NSButton* knightBeforeRoll;
	
	IBOutlet NSTextField* pointTotalField;
	IBOutlet NSTextField* cityField;
	IBOutlet NSTextField* settlementField;


	BOOL gameHost;
	BOOL readyFlag;
	NSString* myName;
	NSColor* myColor;
//	GameClient* theServer;
	BGClient* theServer;
	
	BOOL shouldChangeColorSetting;
	
	NSMutableArray* players;
	
	NSDictionary* gamePrefs;
	NSDictionary* buttonDict;
	
	NSData* boardInfo;
}

-(NSData*) boardInfo;
-(NSDictionary*) gamePrefs;


//-(id) initWithServer:(GameClient*)obj name:(NSString*)nm color:(NSColor*)color board:(NSData*)info prefs:(NSDictionary*)prefs asHost:(BOOL)flag;
-(id) initWithServer:(BGClient*)obj name:(NSString*)nm color:(NSColor*)color board:(NSData*)info prefs:(NSDictionary*)prefs asHost:(BOOL)flag;

-(IBAction) toggleReady:(id)sender;
-(IBAction) sendChat:(id)sender;
-(IBAction) startGame:(id)sender;
-(IBAction) colorChanged:(id)sender;
-(IBAction) generateBoard:(id)sender;
-(IBAction) prefsChanged:(id)sender;
-(void) close;


-(void) notify:(SEL)sel args:(NSArray*)args;
-(NSColor*) color;
-(void) addPlayer:(NSDictionary*)dict;
@end

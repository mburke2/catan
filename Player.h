//
//  Player.h
//  catan
//
//  Created by James Burke on 1/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DevelopmentCard.h"
#import "NSArray-Additions.h"
//#import "TradeRoutes
//#import "GameController.h"

@class Vertex;
@class Edge;
@class CollectionView;
@class BoardToken;

@interface Player : NSObject {
	NSString* myName;
	NSColor* myColor;
	
	NSMutableArray* resources;
//	NSMuta
	NSArray* draggedResources;
	
	NSArray* catagories;
	NSArray* items;
	
	NSMutableArray* settlements;
	NSMutableArray* myDevCards;
	NSMutableArray* myRoads;
//	NSArray* tradeRoutes;

	int cardsToDiscard;
	
	int armySize;
	int vpCards;
	
	BOOL active;
	
	CollectionView* resView;
	
	
	int resourcesLostToRobber;
	int resourcesStolen;
	int earnedResources;
	float expectedResources;
	int sevensRolled;
	int tradedAway;
	int receivedInTrade;
}

-(BOOL) active;
-(void) setActive:(BOOL)flag;
-(NSArray*) settlements;
-(int) score;
-(void) setResourceView:(CollectionView*)cv;
-(id) initWithName:(NSString*)str color:(NSColor*)color;
+(Player*) playerWithName:(NSString*)str color:(NSColor*)color;
-(void) resourceTableDoubleClicked:(id)sender;
-(void) addDevCard:(DevelopmentCard*)dc;
-(void) addSettlement:(Vertex*)v;
-(NSArray*) tradeRoutes;
-(void) addResource:(NSString*)str;
//-(void) addTradeRoute:(TradeRoute*)tr;
-(NSArray*) resources;
-(void) spend:(NSArray*)arr;
-(int) countResourcesOfType:(NSString*)str;
-(BOOL) itemIsCatagory:(id)item;
-(NSString*) typeForItem:(id)item;

-(void) addRoad:(Edge*)e;
-(int) roadCount;
-(int) settlementCount;

-(NSString*) name;
-(NSColor*) color;

-(void) decreaseDiscardCountBy:(int)n;
-(int) discardCount;
-(void) setDiscardIfNeeded;

-(void) activateDevCards;
-(void) deactivateDevCards;
-(int) armySize;




-(void) projectResources:(float*)res afterRolls:(int)rolls;
-(void) getGainsPerRoll:(float*)gainsPerRoll;


/*
	int resourcesLostToRobber;
	int resourcesStolen;
	int earnedResources;
	float expectedResources;
	int sevensRolled;
*/

-(void) settlementWasRobbered:(BoardToken*)token;
-(void) rolledSeven;
-(void) incrementStolenResources:(int)n;
-(void) incrementEarnedResources:(int)n;
-(void) incrementExpectedResources:(float)f;

-(int) sevensRolled;
-(int) earnedResources;
-(float) expectedResources;
-(int) resourcesLostToRobber;
-(int) stolenResources;

-(int) tradedAway;
-(int) receivedInTrade;

-(void) tradedResources:(int)n;
-(void) receivedResourcesViaTrade:(int)n;
@end

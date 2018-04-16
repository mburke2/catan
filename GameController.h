//
//  GameController.h
//  catan
//
//  Created by James Burke on 1/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSMutableArray-Shuffle.h"
#import "Board.h"
#import "Edge.h"
#import "Vertex.h"
#import "BoardHexagon.h"
#import "Player.h"
#import "DevelopmentCard.h"

@class GameClient;
@class Control;
@class BoardView;
@class AnimatedCardView;
@class ResourceManager;

enum GamePhase	{
	RollPhase,
	SetupPhase,
	ReverseSetupPhase,
	PlayPhase
};


@interface GameController : NSObject {
	int phase;
	
	Player* thePlayer;
	Player* winner;
	NSMutableArray* vertices;
	
	NSArray* players;
	
	BOOL canMoveRobber;
	int roadBuilderCounter;
	
	int firstPlayer;
	
	Board* theBoard;
	NSMutableArray* devCards;
	
	GameClient* server;
	Control* interface;
	
	int turnIndex;
	BOOL rolled;
	BOOL canSteal;
	int bankTradeValue;
	
	NSDictionary* gamePrefs;
//	NSRect robberRect;

	BOOL playedKnight;
	BOOL playedCard;
	
	NSArray* placementIndices;
	int placementCounter;
	ResourceManager* resourceManager;
	
	
	int rollPhaseResultArray[4];
	
	
	NSArray* longestRoad;
	Player* largestArmy;
    
    
    IBOutlet NSTableView* statsTable;

}

@property (nonatomic, strong) IBOutlet NSWindow* statsWindow;
//-(NSRect) robberRect;
-(int) twoToOneTradeValue:(NSArray*)arr forResource:(NSString*)str;
+(GameController*) gameController;


-(BOOL) gameInProgress;
-(BOOL) canBuildRoad;
-(BOOL) canBuildSettlement;
-(BOOL) canBuildCity;
-(BOOL) canBuildDevCard;

-(void) setDevCards:(NSMutableArray*)arr;

-(BoardView*) boardView;

-(void) setInterface:(Control*)c;
-(void) setBoard:(Board*)b;
-(Board*) board;
-(BOOL) canDragRoadTo:(Edge*)edge;
-(BOOL) canDragCityTo:(Vertex*)vertex;
-(BOOL) canDragSettlementTo:(Vertex*)vertex;
-(BOOL) canMoveRobber;
-(void) setPhase:(int)p;
-(int) phase;
-(BOOL) performRoll:(NSNumber*)n;
-(void) addVertexItem:(Vertex*)v;
-(void) addEdgeItem:(Edge*)e;
-(void) giveResource:(NSString*)res;
-(void) makeCurrentPlayerSpend:(NSArray*)arr;
-(BOOL) currentPlayerCanTradeToBank:(NSArray*)arr;
-(void) robberMoved;
-(BOOL) localPlayerMustDiscard;
-(BOOL) buyDevCard;
-(Player*) localPlayer;
-(Player*) currentPlayer;
-(void) setServer:(GameClient*)srvr;
-(BOOL) rolled;
-(BOOL) localTurn;
-(BOOL) turnCanEnd;
-(NSArray*) players;
-(BOOL) trade:(NSArray*)res from:(Player*)from to:(Player*)to;
-(BOOL) trade:(NSArray*)res fromToIndices:(NSArray*)arr;
-(int) turnIndex;
-(void) addItem:(NSString*)item toVertex:(NSNumber*)n;
-(void) addRoadToEdge:(NSNumber*)n;
-(void) moveRobberToTile:(NSNumber*)n;
-(void) stealFrom:(Player*)p;
-(BOOL) canSteal;
-(BOOL) playerHasLongestRoad:(Player*)p;
-(AnimatedCardView*) animatedCardView;
-(void) setGamePrefs:(NSDictionary*)dict;
-(BOOL) playerHasLargestArmy:(Player*)p;
-(void) endTurn;


-(void) buildPlacementIndicesStartingWithIndex:(int)n;
-(int) numberOfSettlementsPlayerShouldHaveDuringSetup;

-(int) cityCount;
-(int) settlementCount;

-(int) availableSettlementsForLocalPlayer;
-(int) availableCitiesForLocalPlayer;
-(int) winningPointTotal;

-(void) interfaceBecameActive;
-(void) setActive:(BOOL)flag forIndex:(int)index;


-(NSDictionary*) gamePrefs;

-(BOOL) playDevCard:(NSString*)card;
@end

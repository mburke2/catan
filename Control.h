/* Control */

#import <Cocoa/Cocoa.h>
#import "PurchaseTableItemCell.h"
#import "ResourceTableView.h"
#import "ResourceOutlineView.h"
#import "PurchaseTableView.h"
#import "FrameView.h"
#import "GameController.h"
#import "Player.h"
#import "BankView.h"
#import "PlayerView.h"
#import "DevelopmentCard.h"
#import "DiceView.h"
#import "ImageAndTextCell.h"
#import "DiceGraphView.h"
#import "AnimatedCardView.h"
#import "RollFrequencyController.h"
#import "ResourceManager.h"
//#import "CollectionView.h"

@class CollectionView;
@class BoardView;
@class AnimatedCardWindow;
@interface Control : NSObject
{
    
    IBOutlet BoardView* boardView;
//	IBOutlet NSTableView* tableView;
	IBOutlet PurchaseTableView* purchaseTable;
	NSDictionary* purchaseTableDictionary;
	NSArray* purchaseTableArray;
	IBOutlet NSTextField* diceValueField;
	IBOutlet ResourceTableView* resourceTable;
	IBOutlet ResourceOutlineView* resourceOutline;
	IBOutlet BankView* bankView;
	IBOutlet NSTableView* devCardTable;
	IBOutlet FrameView* frameView;
	
	IBOutlet PlayerView* playerView1;
	IBOutlet PlayerView* playerView2;
	IBOutlet PlayerView* playerView3;
	IBOutlet PlayerView* playerView4;
	
	IBOutlet NSTextField* chatInputField;
	IBOutlet NSTextView* chatView;
	
	IBOutlet NSButton* rollButton;
	IBOutlet NSButton* endButton;
	IBOutlet NSWindow* window;
	IBOutlet DiceView* diceView;
	IBOutlet CollectionView* resourceView;
	
	RollFrequencyController* rollFrequencyController;
	
	BOOL enabled;
	NSArray* playerViews;
	
//	AnimatedCardView* cardView;
	AnimatedCardWindow* animatedCardWindow;
	
//	NSWindow* 
}

-(float) diceRollAnimationDelay;
-(IBAction) rollDice:(id)sender;
-(IBAction) endTurn:(id)sender;
-(IBAction) sendChat:(id)sender;
-(void) update;
-(void) playDevCard:(DevelopmentCard*)card;
-(AnimatedCardView*) animatedCardView;
-(BoardView*) boardview;
@end

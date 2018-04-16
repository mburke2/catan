/* PlayerView */

#import <Cocoa/Cocoa.h>
//#import "Player.h"

@class Player;

enum PlayerViewLocation	{
	TopLeft,
	TopRight,
	BottomLeft,
	BottomRight
};

@interface PlayerView : NSView
{
	Player* myPlayer;
	BOOL highlight;
	BOOL robberableFlag;
	int myLocation;
	
	NSBezierPath* outlinePath;
}

-(int) loction;
-(void) setLocation:(int)loc;
-(void) setPlayer:(Player*)p;
-(void) setHighlight:(BOOL)flag;
-(void) setRobberable:(BOOL)flag;
-(Player*)player;
-(NSRect) rectForFirstIcon;
-(NSRect) rectForSecondIcon;
-(NSRect) rectForDiscardString:(NSAttributedString*)str;
-(NSRect) rectForStealString:(NSAttributedString*)str;
-(NSRect) resRect;


-(BOOL) shouldAcceptTrade:(id <NSDraggingInfo>) sender;
@end

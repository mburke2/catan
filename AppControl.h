/* AppControl */

#import <Cocoa/Cocoa.h>
#import "GameServer.h"
#import "GameClient.h"
#import "PrefsController.h"
#import "GameSetupController.h"

@interface AppControl : NSObject	{
	BOOL connected;
	BOOL hosting;
	IBOutlet NSTextField* addField;
	IBOutlet NSTextField* numPlayersField;
	IBOutlet NSTextField* nameField;
	IBOutlet NSWindow* window;
	IBOutlet NSTableView* localGamesTable;
	
	NSNetServiceBrowser* browser;
	NSMutableArray* localGameServices;
	
	GameServer* server;
	
	BGClient* client;


	PrefsController* prefControl;
}


-(IBAction) host:(id)sender;
-(IBAction) join:(id)sender;
-(IBAction) openPrefs:(id)sender;

@end

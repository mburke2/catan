#import "AppControl.h"
#import "Control.h"
#import "Player.h"

#import "GameController.h"
@implementation AppControl

-(IBAction) openPrefs:(id)sender	{
	[prefControl showWindow:nil];
}


-(NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication*)sender	{
//	NSLog(@"should terminate");
	
	if ([[GameController gameController] gameInProgress] == NO)
		return NSTerminateNow;
	
	NSAlert* alert = [NSAlert alertWithMessageText:@"Are you sure you want to quit?" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@"There is a game in progress."];
	int result = [alert runModal];
	
	if (result == 1)
		return NSTerminateNow;

	return NSTerminateCancel;
}


-(void) applicationWillTerminate:(NSNotification*)note	{
//	[server release];
	NSLog(@"will terminate");
//	[
	[server kill];
//	[self release];
}
-(id) init	{
	self = [super init];
	if (self)	{
		prefControl = [[PrefsController alloc] init];
		[NSBundle loadNibNamed:@"CatanPrefs" owner:prefControl];

		connected = NO;
		srand(time(0));
		hosting = NO;
		server = nil;
		localGameServices = [[NSMutableArray alloc] init];
		browser = [[NSNetServiceBrowser alloc] init];
		[browser setDelegate:self];
		[browser searchForServicesOfType:@"_catanService._tcp." inDomain:@"local."];
//		[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(blah:) userInfo:nil repeats:NO];
//		[NSApp setApplicationIconImage:[NSImage imageNamed:@"catanIcon.tiff"]];

	}
	return self;
	
}

-(void) blah:(NSTimer*)t	{
	NSLog(@"stopping browser");
	[browser stop];
}

-(void) dealloc	{
	NSLog(@"deallocing appcontrol");
	[server release];
	[super dealloc];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing	{
	[aNetService retain];
	[aNetService setDelegate:self];
	[aNetService resolveWithTimeout:10];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing	{
	[localGameServices removeObject:aNetService];
	[localGamesTable reloadData];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict	{
	NSLog(@"couldn't resolve service, %@, %@", [sender name], errorDict);
}


- (void)netServiceDidResolveAddress:(NSNetService *)sender	{
	[localGameServices addObject:sender];
	[localGamesTable reloadData];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser	{
	NSLog(@"searching stopped completely");
//	[browser release];
}










-(void) applicationDidFinishLaunching:(NSNotification*)note	{
//	NSLog(@"launched");
	
//	Control* c = [[Control alloc] init];
//	[NSBundle loadNibNamed:@"GameControl.nib" owner:c];
}
/*
-(void) awakeFromNib	{
	[[[[localGamesTable tableColumns] objectAtIndex:0] dataCell] setEditable:NO];
	[localGamesTable setTarget:self];
	[localGamesTable setDoubleAction:@selector(tableDoubleClicked:)];
}
-(void) tableDoubleClicked:(id)sender	{
	int row = [localGamesTable clickedRow];
//	NSLog(@"clicked row, %d", row);
}*/

-(IBAction) host:(id)sender	{
	if (hosting || connected)
		return;
	server = [[GameServer alloc] init];
//	[server setNumberOfPlayers:[numPlayersField intValue]];
	[server listen];
	[server setGameName:[nameField stringValue]];
	hosting = YES;
//	NSLog(@"listening");
	NSDate* stallDate = [NSDate date];
	int jc = 0;
	while (-[stallDate timeIntervalSinceNow] < 3.0)
		jc++;
	NSLog(@"going to join, jc = %d", jc);
	[self join:nil];
//	[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(connectToServer:) userInfo:nil repeats:NO];

}


-(IBAction) join:(id)sender	{
	if (connected)
		return;
	int i;
	NSString* address = nil;
	int portNumber = 34567;
	if (server)	{
		address = @"127.0.0.1";
		portNumber = [server portNumber];
	} 
	else if ([[addField stringValue] isEqualToString:@""] == NO)	{
		NSString* wholeAddress = [addField stringValue];
		NSArray* addressComponents = [wholeAddress componentsSeparatedByString:@":"];
		address = [addressComponents objectAtIndex:0];
		if ([addressComponents count] > 1)
			portNumber = [[addressComponents objectAtIndex:1] intValue];
	}
	else if ([localGamesTable selectedRow] >= 0)	{
		NSArray* srvcAdds = [[localGameServices objectAtIndex:[localGamesTable selectedRow]] addresses];
//		NSLog(@"srvcsAdds = %@,\n\n count = %d", srvcAdds, [srvcAdds count]);
		for (i =  0; i < [srvcAdds count]; i++)	{
			if ([[srvcAdds objectAtIndex:i] length] == 16)	{
				NSData* data = [srvcAdds objectAtIndex:i];
				unsigned char bytes[16] = {0};
				[data getBytes:bytes];
				address = [NSString stringWithFormat:@"%d.%d.%d.%d",
					bytes[4], bytes[5], bytes[6], bytes[7]];
				portNumber = 256 * bytes[2] + bytes[3];
			}
//			NSLog(@"%@", [[srvcAdds objectAtIndex:i] stringValue]);
		}
	}
	else
		return;
	
	client = [[BGClient alloc] init];
	[client setOwner:self];
	
	NSDate* date = [NSDate date];
	while (-[date timeIntervalSinceNow] < 2.0)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	if ([client connectToIP:address portNumber:portNumber])	{
		[window close];
		[browser stop];
		connected = YES;
	}
	else	{
		#warning SHOULD DO SOMETHING HERE
		NSLog(@"couldn't connect");
	}
//-(BOOL) connectToIP:(NSString*)ipAddress portNumber:(int)pn;
}

#pragma mark CLIENT OWNER METHODS
-(NSString*) name	{
	return [nameField stringValue];
}

-(void) infoChanged:(NSArray*)keys	{
	NSLog(@"info changed, appControl doesn't care though");
}

-(void) connectionIsEstablished	{
	NSDictionary* info = [client infoDictionary];
	
//	NSLog(@"myIndex = %d", [theClient index]);
//	myIndex = [theClient index];
	NSArray* keys = [self keysForPlayer:[client index] inInfoDict:info];
	int i;
	NSArray* pieces;
	NSString* piece;
	NSString* name = nil;
	NSColor* color = nil;
	for (i = 0; i < [keys count]; i++)	{
		pieces = [[keys objectAtIndex:i] componentsSeparatedByString:@":"];
		piece = [pieces objectAtIndex:1];
		if ([piece isEqualToString:@"NAME"])	{
			//[self setName:[info objectForKey:[keys objectAtIndex:i]]];
			name = [info objectForKey:[keys objectAtIndex:i]];
		}
		else if ([piece isEqualToString:@"COLOR"])	{
			color = [info objectForKey:[keys objectAtIndex:i]];
//			[self setColor:[info objectForKey:[keys objectAtIndex:i]]];
		}
//		else if ([piece isEqualToString:@"READY"])
	}
//	NSLog(@"loading window");
	[self loadSetupWindowAsHost:hosting name:name color:color];

}
#pragma mark END CLIENT METHODS
-(IBAction) oldjoin:(id)sender	{
	int i;
	
//	NSLog(@"joining");
	if (connected)
		return;
//	[self connectToServer:nil];
//	NSString* name = [nameField stringValue];
	NSString* address = nil;
	if (server)	{
//		NSLog(@"server exists");
		address = [NSString stringWithFormat:@"127.0.0.1:%d", [server portNumber]];
		
	}
	else if ([[addField stringValue] isEqualToString:@""] == NO)	{
		address = [addField stringValue];
		NSLog(@"using address, %@", address);

		if ([address rangeOfString:@":"].location == NSNotFound)
			address = [NSString stringWithFormat:@"%@:34567", address];
	}
	else if ([localGamesTable selectedRow] >= 0)	{
//		NSLog(@"connecting locally");
		NSArray* srvcAdds = [[localGameServices objectAtIndex:[localGamesTable selectedRow]] addresses];
//		NSLog(@"srvcsAdds = %@,\n\n count = %d", srvcAdds, [srvcAdds count]);
		for (i =  0; i < [srvcAdds count]; i++)	{
			if ([[srvcAdds objectAtIndex:i] length] == 16)	{
				NSData* data = [srvcAdds objectAtIndex:i];
				unsigned char bytes[16] = {0};
				[data getBytes:bytes];
				address = [NSString stringWithFormat:@"%d.%d.%d.%d:%d",
					bytes[4], bytes[5], bytes[6], bytes[7], 256 * bytes[2] + bytes[3]];
			}
//			NSLog(@"%@", [[srvcAdds objectAtIndex:i] stringValue]);
		}
	}	
	else	{
//		NSLog(@"doing nothing");
		return;
	}
	GameClient* client = [[GameClient alloc] init];
//	BGClient* client = [[BGClient alloc] init];
//	[client setOwner:self];
	[client setHost:hosting];
	[client setName:[nameField stringValue]];
//	[client connect:[addField stringValue]];
//	[NSTimer scheduledTimerWithTimeInterval:1.0 target:client selector:@selector(connect:
	NSDate* date = [NSDate date];
	while (-[date timeIntervalSinceNow] < 1.0)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	[client connect:address];
//	[client loadSetupWindowAsHost:hosting];
//	NSColor* color = [client color];
	
	connected = YES;
	[window close];
}

-(void) connectToServer:(NSTimer*)timer	{
//	NSLog(@"going to connect");

}

-(int) numberOfRowsInTableView:(NSTableView*)tv	{
	return [localGameServices count];
}

-(id) tableView:(NSTableView*)tv objectValueForTableColumn:(NSTableColumn*)tc row:(int)r	{
	return [[localGameServices objectAtIndex:r] name];
}


#pragma mark SOME UTILITY METHODS
-(NSArray*) keysForPlayer:(int)n inInfoDict:(NSDictionary*)dict	{
	NSString* targetString = [NSString stringWithFormat:@"%d", n];
	NSMutableArray* result = [NSMutableArray array];
	NSArray* keys = [dict allKeys];
	int i;
	NSArray* pieces;
	for (i = 0; i < [keys count]; i++)	{
		pieces = [[keys objectAtIndex:i] componentsSeparatedByString:@":"];
		if ([pieces count] > 0 && [[pieces objectAtIndex:0] isEqualToString:targetString])
			[result addObject:[keys objectAtIndex:i]];
	}
	return result;
}
-(NSArray*) playerArrayForInfo:(NSDictionary*)dict	{
	int i, j;
	NSArray* keys;
	NSMutableDictionary* newDict;
	NSArray* pieces;
	NSMutableArray* result = [NSMutableArray array];
	for (i = 0; i < 4; i++)	{
		keys = [self keysForPlayer:i inInfoDict:dict];
		if ([keys count] > 0)	{
			newDict = [NSMutableDictionary dictionary];
			for (j = 0; j < [keys count]; j++)	{
				pieces = [[keys objectAtIndex:j] componentsSeparatedByString:@":"];
				[newDict setObject:[dict objectForKey:[keys objectAtIndex:j]] forKey:[pieces objectAtIndex:1]];
			}
			[result addObject:newDict];
		}
	}
	return result;
}

-(void) loadSetupWindowAsHost:(BOOL)hostFlag name:(NSString*)name color:(NSColor*)myColor	{
	NSDictionary* info = [client infoDictionary];
	NSData* boardInfo = [[info objectForKey:@"BOARD"] objectAtIndex:0];
	NSData* prefs = [info objectForKey:@"PREFS"];
	NSDictionary* prefsDict = [NSUnarchiver unarchiveObjectWithData:prefs];
	NSArray* players = [self playerArrayForInfo:info];
	GameSetupController* setup = [[GameSetupController alloc] initWithServer:client name:name color:myColor board:boardInfo prefs:prefsDict asHost:hostFlag];
	[client setOwner:setup];
//	NSLog(@"created setup");
	int i;
	for (i = 0; i < [players count]; i++)	{
		[setup addPlayer:[players objectAtIndex:i]];
	}
//	NSLog(@"loading nib");
	[NSBundle loadNibNamed:@"GameSetup.nib" owner:setup];
//	NSLog(@"loaded");
}


#pragma mark END UTILITY METHODS
@end

//
//  main.m
//  catan
//
//  Created by James Burke on 12/29/07.
//  Copyright __MyCompanyName__ 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JunkAnimation.h"


int main(int argc, char *argv[])
{
	NSAutoreleasePool* startupPool = [[NSAutoreleasePool alloc] init];

//	[NSApp setApplicationIconImage:[NSImage imageNamed:@"catanIcon.tiff"]];
	
	[startupPool release];
    return NSApplicationMain(argc,  (const char **) argv);
}

//
//  NSSocketPort-Additions.h
//  catan
//
//  Created by James Burke on 1/28/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSSocketPort (Additions)

-(int) portNumber;
-(NSString*) ipAddress;

@end

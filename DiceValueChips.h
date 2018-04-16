//
//  DiceValueChips.h
//  catan
//
//  Created by James Burke on 1/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DiceValueChips : NSObject {

}

+(NSImage*) imageForValue:(int)n size:(NSSize)sz letter:(char)letter;
@end

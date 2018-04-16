//
//  NSImage-Additions.h
//  catan
//
//  Created by James Burke on 2/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSShadow-Additions.h"

@interface NSImage (Additions)

-(NSImage*) imageByFlippingHorizontally;
-(NSImage*) imageByFlippingVertically;
-(NSImage*) imageByRotatingDegrees:(int)d;
-(NSImage*) shadowedImage;
+(NSImage*) shadowedImageWithImage:(NSImage*)image;

@end

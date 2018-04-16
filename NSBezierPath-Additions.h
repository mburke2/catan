//
//  NSBezierPath-Additions.h
//  catan
//
//  Created by James Burke on 2/4/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBezierPath (Additions)

+(NSBezierPath*) bezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)rad;
+(NSBezierPath*) thinRect:(NSRect)rect;
-(NSBezierPath*) bezierPathByFlippingHorizontally;
@end

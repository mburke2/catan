/* DiceView */

#import <Cocoa/Cocoa.h>

@interface DiceView : NSView	{
	int diceVal1;
	int diceVal2;
	
	int tempVal1;
	int tempVal2;
	
	NSColor* highlightColor;
	
	NSDate* animationStartTime;
	
	
	
	float animationLength;
	
	
	NSRect r1;
	NSRect r2;
	NSRect imgRect;
	
}

-(void) setValue1:(int)v1 value2:(int)v2 color:(NSColor*)color;
-(float) animationLength;
@end

#import "DiceView.h"

#import "Debug.h"
@implementation DiceView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		diceVal1 = 0;
		diceVal2 = 0;
		tempVal1 = 0;
		tempVal2 = 0;
		highlightColor = nil;
		animationStartTime = nil;
		
		if (DEBUG_MODE)
			animationLength = 0;
		else
			animationLength = 1.2;
		
		r1 = NSMakeRect(2, 2, 32, 32);
		r2 = NSMakeRect(36, 2, 32, 32);
		imgRect = NSMakeRect(0, 0, 32, 32);
	}
	return self;
}

- (void)drawRect:(NSRect)rect	{

	if (tempVal1 > 0 && tempVal2 > 0 && highlightColor != nil)	{
		NSImage* image1 = [NSImage imageNamed:[NSString stringWithFormat:@"Face%d.png", tempVal1]];
		NSImage* image2 = [NSImage imageNamed:[NSString stringWithFormat:@"Face%d.png", tempVal2]];
		[[highlightColor colorWithAlphaComponent:0.5] set];
		[NSBezierPath fillRect:[self bounds]];
		
		[image1 drawInRect:r1 fromRect:imgRect operation:NSCompositeSourceOver fraction:1.0];
		[image2 drawInRect:r2 fromRect:imgRect operation:NSCompositeSourceOver fraction:1.0];
	}
}


-(void) setValue1:(int)v1 value2:(int)v2 color:(NSColor*)color	{
//	NSLog(@"setting value");
	diceVal1 = v1;
	diceVal2 = v2;
	[color release];
	highlightColor = [color retain];

//	[NSThread detachNewThreadSelector:@selector(beginAnimation:) toTarget:self withObject:nil];
	
//}
//-(void) beginAnimation:(id)obj	{
//	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[animationStartTime release];
	animationStartTime = [NSDate date];
	[animationStartTime retain];
//	NSLog(@"starting timer");
	[NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(updateAnimation:) userInfo:nil repeats:YES];
//	[pool release];
}

-(void) updateAnimation:(NSTimer*)t	{
//	NSLog(@"updating animation");
	tempVal1 = 1 + rand() % 6;
	tempVal2 = 1 + rand() % 6;
	
	if (-[animationStartTime timeIntervalSinceNow] > animationLength)	{
		tempVal1 = diceVal1;
		tempVal2 = diceVal2;
		[t invalidate];
	}
	
	[self setNeedsDisplay:YES];
}

-(float) animationLength	{
	return animationLength;
}

-(void) reportError	{
	NSLog(@"skkh!!!>LKHH@!!! WHAT? THIS IS BAD");
}


@end

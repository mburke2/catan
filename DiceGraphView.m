#import "DiceGraphView.h"
#import "RollFrequencyController.h"
float maxVal(float f1, float f2)	{
	if (f1 > f2)
		return f1;
	return f2;
}
@implementation DiceGraphView



- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		int i;
		for (i = 0; i < 11; i++)	{
			rolls[i] = 0;
		}
		leftMargin = [[[[NSAttributedString alloc] initWithString:@"5555" attributes:nil] autorelease] size].width + 3;
		topMargin = [[[[NSAttributedString alloc] initWithString:@"Total:" attributes:nil] autorelease] size].height + 2;
		bottomMargin = [[[[NSAttributedString alloc] initWithString:@"11" attributes:nil] autorelease] size].height + 2;
		
		[self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		total = 0;
		max = 0;
	}
	return self;
}

-(void) dealloc	{
//	NSLog(@"deallocing view");
	[super dealloc];
}

-(void) awakeFromNib	{
//	NSLog(@"view is waking");
//	NSLog(@"data source = %@", dataSource);
}

- (void)drawRect:(NSRect)rect	{
//	[[NSColor blueColor] set];
//	[NSBezierPath strokeRect:[self bounds]];
	[self drawGraph];
	[self drawScale];
}

-(void) drawGraph	{
//	float barWidth = [self bounds].size.width / 11;	
	float h;
	int i;
	NSPoint p = NSMakePoint(leftMargin, bottomMargin);
	NSRect barRect;
//	NSAttributedString* str;
	float barWidth = [self barWidth];
	NSBezierPath* expectedPath;
	for (i = 0; i < 11; i++)	{
		h = [self heightForVal:rolls[i]];
//		str = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", rolls[i]] attributes:nil] autorelease];
		barRect = NSMakeRect(p.x, p.y, barWidth, h);
		[[[NSColor lightGrayColor] colorWithAlphaComponent:0.3] set];
		[NSBezierPath fillRect:barRect];
		[[NSColor blackColor] set];
		[NSBezierPath strokeRect:barRect];
	//	[str drawAtPoint:NSMakePoint(p.x + (barWidth - [str size].width) / 2, p.y)];
		h = [self heightForVal:[self expectedValueFor:i + 2]];
		expectedPath = [NSBezierPath bezierPath];
		[expectedPath moveToPoint:NSMakePoint(p.x, h + bottomMargin)];
		[expectedPath lineToPoint:NSMakePoint(p.x + barWidth, h + bottomMargin)];
		[[NSColor greenColor] set];
		[expectedPath stroke];
		p.x += barWidth;
	}
	

}

-(int) makeScale:(int[10])scale	{
	scale[0] = 1 * max / 4;
	scale[1] = 2 * max / 4;
	scale[2] = 3 * max / 4;
//	scale[3] = 4 * max / 7;
//	scale[4] = 5 * max / 7;
//	scale[5] = 6 * max / 7;
	return 3;
}

-(float) barWidth	{
	return  ([self bounds].size.width - leftMargin) / 11.0;
}

-(void) drawScale	{
//	[[NSColor redColor] set];
//	[NSBezierPath strokeRect:[self bounds]];
	
	[[NSColor blackColor] set];
//	path = [self thinHorizontalLineFromPoint
	NSBezierPath* path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(0, bottomMargin)];
	[path lineToPoint:NSMakePoint([self bounds].size.width, bottomMargin)];
	
	[path stroke];
	
	path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(leftMargin, 0)];
	[path lineToPoint:NSMakePoint(leftMargin, [self bounds].size.height - topMargin)];
	[path stroke];
	
	path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(0, [self bounds].size.height - topMargin)];
	[path lineToPoint:NSMakePoint([self bounds].size.width, [self bounds].size.height - topMargin)];
	[path stroke];
	
	
	int i;
	NSAttributedString* attStr;
	float barWidth = [self barWidth];
	NSPoint p = NSMakePoint(leftMargin, 0);
	for (i = 0; i < 11; i++)	{
		attStr = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", i + 2] attributes:nil] autorelease];
		[attStr drawAtPoint:NSMakePoint(p.x + (barWidth - [attStr  size].width) / 2, (bottomMargin - [attStr size].height) / 2)];
		p.x += barWidth;
	}
	
	int scale[10] = {0};
	int steps = [self makeScale:scale];
	float stepHeight = ([self bounds].size.height - (topMargin + bottomMargin)) / (steps + 1);
	float dashPattern[2] = {6.0, 14.0};
	float height;// = stepHeight + bottomMargin;
//	[[NSColor redColor] set];
	for (i = 0; i < steps; i++)	{
		height = [self heightForVal:scale[i]] + bottomMargin;
		path = [NSBezierPath bezierPath];
		[path moveToPoint:NSMakePoint(leftMargin, height)];
		[path lineToPoint:NSMakePoint([self bounds].origin.x + [self bounds].size.width,   height)];
		[path setLineDash:dashPattern count:2 phase:10];
		[[NSColor redColor] set];
		[path stroke];
		attStr = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", scale[i]] attributes:nil] autorelease];
		[attStr drawAtPoint:NSMakePoint((leftMargin - [attStr size].width) / 2, height - [attStr size].height / 2)];
		height += stepHeight;
	}
	
	
	attStr = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Total: %d", total] attributes:nil] autorelease];
	[attStr drawAtPoint:NSMakePoint(3, [self bounds].size.height - topMargin)];
}

-(float) expectedValueFor:(int)v	{
	v = abs(7 - v);
	v = abs(6 - v);
	
	return total * (v / 36.0);
}

-(float) heightForVal:(float)val	{
	float realMax = maxVal(max, [self expectedValueFor:7]);
	float f =  ((val * 1.0) / (1.0 * realMax)) * ([self bounds].size.height - (topMargin + bottomMargin));
//	NSLog(@"val = %f, height = %f", val, f);
	return f;
}

-(void) addRoll:(int)r	{
	rolls[r - 2]++;
	if (rolls[r - 2] > max)
		max = rolls[r - 2];
	total++;
	[self setNeedsDisplay:YES];
}


-(void) update	{
//	NSLog(@"updating");
//	[dataSource getRolls:rolls];
	NSArray* tmp = [dataSource getRolls];
//	NSLog(@"tmp = %@", tmp);
	int i;
	total = 0;
	max = 0;
	for (i = 0; i < 11; i++)	{
		rolls[i] = [[tmp objectAtIndex:i] intValue];
//		NSLog(@"got rolls, v = %d, total = %d", i + 2, rolls[i]);
		total += rolls[i];
		if (rolls[i] > max)
			max = rolls[i];
	}
	[self setNeedsDisplay:YES];
}

-(NSBezierPath*) thinStraightLineFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2	{

	
}

@end

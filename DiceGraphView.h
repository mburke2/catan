/* DiceGraphView */

#import <Cocoa/Cocoa.h>

@class RollFrequencyController;
@interface DiceGraphView : NSView	{
	int rolls[11];
	int total;
	
	float leftMargin;
	float topMargin;
	float bottomMargin;
	float max;
	
	IBOutlet RollFrequencyController* dataSource;
}
-(float) heightForVal:(float)val;
-(void) addRoll:(int)r;
-(float) expectedValueFor:(int)v;
-(float) barWidth;
-(int) makeScale:(int[10])scale;
@end

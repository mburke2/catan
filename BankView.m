//
//  BankView.m
//  catan
//
//  Created by James Burke on 1/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BankView.h"
#import "NSBezierPath-Additions.h"
#import "DEBUG.h"
#define PP NSLog(@"%s", __FUNCTION__)

@implementation BankView

-(id) initWithFrame:(NSRect)frame	{
//	PP;
	self = [super initWithFrame:frame];
	if (self)	{
		isActive = NO;
		draggingInProgress = NO;
		tradeValue = 0;
		monopolize = NO;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yopCardPlayed:) name:@"YoPNote" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(monopolyPlayed:) name:@"MonopolyNote" object:nil];
		
		int i;
		resources = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
		[resources retain];
		float margin = 6;
		NSSize sz = NSMakeSize((frame.size.width - (6 * margin))/ 5.0,  frame.size.height - 14);
		NSPoint p = NSMakePoint(margin, 0);
		for (i = 0; i < 5; i ++)	{
			resourceRects[i] = NSMakeRect(p.x, p.y, sz.width, sz.height);
			p.x += (margin + sz.width);
		}
		
	}
	return self;
}

-(void) monopolyPlayed:(NSNotification*)note	{
	monopolize = YES;
	tradeValue = 1;
	[self setNeedsDisplay:YES];
//	isActive = YES;
}
-(void) yopCardPlayed:(NSNotification*)note	{
//	NSLog(@"getting yop notif");
	tradeValue += 2;
	[self setNeedsDisplay:YES];
}

-(void) drawRect:(NSRect)rect	{
	int i;
	NSImage* image;
	for (i = 0; i < 5; i++)	{
		image = [NSImage imageNamed:[NSString stringWithFormat:@"%@Res", [resources objectAtIndex:i]]];
		[image drawInRect:resourceRects[i] fromRect:NSMakeRect(0, 0, [image size].width, [image size].height)  operation:NSCompositeSourceOver fraction:1.0];
	}
	NSString* string;
	if (monopolize)
		string = @"Choose resource to monopolize:";
	else if (tradeValue > 1)
		string = [NSString stringWithFormat:@"Choose %d resources:", tradeValue];
	else if (tradeValue == 1)
		string = @"Choose 1 resource:";
	else
		string = @"Bank";
	
	NSAttributedString* attString = [[[NSAttributedString alloc] initWithString:string] autorelease];
//	NSAttributedString* bank = [[[NSAttributedString alloc] initWithString:@"Bank"] autorelease];
	[attString drawAtPoint:NSMakePoint(2, [self bounds].size.height - [attString size].height)];
	if (draggingInProgress)	{
		[[NSColor blackColor] set];
		NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:10];
		[path stroke];
	}
		

}	


-(void) olddrawRect:(NSRect)rect	{
//	PP;
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:rect];
	
	[[NSColor blackColor] set];
	[NSBezierPath strokeRect:rect];
	
	NSPoint p;
//	if (isActive == NO)	{
	if (tradeValue == 0)	{
		NSAttributedString* bank = [[[NSAttributedString alloc] initWithString:@"Bank" attributes:nil] autorelease];
		p = NSMakePoint([self bounds].size.width / 2, [self bounds].size.height / 2);
		p.x -= [bank size].width / 2;
		p.y -= [bank size].height / 2;
		[bank drawAtPoint:p];
		return;
	}
	
	
	int i;
	NSString* str;
	if (monopolize)
		str = @"Choose resource to monopolize.";
	else
		str = [NSString stringWithFormat:@"Take %d resource cards.", tradeValue];
		
	NSAttributedString* tradeValueString = [[[NSAttributedString alloc] initWithString:str attributes:nil] autorelease];
	
	[tradeValueString drawAtPoint:NSMakePoint(3, [self bounds].size.height - [tradeValueString size].height)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0, [self bounds].size.height - [tradeValueString size].height)
		toPoint:NSMakePoint([self bounds].size.width, [self bounds].size.height - [tradeValueString size].height)];
	NSArray* strs = [NSArray arrayWithObjects:@"Brick", @"Wood", @"Sheep", @"Grain", @"Ore", nil];
	NSAttributedString* res;
	for (i = 0; i < 5; i++)	{
		[NSBezierPath strokeLineFromPoint:NSMakePoint( (i + 1) * ([self bounds].size.width / 5.0), 0)
			toPoint:NSMakePoint( (i + 1) * ([self bounds].size.width / 5.0), [self bounds].size.height - [tradeValueString size].height)];
		
		p = NSMakePoint( ((2 * i + 1) * ([self bounds].size.width / 5.0)) / 2.0, [self bounds].size.height / 2.0);
		res = [[[NSAttributedString alloc] initWithString:[strs objectAtIndex:i] attributes:nil] autorelease];
		p.x -= [res size].width / 2;
		p.y -= [res size].height / 2;
		
		[res drawAtPoint:p];
	}
	
	

}

-(NSDragOperation) draggingEntered:(id <NSDraggingInfo>)sender	{
	if ([[GameController gameController] localPlayerMustDiscard])	{
		return NSDragOperationNone;
	}
	
	if ([[GameController gameController] localPlayer] != [[GameController gameController] currentPlayer])
		return NSDragOperationNone;

	if (tradeValue > 0)
		return NSDragOperationNone;
//	if (isActive)
//		return NSDragOperationNone;
//	NSArray* propertyList = [[sender draggingPasteboard] propertyListForType:@"CATAN_RESOURCE_TYPE"];
//	if ([propertyList count] >= 4)	{
//		//NSString* res = [propertyList objectAtIndex:0];
//		return NSDragOperationCopy;
//	}
	draggingInProgress = YES;
	[self setNeedsDisplay:YES];
	return NSDragOperationCopy;
//	return NSDragOperationNone;
}

-(void) draggingExited:(id <NSDraggingInfo>)sender	{
	draggingInProgress = NO;
	[self setNeedsDisplay:YES];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender	{
	PP;
	
	if ([[GameController gameController] localPlayerMustDiscard])	{
		[[GameController gameController] player:[[GameController gameController] localPlayer] discarded:[[sender draggingPasteboard] propertyListForType:@"CATAN_RESOURCE_TYPE"]];
		return YES;
	}
	if ([[GameController gameController] localPlayer] != [[GameController gameController] currentPlayer])
		return NO;
//	if (isActive)
//		return NO;
	if (tradeValue > 0)
		return NO;
	NSArray* propertyList = [[sender draggingPasteboard] propertyListForType:@"CATAN_RESOURCE_TYPE"];
//	NSLog(@"pList = %@", propertyList);

	tradeValue = [[GameController gameController] bankValueForTrade:propertyList];
	draggingInProgress = NO;
	[self setNeedsDisplay:YES];

	if (tradeValue > 0)	{
//		[[GameController gameController] makeCurrentPlayerSpend:propertyList];
		[[GameController gameController] makeCurrentPlayerGiveResourcesToBank:propertyList];
		return YES;
	}
	return NO;
//	if ([propertyList count] == 4)	{
//	NSString* res;
/*
	if ([[GameController gameController] currentPlayerCanTradeToBank:propertyList])	{
//	if ([[GameController
		res = [propertyList objectAtIndex:0];
		int i;
		for (i = 1; i < 4; i++)	{
			if ([res isEqualToString:[propertyList objectAtIndex:i]] == NO)
				return NO;
		}
//		NSLog(@"here");
		isActive = YES;
//		NSLog(@"and here");
		[[GameController gameController] makeCurrentPlayerSpend:propertyList];
		[self setNeedsDisplay:YES];
//		NSLog(@"and returning yes");
		//NSString* res = [propertyList objectAtIndex:0];
		return YES;
	}
	
	return NO;
	*/
}


-(void) mouseDown:(NSEvent*)event	{
//	if (isActive == NO)
//		return;

	if (tradeValue == 0 && DEBUG_MODE == 0)
		return;
	NSPoint p = [event locationInWindow];
	p = [self convertPoint:p fromView:[[self window] contentView]];
//	p.x -= [self frame].origin.x;
//	p.y -= [self frame].origin.y;
	
	NSString* res = nil;
//	if (p.x <= [self bounds].size.width / 5)
//		res = @"Brick";
//	else if (p.x <= 2 * ([self bounds].size.width) / 5)
//		res = @"Wood";
//	else if (p.x <= 3 * ([self bounds].size.width) / 5)
//		res = @"Sheep";
//	else if (p.x <= 4 * ([self bounds].size.width) / 5)
//		res = @"Grain";
//	else
//		res = @"Ore";
	int i;
	int clickedIndex = -1;
	for (i = 0; i < 5; i++)	{
		if (NSMouseInRect(p, resourceRects[i], NO))
			clickedIndex = i;
	}
	
	if (clickedIndex >= 0)
		res = [resources objectAtIndex:clickedIndex];
	if (monopolize)
		[[GameController gameController] monopolize:res];
	else	{
		//[[GameController gameController] giveResource:res];
		[[GameController gameController] giveResourceToCurrentPlayerFromBank:res];
	}
//	isActive = NO;
	if (DEBUG_MODE == 0)
		tradeValue--;
	if (monopolize)
		monopolize = NO;
	[self setNeedsDisplay:YES];
}


-(NSRect) rectForResource:(NSString*)res	{
	int index = [resources indexOfObject:res];
	return resourceRects[index];
}



@end

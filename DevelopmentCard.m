//
//  DevelopmentCard.m
//  catan
//
//  Created by James Burke on 1/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DevelopmentCard.h"
#import "GameController.h"

@implementation DevelopmentCard

-(id) init	{
	self = [super init];
	if (self)	{
		myType = nil;
		playableFlag = NO;
	}
	return self;
}
+(DevelopmentCard*) cardWithType:(NSString*)type	{
	DevelopmentCard* c = [[DevelopmentCard alloc] init];
	[c autorelease];
	[c setType:type];
	
	return c;
//	return myType;
}	
-(void) setType:(NSString*)str	{
	[myType release];
	myType = [str copy];
	[myType retain];
}
-(NSString*) type	{
//	NSLog(@"asking for type");
	return myType;
}

-(BOOL) playable	{
	return playableFlag;
}

-(void) setPlayable:(BOOL)flag	{
	playableFlag = flag;
}


@end

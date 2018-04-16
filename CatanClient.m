//
//  CatanClient.m
//  catan
//
//  Created by James Burke on 7/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CatanClient.h"


@implementation CatanClient

-(id) init	{
	self = [super init];
	if (self)	{
		[self setOwner:self];
	}
	return self;
}

-(void) infoChanged:(NSDictionary*)dict	{
	
}
@end

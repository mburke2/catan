//
//  ResourceTable.m
//  catan
//
//  Created by James Burke on 1/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ResourceTableView.h"


@implementation ResourceTableView

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation	{
	//NSLog(@"%s, drag ended, operation = %d",__FUNCTION__, operation);
	[[self dataSource] draggedImage:anImage endedAt:aPoint operation:operation];
}
@end

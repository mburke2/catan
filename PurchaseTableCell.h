//
//  PurchaseTableCell.h
//  catan
//
//  Created by James Burke on 1/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PurchaseTableCell : NSCell {
	BOOL enabled;
	BOOL selected;
}

-(void) setSelected:(BOOL)flag;
-(void) setEnabled:(BOOL)flag;
@end

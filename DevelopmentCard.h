//
//  DevelopmentCard.h
//  catan
//
//  Created by James Burke on 1/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import 

@interface DevelopmentCard : NSObject {
	NSString* myType;
	BOOL playableFlag;
}

+(DevelopmentCard*) cardWithType:(NSString*)type;
-(void) setType:(NSString*)str;
-(NSString*) type;
-(BOOL) playable;
-(void) setPlayable:(BOOL)flag;
-(void) playCard;

@end

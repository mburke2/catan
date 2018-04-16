//
//  PurchaseTable.m
//  catan
//
//  Created by James Burke on 12/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PurchaseTableView.h"
#import "GameController.h"

@implementation PurchaseTableView

-(id) initWithFrame:(NSRect)rect	{
//	NSLog(@"%s", __FUNCTION__);
	self = [super initWithFrame:rect];
	if (self)	{
		cityImage = nil;
		roadImage = nil;
		settlementImage = nil;
		devCardImage = nil;
	}
	return self;
}
- (NSImage *)dragImageForRowsWithIndexes:(NSIndexSet *)dragRows tableColumns:(NSArray *)tableColumns event:(NSEvent*)dragEvent offset:(NSPointPointer)dragImageOffset	{
	
//    NSLog(@"%s", __FUNCTION__);
	*dragImageOffset = NSMakePoint(-5, 5);
	NSImage* img = nil;
	int index = [dragRows firstIndex];
	if (index == 0)
		img =  [self roadImage];
	else if (index == 1)
		img =  [self settlementImage];
	else if (index == 2)
		img =  [self cityImage];
	else
		img =  [self devCardImage];
	
	NSImage* returnImage = [[[NSImage alloc] initWithSize:[img size]] autorelease];
	NSRect rect = NSMakeRect(0, 0, [img size].width, [img size].height);
	[returnImage lockFocus];
	[img drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:0.75];
	[returnImage unlockFocus];
	
	return returnImage;
//	else
//		NSLog(@"SHOULDN"T H
		/*
	NSBezierPath* triPath = [NSBezierPath bezierPath];
	[triPath moveToPoint:NSMakePoint(0, 0)];
	[triPath lineToPoint:NSMakePoint(8, 18)];
	[triPath lineToPoint:NSMakePoint(18, 0)];
	[triPath lineToPoint:NSMakePoint(0, 0)];
	
	NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(18, 18)];
	[image lockFocus];
	[[NSColor blueColor] set];
	[triPath fill];
	[image unlockFocus];
	
	return image;
	*/
}


-(NSImage*) roadImage	{
	if (roadImage)
		return roadImage;
	
//	NSImage* base = [NSImage imageNamed:[NSString stringWithFormat:@"road%dNewRoad.png", myOrientation]];
	NSImage* base = [NSImage imageNamed:@"road0NewRoad.png"];
	NSRect baseRect = NSMakeRect(0, 0, [base size].width, [base size].height);
//	NSLog(@"baseRect = %@", NSStringFromRect(baseRect));
//	NSImage* shadow = [NSImage imageNamed:[NSString stringWithFormat:@"road%dNewShadow.png", myOrientation]];
	NSImage* shadow = [NSImage imageNamed:@"road0NewShadow.png"];
	NSImage* colorImage = [[[NSImage alloc] initWithSize:baseRect.size] autorelease];
	[colorImage lockFocus];
//	[[myOwner color] set];
	[[[[GameController gameController] localPlayer] color] set];

	[NSBezierPath fillRect:baseRect];
	[colorImage unlockFocus];
	
	NSImage* colorRoad = [[[NSImage alloc] initWithSize:baseRect.size] autorelease];
	[colorRoad lockFocus];
	[base drawInRect:baseRect fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[colorImage drawInRect:baseRect fromRect:baseRect operation:NSCompositeSourceAtop fraction:0.4];
	[colorRoad unlockFocus];
	
	
//	NSImage* newImage = [[[NSImage alloc] initWithSize:tmpSize] autorelease];
	NSImage* newImage = [[[NSImage alloc] initWithSize:[base size]] autorelease];
//	newImage = [[[NSImage alloc] 
	[newImage setScalesWhenResized:YES];
	
	[newImage lockFocus];
	[shadow drawInRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height) fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[colorRoad drawInRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height) fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[newImage unlockFocus];
	
//	[[newImage TIFFRepresentation] writeToFile:@"/testImage.tiff" atomically:NO];
//	[newImage setSize:mySize];
	[newImage setSize:NSMakeSize(11, 18)];
//	[myImage release];
//	myImage = [newImage retain];
	[roadImage release];
	roadImage = [newImage retain];
	
	return roadImage;
}

-(NSImage*) oldroadImage	{
	if (roadImage)
		return roadImage;
		
	NSImage* image = [[[NSImage alloc] initWithSize:NSMakeSize(18, 18)] autorelease];
//	[image setFlipped:YES];

	NSBezierPath* path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(0, 0)];
	[path lineToPoint:NSMakePoint(18, 18)];
	
	[image lockFocus];
	[[[[GameController gameController] localPlayer] color] set];
//	[[NSColor blueColor] set];
	[path stroke];
	[image unlockFocus];
	roadImage = [image retain];
	return image;
}	
-(NSImage*) settlementImage	{
	if (settlementImage)
		return settlementImage;
		
	settlementImage = [self imageForType:@"settlement"];
	[settlementImage retain];
	return settlementImage;
	NSImage* image = [[[NSImage alloc] initWithSize:NSMakeSize(18, 18)] autorelease];
//	[image setFlipped:YES];
	NSBezierPath* path = [NSBezierPath bezierPath];
	
	[path moveToPoint:NSMakePoint(0, 0)];
	[path lineToPoint:NSMakePoint(9, 18)];
	[path lineToPoint:NSMakePoint(18, 0)];
	[path lineToPoint:NSMakePoint(0,  0)];
	
	[image lockFocus];
	[[[[GameController gameController] localPlayer] color] set];
//	[[NSColor blueColor] set];
	[path fill];
	[image unlockFocus];
	settlementImage = [image retain];
	return image;
}
-(NSImage*) cityImage	{
	if (cityImage)
		return cityImage;
		
	cityImage = [self imageForType:@"city"];
	[cityImage retain];
//	[[cityImage TIFFRepresentation] :@"/smallCity.tiff" atomically:NO];
	return cityImage;
	NSImage* image = [[[NSImage alloc] initWithSize:NSMakeSize(18, 18)] autorelease];
//	[image setFlipped:YES];

	NSBezierPath* path = [NSBezierPath bezierPath];
	
	[path moveToPoint:NSMakePoint(0, 0)];
	[path lineToPoint:NSMakePoint(3, 18)];
	[path lineToPoint:NSMakePoint(6, 0)];
	[path lineToPoint:NSMakePoint(9, 18)];
	[path lineToPoint:NSMakePoint(12, 0)];
	[path lineToPoint:NSMakePoint(15, 18)];
	[path lineToPoint:NSMakePoint(18, 0)];
	[path lineToPoint:NSMakePoint(0, 0)];
	
	[image lockFocus];
	[[[[GameController gameController] localPlayer] color] set];
//	[[NSColor blueColor] set];
	[path fill];
	[image unlockFocus];
	
	cityImage = [image retain];
	return image;
}
-(NSColor*) averageColorForImage:(NSImage*)image	{
	int r = 0;
	int g = 0;
	int b = 0;
//	NSData* dat = [image TIFFRepresentation];
	int i = 0;
	NSColor* c;
//	NSBitmapImageRep* rep = nil;//[[image representations] objectAtIndex:0];
	
//	for (i = 0; i < [[image representations] count]; i++)	{
//		if ([[[image representations] objectAtIndex:i] isKindOfClass:[NSBitmapImageRep class]])
//			rep = [[image representations] objectAtIndex:i];
//	}
	NSBitmapImageRep* rep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
	if (rep == nil)	{
		NSLog(@"COULDN'T FIND REP");
		return [[[GameController gameController] localPlayer] color];
	}
	
	i = 0;
	
	while (i < 50)	{
//		c = [rep colorAtX:rand() % (int)[rep size].width y:rand() % (int)[rep size].height];
		c = [rep colorAtX:8 y:24];
		return c;
		if ([c alphaComponent] == 1)	{
			r += [c redComponent];
			g += [c greenComponent];
			b += [c blueComponent];
			i++;
		}
		
	}
	
	
	return [NSColor colorWithCalibratedRed:(1.0 * r) / i green:(1.0 * g) / i blue:(1.0 * b) / i alpha:1.0];
}
-(NSImage*) devCardImage	{
	if (devCardImage)
		return devCardImage;
	NSImage* image = [[[NSImage alloc] initWithSize:NSMakeSize(18, 18)] autorelease];
//	[image setFlipped:YES];

	NSString* str = @"?";
	NSFont* font = [NSFont boldSystemFontOfSize:14];
//	NSImage* 
//	NSDictionary* atts = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
	NSColor* aColor = [self averageColorForImage:[self cityImage]];
//	NSColor* aColor = [NSColor blackColor];
	NSDictionary* atts = [NSDictionary dictionaryWithObjectsAndKeys:
		font, NSFontAttributeName, 
//		[NSColor blueColor], NSForegroundColorAttributeName, 
//		[[[GameController gameController] localPlayer] color], NSForegroundColorAttributeName,
		aColor, NSForegroundColorAttributeName,

		[NSNumber numberWithFloat:0.10] ,NSObliquenessAttributeName, nil];
	NSAttributedString* attStr = [[NSAttributedString alloc] initWithString:str attributes:atts];
	
	NSSize sz = [attStr size];
//	NSLog(@"sz = %@", NSStringFromSize(sz));
	
//	NSImage* subImage = [[[NSImage alloc] initWithSize:sz] autorelease];
//	[subImage lockFocus];
//	[attStr drawAtPoint:NSMakePoint(0, 0)];
//	[[NSColor blueColor] set];
//	[NSBezierPath strokeRect:NSMakeRect(0, 0, sz.width, sz.height)];
//	[subImage unlockFocus];

	float xMarg = (18 - sz.width) / 2;
	float yMarg = (18 - sz.height) / 2;
	
	[image lockFocus];
//	[subImage drawAtPoint:NSMakePoint(xMarg, yMarg) fromRect:NSMakeRect(0, 0, sz.width, sz.height) operation:NSCompositeCopy fraction:1.0];
	[attStr drawInRect:NSMakeRect(xMarg, yMarg, [attStr size].width, [attStr size].height)];
	[[NSColor blackColor] set];
	[NSBezierPath strokeRect:NSMakeRect(0, 0, 18, 18)];
	[image unlockFocus];
	
	devCardImage = [image retain];
	return image;
}

-(NSImage*) itemImageForRow:(int)r	{
//	NSLog(@"getting image for row %d", r);
	NSImage* returnImage  = nil;
	if (r == 0)
		returnImage =  [self roadImage];
	else if (r == 1)
		returnImage = [self settlementImage];
	else if (r == 2)
		returnImage = [self cityImage];
	else if (r == 3)
		returnImage = [self devCardImage];
	else	
		NSLog(@"SHOULDN'T HAVE GOTTEN TO HERE, %s, %d", __FUNCTION__, r);
		
	
//	NSLog(@"returning it");
	return returnImage;
}

-(CGFloat) rowHeight	{
    /*!!!!!  was -(float) rowHeight... changed it to CGFloat to get the table to render properly in 10.8*/
	return 27.0;
}


/*
	NSImage* base = [NSImage imageNamed:[NSString stringWithFormat:@"road%dNewRoad.png", myOrientation]];
	NSRect baseRect = NSMakeRect(0, 0, [base size].width, [base size].height);
//	NSLog(@"baseRect = %@", NSStringFromRect(baseRect));
	NSImage* shadow = [NSImage imageNamed:[NSString stringWithFormat:@"road%dNewShadow.png", myOrientation]];
	
	NSImage* colorImage = [[[NSImage alloc] initWithSize:baseRect.size] autorelease];
	[colorImage lockFocus];
	[[myOwner color] set];
	[NSBezierPath fillRect:baseRect];
	[colorImage unlockFocus];
	
	NSImage* colorRoad = [[[NSImage alloc] initWithSize:baseRect.size] autorelease];
	[colorRoad lockFocus];
	[base drawInRect:baseRect fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[colorImage drawInRect:baseRect fromRect:baseRect operation:NSCompositeSourceAtop fraction:0.4];
	[colorRoad unlockFocus];
	
	
//	NSImage* newImage = [[[NSImage alloc] initWithSize:tmpSize] autorelease];
	NSImage* newImage = [[[NSImage alloc] initWithSize:[base size]] autorelease];
//	newImage = [[[NSImage alloc] 
	[newImage setScalesWhenResized:YES];
	
	[newImage lockFocus];
	[shadow drawInRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height) fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[colorRoad drawInRect:NSMakeRect(0, 0, [newImage size].width, [newImage size].height) fromRect:baseRect operation:NSCompositeSourceOver fraction:1.0];
	[newImage unlockFocus];
	
	[newImage setSize:mySize];
	[myImage release];
	myImage = [newImage retain];*/



//-(void) buildImage	{

-(NSImage*) fullImageForItemColumnRow:(int)row text:(NSAttributedString*)string  {
    NSImage* itemImage = [self itemImageForRow:row];
    NSImage* stringImage = [[NSImage alloc] initWithSize:[string size]];
    
    [stringImage lockFocus];
    [string drawAtPoint:NSMakePoint(0, 0)];
    [stringImage unlockFocus];
    
    
    float margin = 10.0;
    
    float maxHeight = [itemImage size].height;
    if ([stringImage size].height > maxHeight)
        maxHeight = [stringImage size].height;
    
    NSImage* resultImage = [[NSImage alloc] initWithSize:NSMakeSize([itemImage size].width + [stringImage size].width + 2 * margin, maxHeight)];
    
    
    [resultImage lockFocus];
  
    NSRect srcRect = NSMakeRect(0, 0, [itemImage size].width, [itemImage size].height);
    NSRect destRect = NSMakeRect(margin, 0, [itemImage size].width, [itemImage size].height);
    
    [itemImage drawInRect:destRect fromRect:srcRect operation:NSCompositeSourceOver fraction:1.0];
    
    destRect = NSMakeRect([itemImage size].width + 2 * margin, 0, [stringImage size].width, [stringImage size].height);
    srcRect = NSMakeRect(0, 0, [stringImage size].width, [stringImage size].height);
    
    [stringImage drawInRect:destRect fromRect:srcRect operation:NSCompositeSourceOver fraction:1.0];
//    [itemImage drawInRect:NSMakeRect(0, 0, [itemImage size].width, [itemImage size].height)];
//    [stringImage drawInRect:NSMakeRect([itemImage size].width + margin, 0, [stringImage size].width, [stringImage size].height)];
    
    [resultImage unlockFocus];
    
    
//    [[resultImage TIFFRepresentation] writeToFile:[NSString stringWithFormat:@"/users/mikeburke/desktop/%@.tiff", [string string]] atomically:NO];
    
    return resultImage;
}

-(NSImage*) imageForType:(NSString*)type	{

//	if ([self perspectives] == 0)
//		return;
//	int randomPerspective = 1 + rand() % [self perspectives];
//	int randomPerspective = 
	
	NSImage* buildingBase = [NSImage imageNamed:[NSString stringWithFormat:@"%@1NewBuilding.png", type]];
	NSImage* shadowBase = [NSImage imageNamed:[NSString stringWithFormat:@"%@1NewShadow.png", type]];

	NSRect rect = NSMakeRect(0, 0, [buildingBase size].width, [buildingBase size].height);
	NSImage* colorBase = [[[NSImage alloc] initWithSize:rect.size] autorelease];
	NSImage* returnImage = [[[NSImage alloc] initWithSize:[buildingBase size]] autorelease];
	NSRect retRect = NSMakeRect(0, 0, [returnImage size].width, [returnImage size].height);

//	NSColor* color = [[myOwner color] blendedColorWithFraction:0.35 ofColor:[NSColor blackColor]];
	NSColor* color = [[[GameController gameController] localPlayer] color];
	[colorBase lockFocus];
	[color set];
//	[[myOwner color] set];
	[NSBezierPath fillRect:rect];
	[colorBase unlockFocus];

	NSImage* coloredBuilding = [[[NSImage alloc] initWithSize:rect.size] autorelease];
	[coloredBuilding lockFocus];
	[buildingBase drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	[colorBase drawInRect:rect fromRect:rect operation:NSCompositeSourceAtop fraction:0.35];
	[coloredBuilding unlockFocus];
	
	[returnImage lockFocus];
	[shadowBase drawInRect:retRect fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	[coloredBuilding drawInRect:retRect fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	[returnImage unlockFocus];

	[returnImage setScalesWhenResized:YES];
	if ([type isEqualToString:@"city"])
		[returnImage setSize:NSMakeSize(25, 25)];
	else
		[returnImage setSize:NSMakeSize(20, 25)];
//	[myImage release];
//	myImage = [returnImage retain];
	return returnImage;
//	NSLog(@"built image, it's %@", returnImage);
//	return returnImage;
}

@end

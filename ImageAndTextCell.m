/*
	ImageAndTextCell.m
	Copyright (c) 2001-2004, Apple Computer, Inc., all rights reserved.
	Author: Chuck Pisula

	Milestones:
	Initially created 3/1/01

        Subclass of NSTextFieldCell which can display text and an image simultaneously.
*/

/*
 IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. ("Apple") in
 consideration of your agreement to the following terms, and your use, installation, 
 modification or redistribution of this Apple software constitutes acceptance of these 
 terms.  If you do not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject to these 
 terms, Apple grants you a personal, non-exclusive license, under AppleÕs copyrights in 
 this original Apple software (the "Apple Software"), to use, reproduce, modify and 
 redistribute the Apple Software, with or without modifications, in source and/or binary 
 forms; provided that if you redistribute the Apple Software in its entirety and without 
 modifications, you must retain this notice and the following text and disclaimers in all 
 such redistributions of the Apple Software.  Neither the name, trademarks, service marks 
 or logos of Apple Computer, Inc. may be used to endorse or promote products derived from 
 the Apple Software without specific prior written permission from Apple. Except as expressly
 stated in this notice, no other rights or licenses, express or implied, are granted by Apple
 herein, including but not limited to any patent rights that may be infringed by your 
 derivative works or by other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, 
 EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, 
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS 
 USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL 
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
 OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, 
 REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND 
 WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR 
 OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "ImageAndTextCell.h"

@implementation ImageAndTextCell

-(id) init	{
	self = [super init];
	if (self)	{
		attributedString = nil;
//		[self setWraps:NO];
//		[self setLineBreakMode:NSLineBreakByTruncatingTail];
	}
	return self;
}
- (void)dealloc {
    [image release];
    image = nil;
    [super dealloc];
}

- copyWithZone:(NSZone *)zone {
    ImageAndTextCell *cell = (ImageAndTextCell *)[super copyWithZone:zone];
    cell->image = [image retain];
    return cell;
}

- (void)setImage:(NSImage *)anImage {
    if (anImage != image) {
        [image release];
        image = [anImage retain];
    }
}

- (NSImage *)image {
    return image;
}

- (NSRect)imageFrameForCellFrame:(NSRect)cellFrame {
    if (image != nil) {
        NSRect imageFrame;
        imageFrame.size = [image size];
        imageFrame.origin = cellFrame.origin;
        imageFrame.origin.x += 3;
        imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
        return imageFrame;
    }
    else
        return NSZeroRect;
}
/*
- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
	NSLog(@"%s", __FUNCTION__);
	NSRect textFrame, imageFrame;
    NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [image size].width, NSMinXEdge);
	textFrame.origin.y += 3;
	textFrame.size.height = 12;
//	textFrame.size.width = [[self stringValue] length] * 5;
	textFrame.size.width = [attributedString size].width;
	NSLog(@"textFrame = %@", NSStringFromRect(textFrame));
//	[[NSColor whiteColor] set];
//	[NSBezierPath strokeRect:textFrame];
	[self setStringValue:[attributedString string]];
	NSLog(@"textObj = %@, delegate = %@", textObj, anObject);
	[super editWithFrame: textFrame inView: controlView editor:textObj delegate:anObject event: theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(int)selStart length:(int)selLength {
	NSLog(@"%s", __FUNCTION__);
    NSRect textFrame, imageFrame;
    NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [image size].width, NSMinXEdge);
	NSLog(@"textFrame = %@", NSStringFromRect(textFrame));
	textFrame.origin.y += 3;
	textFrame.size.height = 12;
	textFrame.size.width = [[self stringValue] length] * 5;
    [super selectWithFrame: textFrame inView: controlView editor:textObj delegate:anObject start:selStart length:selLength];
}
*/

//static int colorCounter = 0;
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
//	NSLog(@"%s", __FUNCTION__);
        NSRect	imageFrame = NSMakeRect(0, 0, 0, 0);
        NSSize	imageSize = NSMakeSize(0, 0);

    if (image != nil) {
  //      NSSize	imageSize;
    //    NSRect	imageFrame;

        imageSize = [image size];
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
//        if ([self drawsBackground]) {
  //          [[self backgroundColor] set];
    //        NSRectFill(imageFrame);
      //  }
        imageFrame.origin.x += 3;
        imageFrame.size = imageSize;

        if ([controlView isFlipped])
            imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
        else
            imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);

        [image compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
    }
	
	NSSize sz = [attributedString size];
	int vMargins = (cellFrame.size.height - sz.height) / 2;
	NSRect stringFrame = NSMakeRect(imageFrame.origin.x + imageFrame.size.width + 5, cellFrame.origin.y + vMargins, cellFrame.size.width, sz.height);
	
//	if ([[attributedString string] hasPrefix:@"Set"])	{
//		[[NSColor redColor] set];
//		[NSBezierPath strokeRect:stringFrame];
//		[[NSColor blueColor] set];
//		[NSBezierPath strokeRect:imageFrame];
//	}
	[attributedString drawInRect:stringFrame];

//	[attributedString drawInRect:NSMakeRect(
//	id objectValue = [self objectValue];
//	int yMarg = 
//	[tField setAtt
 //   [super drawWithFrame:cellFrame inView:controlView];
}

-(void) setAttributedString:(NSAttributedString*)str	{
  //  NSLog(@"setting attribute");
   // NSLog(@"break");
    //NSLog(@"set %@", str);
//	NSLog(@"setting attributed string, %@", str);
//	if (str == nil)
//		NSLog(@"but it's nil");
	[attributedString release];
	attributedString = [str copy];
	[attributedString retain];
//	NSLog(@"set it, %@", str);
}
-(NSAttributedString*) attributedString	{
	return attributedString;
}


- (NSSize)cellSize {
    NSSize cellSize = [super cellSize];
	cellSize.height = 20;
    cellSize.width += (image ? [image size].width : 0) + 3;
    return cellSize;
}

/*
- (NSArray *)draggingImageComponentsWithFrame:(NSRect)frame inView:(NSView *)view   {
    NSLog(@"%s", __FUNCTION__);
    return [NSArray arrayArrayWithObject:@"12345"];
}*/


@end


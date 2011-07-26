//
//  GCUndoTestView.m
//  GCDrawKit
//
//  Created by graham on 5/12/09.
//  Copyright 2009-2011 Apptree.net. All rights reserved.
//

#import "GCUndoTestView.h"
#import "GCUndoManager.h"

@implementation GCUndoTestView

- (id)		initWithFrame:(NSRect) frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		draggedBox = NSMakeRect( 100, 100, 100, 100 );
		dragBoxColour = [[NSColor redColor] retain];
	
	}
    return self;
}


- (void)	drawRect:(NSRect) dirtyRect
{
	
	[[NSColor whiteColor] set];
	NSRectFill(dirtyRect);
	
	[[NSColor lightGrayColor] set];
	NSFrameRectWithWidth([self bounds], (CGFloat)1.0);
	
	[[self draggedBoxColour] set];
	NSRectFill(draggedBox);

	[[NSColor blackColor] set];
	NSFrameRectWithWidth(draggedBox, (CGFloat)0.5);
	
	NSRect sizeRect = NSMakeRect( NSMaxX( draggedBox ) - 10, NSMaxY( draggedBox ) -10, 10, 10 );
	NSFrameRectWithWidth( sizeRect, (CGFloat)0.5);
}


- (BOOL)	isFlipped
{
	return YES;
}


- (void)	mouseDown:(NSEvent*) event
{
	[[self undoManager] beginUndoGrouping];
	
	NSPoint local = [self convertPoint:[event locationInWindow] fromView:nil];
	
	hit = [self hitTestBox:local];
	
	if( hit )
	{
		mouseOffset.x = local.x - draggedBox.origin.x;
		mouseOffset.y = local.y - draggedBox.origin.y;
	}
}


- (void)	mouseDragged:(NSEvent*) event
{
	NSPoint local = [self convertPoint:[event locationInWindow] fromView:nil];
	
	switch( hit )
	{
		case kHitForMove:
			local.x -= mouseOffset.x;
			local.y -= mouseOffset.y;
		
			[self setDraggedBoxPosition:local];
			break;
			
		case kHitForSize:
		{
			NSSize size;
			
			size.width = local.x - draggedBox.origin.x;
			size.height = local.y - draggedBox.origin.y;
			
			[self setDraggedBoxSize:size];
		}
		break;
	}
}


- (void)	mouseUp:(NSEvent*) event
{
	(void)event;
	
	[[self undoManager] endUndoGrouping];
}

- (void)		setDraggedBoxPosition:(NSPoint) p
{
	[[[self undoManager] prepareWithInvocationTarget:self] setDraggedBoxPosition:[self draggedBoxPosition]];
	
	[self setNeedsDisplayInRect:draggedBox];
	draggedBox.origin = p;
	[self setNeedsDisplayInRect:draggedBox];
	
	[[self undoManager] setActionName:@"Move"];
}


- (NSPoint)		draggedBoxPosition
{
	return draggedBox.origin;
}

- (void)		setDraggedBoxSize:(NSSize) size
{
	[[[self undoManager] prepareWithInvocationTarget:self] setDraggedBoxSize:[self draggedBoxSize]];
	
	[self setNeedsDisplayInRect:draggedBox];
	draggedBox.size = size;
	[self setNeedsDisplayInRect:draggedBox];

	[[self undoManager] setActionName:@"Resize"];
}


- (NSSize)		draggedBoxSize
{
	return draggedBox.size;
}


- (void)		setDraggedBoxColour:(NSColor*) aColour
{
	[[[self undoManager] prepareWithInvocationTarget:self] setDraggedBoxColour:[self draggedBoxColour]];
	
	[aColour retain];
	[dragBoxColour release];
	dragBoxColour = aColour;
	[self setNeedsDisplayInRect:draggedBox];
	
	[[self undoManager] setActionName:@"Change Colour"];
}


- (NSColor*)	draggedBoxColour
{
	return dragBoxColour;
}


- (NSInteger)	hitTestBox:(NSPoint) p
{
	if( NSPointInRect( p, draggedBox ))
	{
		NSRect sizeRect = NSMakeRect( NSMaxX( draggedBox ) - 10, NSMaxY( draggedBox ) -10, 10, 10 );
		
		if( NSPointInRect( p, sizeRect ))
			return kHitForSize;
		else
			return kHitForMove;
	}
	else
		return kNoHit;
}

@end

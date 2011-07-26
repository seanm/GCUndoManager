//
//  GCUndoTestView.h
//  GCDrawKit
//
//  Created by graham on 5/12/09.
//  Copyright 2009-2011 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// n.b for simplicty this includes a very crude data model of a draggable/resizeable box. This is not a good example of MVC separation, as
// the purpose of it is merely to allow testing of the undo manager code.


@interface GCUndoTestView : NSView
{
	NSRect		draggedBox;
	NSPoint		mouseOffset;
	NSInteger	hit;
	NSColor*	dragBoxColour;
}

// undoable properties

- (void)		setDraggedBoxPosition:(NSPoint) p;
- (NSPoint)		draggedBoxPosition;

- (void)		setDraggedBoxSize:(NSSize) size;
- (NSSize)		draggedBoxSize;

- (void)		setDraggedBoxColour:(NSColor*) aColour;
- (NSColor*)	draggedBoxColour;

- (NSInteger)	hitTestBox:(NSPoint) p;

@end


enum
{
	kNoHit			= 0,
	kHitForMove		= 1,
	kHitForSize		= 2
};

//
//  MyDocument.m
//  GCDrawKit
//
//  Created by graham on 5/12/09.
//  Copyright 2009-2011 Apptree.net. All rights reserved.
//

#import "MyDocument.h"
#import "GCUndoManager.h"
#import "GCUndoTestView.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.

		GCUndoManager* um = [[GCUndoManager alloc] init];
		[um enableUndoTaskCoalescing];
		[um setLevelsOfUndo:16];
		[self setUndoManager:(id)um];
		[um release];
		[self setHasUndoManager:YES];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	(void)typeName;
	
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	(void)data;
	(void)typeName;
	
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}


- (IBAction)		enableUndoAction:(id) sender
{
	if([sender state] == NSOnState )
		[[self undoManager] enableUndoRegistration];
	else
		[[self undoManager] disableUndoRegistration];
}


- (IBAction)		enableCoalescingAction:(id) sender
{
	if([sender state] == NSOnState )
		[(GCUndoManager*)[self undoManager] enableUndoTaskCoalescing];
	else
		[(GCUndoManager*)[self undoManager] disableUndoTaskCoalescing];
}


- (IBAction)		enableEventGroupingAction:(id) sender
{
	[[self undoManager] setGroupsByEvent:[sender state]];
}


- (IBAction)		removeAllActionsAction:(id) sender
{
	(void)sender;
	
	[[self undoManager] removeAllActions];
}


- (IBAction)		colourAction:(id) sender
{
	[mMainView setDraggedBoxColour:[sender color]];
}


- (IBAction)		umTypeAction:(id) sender
{
	NSInteger	tag = [[sender selectedCell] tag];
	id			um;
	
	if( tag == 0 )
	{
		um = [[NSUndoManager alloc] init];
		[mEnableCoalescingCheckbox setEnabled:NO];
	}
	else
	{
		um = [[GCUndoManager alloc] init];
		[mEnableCoalescingCheckbox setEnabled:YES];
		
		if([mEnableCoalescingCheckbox state] == NSOnState)
			[um enableUndoTaskCoalescing];
	}
	
	[um setLevelsOfUndo:16];
	[self setUndoManager:um];
	[um release];
}


- (IBAction)		logUMDescription:(id) sender
{
	(void)sender;
	
	NSLog(@"%@", [[self undoManager] description]);
}


- (IBAction)		explodeUndoAction:(id) sender
{
	(void)sender;
	
	if([[self undoManager] respondsToSelector:@selector(explodeTopUndoAction)])
		[(GCUndoManager*)[self undoManager] explodeTopUndoAction];
	
}


- (void)			windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];

	[mEnableUndoCheckbox setState:[[self undoManager] isUndoRegistrationEnabled]];
	[mEnableCoalescingCheckbox setState:[(GCUndoManager*)[self undoManager] isUndoTaskCoalescingEnabled]];
	[mEnableGroupByEventCheckbox setState:[[self undoManager] groupsByEvent]];
	[mColourPropertyWell setColor:[mMainView draggedBoxColour]];
	
	id um = [self undoManager];
	
	if([um isKindOfClass:[GCUndoManager class]])
		[mUndoTypeRadioButtons selectCellWithTag:1];
	else
		[mUndoTypeRadioButtons selectCellWithTag:0];
}


@end

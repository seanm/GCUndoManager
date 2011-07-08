//
//  MyDocument.h
//  GCDrawKit
//
//  Created by graham on 5/12/09.
//  Copyright 2009 Apptree.net. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class GCUndoTestView;


@interface MyDocument : NSDocument
{
	IBOutlet NSButton*			mEnableUndoCheckbox;
	IBOutlet NSButton*			mEnableCoalescingCheckbox;
	IBOutlet NSButton*			mEnableGroupByEventCheckbox;
	IBOutlet NSColorWell*		mColourPropertyWell;
	IBOutlet GCUndoTestView*	mMainView;
	IBOutlet NSMatrix*			mUndoTypeRadioButtons;
}

- (IBAction)		enableUndoAction:(id) sender;
- (IBAction)		enableCoalescingAction:(id) sender;
- (IBAction)		enableEventGroupingAction:(id) sender;
- (IBAction)		removeAllActionsAction:(id) sender;
- (IBAction)		colourAction:(id) sender;
- (IBAction)		umTypeAction:(id) sender;
- (IBAction)		logUMDescription:(id) sender;

@end

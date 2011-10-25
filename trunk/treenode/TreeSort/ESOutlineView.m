//
//  ESOutlineView.m
//  TreeSort
//
//  Created by Russell on 04/06/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "ESOutlineView.h"
#import "OutlineViewController.h"
#import "TreeSortAppDelegate.h"

@implementation ESOutlineView

#pragma mark -
#pragma mark Event Handling methods

// Intercept key presses
- (void)keyDown:(NSEvent *)theEvent
{
    
//    TreeSortAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
//	
//	if(theEvent) {
//		switch([[theEvent characters] characterAtIndex:0])
//		{
//			case NSDeleteCharacter:
//				[appDelegate deleteItems];
//				break;
//                                
//			default:
//				[super keyDown:theEvent];
//				break;
//		}
//	}
}

- (IBAction)copy:(id)sender;
{	
	NSLog(@"Copy called");
    [outlineViewController copy];
}

- (IBAction)paste:(id)sender
{
    NSLog(@"Paste called");
    [outlineViewController paste];
}

- (IBAction)cut:(id)sender
{
    NSLog(@"Cut called");
    [outlineViewController cut];
}

- (IBAction)delete:(id)sender
{
    NSLog(@"delete called");
    [outlineViewController delete];
}


// Call super implementation to re-establish expansion states
- (void)reloadData;
{
    [super reloadData];
	
    NSUInteger row;
	
    
    /*  Disable undo so that the change is not recorded with the undo manager.
        Especially needed at startup or an unwanted undo is recorded.
     */
//    NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
//    [[context undoManager] disableUndoRegistration];
    
    for (row = 0 ; row < [self numberOfRows] ; row++) {
		NSTreeNode *item = [self itemAtRow:row];
		if (![item isLeaf] && [[[item representedObject] valueForKey:@"isExpanded"] boolValue]) {
			[self expandItem:item];
        } else {
            [self collapseItem:item];
        }
	}
    
    // Renable undo
//    [[context undoManager] enableUndoRegistration];
}

- (void)dealloc
{
    [super dealloc];
}

@end


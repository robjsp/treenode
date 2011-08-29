//
//  ESOutlineView.m
//  TreeSort
//
//  Created by Russell on 04/06/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "ESOutlineView.h"
#import "TreeSortAppDelegate.h"

@implementation ESOutlineView

#pragma mark -
#pragma mark Event Handling methods

// Intercept key presses
- (void)keyDown:(NSEvent*)theEvent {
    
    TreeSortAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	
	if(theEvent) {
		switch([[theEvent characters] characterAtIndex:0])
		{
			case NSDeleteCharacter:
				[appDelegate deleteItems];
				break;
                                
			default:
				[super keyDown:theEvent];
				break;
		}
	}
}

- (void)dealloc
{
    [super dealloc];
}

// Call super implementation to re-establish expansion states
- (void)reloadData;
{
	[super reloadData];
	NSUInteger row;
	for (row = 0 ; row < [self numberOfRows] ; row++) {
		NSTreeNode *item = [self itemAtRow:row];
		if (![item isLeaf] && [[[item representedObject] valueForKey:@"isExpanded"] boolValue])
			[self expandItem:item];
        else
            [self collapseItem:item];
	}
}


@end


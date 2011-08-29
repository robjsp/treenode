//
//  ESOutlineView.m
//  TreeSort
//
//  Created by Russell on 04/06/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "ESOutlineView.h"


@implementation ESOutlineView

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
    NSLog(@"reloadData called");
}

- (void)dealloc
{
    [super dealloc];
}

@end


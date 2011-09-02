//
//  ESTableView.m
//  TreeSort
//
//  Created by Russell Newlands on 02/09/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "ESCategoryView.h"
#import "TreeSortAppDelegate.h"

@implementation ESCategoryView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark -
#pragma mark Event Handling methods

// Intercept key presses
- (void)keyDown:(NSEvent *)theEvent {
    
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

@end

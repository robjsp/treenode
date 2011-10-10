//
//  OutlineViewController.h
//  TreeSort
//
//  Created by Newlands Russell on 10/10/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESTreeController;
@class ESOutlineView;

@interface OutlineViewController : NSObject
{
 @private
    NSManagedObjectContext *context;
    IBOutlet ESTreeController *treeController;
    IBOutlet ESOutlineView *testOutlineView;
    IBOutlet NSArrayController *categoryController;
    IBOutlet NSButton *newLeaf;
    IBOutlet NSButton *newGroup;
}

- (IBAction)newLeaf:(id)sender;
- (IBAction)newGroup:(id)sender;

@end

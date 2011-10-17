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

- (NSArray *)treeNodeSortDescriptors; // This is a 'getter' method whose name is used in binding the sortDescriptors property of the treeController

- (IBAction)newLeaf:(id)sender;
- (IBAction)newGroup:(id)sender;

- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)cut:(id)sender;
- (IBAction)delete:(id)sender;

- (void)deleteItems;
- (void)cutItems;
- (void)writeToPasteboard:(NSPasteboard *)pasteBoard;
- (BOOL)createObjectsFromPasteboard:(NSPasteboard *)pasteBoard;

@end

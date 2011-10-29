//
//  TreeSortAppDelegate.h
//  TreeSort
//
//  Created by Russell on 04/06/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ESTreeController;
@class ESOutlineView;
@class OutlineViewController;

@interface TreeSortAppDelegate : NSObject <NSApplicationDelegate>
{
 @private
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
    
    IBOutlet ESTreeController *treeController;
	IBOutlet ESOutlineView *testOutlineView;
    IBOutlet OutlineViewController *outlineViewController;
    IBOutlet NSArrayController *categoryController;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;

- (void)objectsChangedInContext:(NSNotification *)note;

- (NSArray *)treeNodeSortDescriptors; // This is a 'getter' method whose name is used in binding the sortDescriptors property of the treeController

@end

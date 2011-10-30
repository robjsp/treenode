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
    
    ESTreeController *treeController;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet ESOutlineView *testOutlineView;
@property (assign) IBOutlet OutlineViewController *outlineViewController;
@property (assign) IBOutlet NSArrayController *categoryController;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;

- (void)objectsChangedInContext:(NSNotification *)note;

@end

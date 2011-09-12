//
//  TreeSortAppDelegate.m
//  TreeSort
//
//  Created by Russell on 04/06/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "TreeSortAppDelegate.h"
#import "ESTreeNode.h"
#import "ESCategory.h"
#import "NSArray_Extensions.h"
#import "NSTreeController_Extensions.h"
#import "NSTreeNode_Extensions.h"
#import "NSIndexPath_Extensions.h"
#import "NSManagedObject_Extensions.h"

NSString *ESNodeIndexPathPasteBoardType = @"ESNodeIndexPathPasteBoardType";
NSString *propertiesPasteBoardType = @"propertiesPasteBoardType";

@implementation TreeSortAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // register for a notification when objects are changed in the Managed Object Context
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(objectsChangedInContext:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:[self managedObjectContext]];}

- (void)awakeFromNib;
{
	[testOutlineView registerForDraggedTypes:[NSArray arrayWithObject:ESNodeIndexPathPasteBoardType]];
}

/**
    Returns the directory the application uses to store the Core Data store file. This code uses a directory named "TreeSort" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"TreeSort"];
}


/**
    Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TreeSort" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
        
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"TreeSort.storedata"];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    
/** 
    Changed the call to addPersistantStore... to add core data model versioning support as according to
    prag prog book on core data
 */
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:dict error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        [__persistentStoreCoordinator release], __persistentStoreCoordinator = nil;
        return nil;
    }

    return __persistentStoreCoordinator;
}


/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *) managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}


/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction) saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


// undo and redo
-(BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
    if ([anItem action] == @selector(undo:)) {
        return [[[self managedObjectContext] undoManager] canUndo];
    } 
    else if ([anItem action] == @selector(redo:)) {
        return [[[self managedObjectContext] undoManager] canRedo];
    }
    return YES;
}

-(IBAction)undo:sender
{
    [[[self managedObjectContext] undoManager] undo];
}


-(IBAction)redo:sender
{
    [[[self managedObjectContext] undoManager] redo];
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    // Save changes in the application's managed object context before the application terminates.

    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (void)dealloc
{
    [__managedObjectContext release];
    [__persistentStoreCoordinator release];
    [__managedObjectModel release];
    [super dealloc];
}


#pragma mark -
#pragma mark My Stuff Start


// The methods below set the name of the inserted object automatically by a 'static' count variable
- (IBAction)newLeaf:(id)sender;
{
	ESTreeNode *treeNode = [NSEntityDescription insertNewObjectForEntityForName:@"TreeNode" inManagedObjectContext:[self managedObjectContext]];
    
    treeNode.isLeaf = [NSNumber numberWithBool:YES];
    static NSUInteger count = 0;
	treeNode.displayName = [NSString stringWithFormat:@"Leaf %i",++count];
    
	[treeController insertObject:treeNode atArrangedObjectIndexPath:[treeController indexPathForInsertion]];
}


- (IBAction)newGroup:(id)sender;
{
	ESTreeNode *treeNode = [NSEntityDescription insertNewObjectForEntityForName:@"TreeNode" inManagedObjectContext:[self managedObjectContext]];
    
    treeNode.isLeaf = [NSNumber numberWithBool:NO];
    static NSUInteger count = 0;
	treeNode.displayName = [NSString stringWithFormat:@"Group %i",++count];
    
	[treeController insertObject:treeNode atArrangedObjectIndexPath:[treeController indexPathForInsertion]];	
}

- (IBAction)newCategory:(id)sender;
{
    ESCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:[self managedObjectContext]];
    
    static NSUInteger count = 0;
    category.displayName = [NSString stringWithFormat:@"Category %i",++count];
    NSLog(@"newCategory with name = %@", category.displayName);
    
    [categoryController insertObject:category atArrangedObjectIndex:[[categoryController arrangedObjects] count]];	
}


- (NSArray *)treeNodeSortDescriptors;
{
	return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES] autorelease]];
}


// Copy and Paste

- (IBAction)copy:(id)sender
{	
    if ([[treeController selectedNodes] count] > 0 ) {
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [self writeToPasteboard:pasteBoard];
    }
}

- (IBAction)paste:(id)sender
{
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    if(![self readFromPasteboard:pasteBoard])
        NSLog(@"outlineView paste unsuccessful");
}

- (IBAction)cut:(id)sender
{
   [self cutItems];
}

- (IBAction)delete:(id)sender
{
    [self deleteItems];
}

- (void)cutItems
{   
    if ([[treeController selectedNodes] count] > 0 ) {
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [self writeToPasteboard:pasteBoard];
        
        [treeController removeObjectsAtArrangedObjectIndexPaths:[treeController selectionIndexPaths]];            
    }
}

- (void)deleteItems
{
    [treeController removeObjectsAtArrangedObjectIndexPaths:[treeController selectionIndexPaths]];            
}


//- (void)writeToPasteboard:(NSPasteboard *)pasteBoard
//{
//    //  Get the treeController. I know I've got a it as an outlet, but I want to make this more self-contained.
//    //  Move this to awakeFromNib in a viewController. The selected nodes are flattened and the selected managed objects found.
//    //  The properties of each node are then read into a dictionary which is inserted into an array.
//    
//    NSArray *selectedObjects = [treeController flattenedSelectedObjects];    
//    NSUInteger count = [selectedObjects count];
//    
//    if (count) {
//		NSMutableArray	*copiedProperties = [NSMutableArray arrayWithCapacity:count]; 
//        id treeObject;
//        
//		for (treeObject in selectedObjects ) {
//            if ([treeObject respondsToSelector:@selector(dictionaryRepresentation)])
//                [copiedProperties addObject:[treeObject dictionaryRepresentation]];
//        }
//                
//		NSData *copyData = [NSKeyedArchiver archivedDataWithRootObject:copiedProperties];
//        [pasteBoard declareTypes:[NSArray arrayWithObjects:ESObjectURIPasteBoardType, nil] owner:self]; 
//        [pasteBoard setData:copyData forType:ESObjectURIPasteBoardType];
//    }
//}

//- (BOOL)readFromPasteboard:(NSPasteboard *)pasteBoard
//{   
//    NSArray *types = [pasteBoard types];
//    if([types containsObject:ESObjectURIPasteBoardType]) {
//        NSData  *data = [pasteBoard dataForType:ESObjectURIPasteBoardType];
//        
//        //  The data is archived up as a series of NSDictionaries when copy or drag occurs, so unarchive first
//        //  The objects are created and the URI representation used to set their properties. The indexPaths for
//        //  insertion are found separately.
//        
//        NSArray *copiedProperties;
//        if(data) {
//            copiedProperties = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//            NSIndexPath *initialIndexPath = [treeController indexPathForInsertion];
//            NSArray *insertionindexPaths = [treeController indexPathsForNodeProperties:copiedProperties atInsertionIndexPath:initialIndexPath];
//            
//            NSUInteger i;
//            
//            for (i = 0; (i < [copiedProperties count]); ++i) {
//                ESTreeNode *treeNode = [NSEntityDescription insertNewObjectForEntityForName:@"TreeNode" inManagedObjectContext:[self managedObjectContext]];
//                if([treeNode respondsToSelector:@selector(setValuesFromDictionaryRepresentation:)])
//                    [treeNode setValuesFromDictionaryRepresentation:[copiedProperties objectAtIndex:i]];
//                [treeController insertObject:treeNode atArrangedObjectIndexPath:[insertionindexPaths objectAtIndex:i]];
//            }
//            return YES;
//        }
//    }    
//    return NO;
//}


- (void)writeToPasteboard:(NSPasteboard *)pasteBoard
{
    //  Get the treeController. I know I've got a it as an outlet, but I want to make this more self-contained.
    //  Move this to awakeFromNib in a viewController. The selected nodes are flattened and the selected managed objects found.
    //  The properties of each node are then read into a dictionary which is inserted into an array.

    // Filter out duplicate selections when a selected node is an ancestor of another selected node
    NSArray *filteredObjects = [treeController filterObjectsByRemovingChildrenForNodes:[treeController selectedNodes]];    
    NSMutableArray *selectedObjectProps = [NSMutableArray array];

    // Return a dictionary of all objects attributes, their name and their relationship data. These will be ordered.
    for(id managedObject in filteredObjects) {
        [selectedObjectProps addObjectsFromArray:[managedObject objectPropertyTreeInContext:[self managedObjectContext]]];
    }
                   
	NSData *copyData = [NSKeyedArchiver archivedDataWithRootObject:selectedObjectProps];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:propertiesPasteBoardType, nil] owner:self]; 
    [pasteBoard setData:copyData forType:propertiesPasteBoardType];
}


- (BOOL)readFromPasteboard:(NSPasteboard *)pasteBoard
{   
    NSArray *types = [pasteBoard types];
    if([types containsObject:propertiesPasteBoardType]) {
        NSData  *data = [pasteBoard dataForType:propertiesPasteBoardType];
        
        /*  The data is archived up as a series of NSDictionaries when copy or drag occurs, so unarchive first
            The objects are created and the URI representation used to set their properties. The properties copied
            include all attributes, the related object URI's and the original indexPaths for treeNode objects
         */
        
        NSArray *copiedProperties;
        if(data) {
            copiedProperties = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSIndexPath *insertionIndexPath = [treeController indexPathForInsertion];
            
            NSMutableDictionary *indexForURI = [NSMutableDictionary dictionary];
            NSUInteger i;
            
            NSMutableArray *newObjects = [NSMutableArray array];
            NSManagedObjectContext *context = [self managedObjectContext]; 
            
            // Setup lookup dictionary to find related managedObjects, need to do this first so that we can find the base nodes
            for (i = 0; i < [copiedProperties count]; ++i) {
                NSDictionary *copiedDict = [copiedProperties objectAtIndex:i];
                NSURL *selfURI = [copiedDict valueForKey:@"selfURI"];
                [indexForURI setObject:[NSNumber numberWithUnsignedInteger:i] forKey:selfURI];
            }
            
            // Now create new managed objects setting the attributes of each from the copied properties
            for (NSDictionary *copiedDict in copiedProperties) {
                NSString *entityName = [copiedDict valueForKey:@"entityName"];
                NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self managedObjectContext]];
                
                // Set all the attributes of the object, do this before calling NSTreeController's insert Object method                               
                NSDictionary *attributes = [copiedDict valueForKey:@"attributes"];
                for (NSString *attributeName in attributes) {
                    if(![attributeName isEqualToString:@"sortIndex"]) // So as not to override the sortIndex property set by the treeController subclass on insertion
                        [newManagedObject setValue:[attributes valueForKey:attributeName] forKey:attributeName];
                }
                
                /*  Since TreeNode objects are root objects, and the copied base node objects have no parent, their position can be set first
                    or set other positions using sortIndex attribute
                 */
                if ([entityName isEqualToString:@"TreeNode"]) {
                    NSURL *copiedParent = [[[copiedDict valueForKey:@"relationships"] valueForKey:@"parent"] firstObject];
                    if(![indexForURI objectForKey:copiedParent]) {
                        [treeController insertObject:newManagedObject atArrangedObjectIndexPath:insertionIndexPath];	
                        insertionIndexPath = [insertionIndexPath indexPathByIncrementingLastIndex];
                    } else {
                        [newManagedObject setValue:[attributes valueForKey:@"sortIndex"] forKey:@"sortIndex"];
                    }
                }
                
                [newObjects addObject:newManagedObject];
//                [self restoreExpansionStates:newManagedObject];
            }
            
            // Set the relationships of the new objects by using the lookup dictionary.
            for (i = 0; i < [newObjects count]; ++i) {
                NSDictionary *copiedRelationships = [[copiedProperties objectAtIndex:i] valueForKey:@"relationships"];
                
                NSManagedObject *newObject = [newObjects objectAtIndex:i];
                NSString *entityName = [[newObject entity] name];
                NSDictionary *relationships = [[NSEntityDescription entityForName:entityName inManagedObjectContext:context] relationshipsByName];
                
                for (NSString *relationshipName in [copiedRelationships allKeys]) {
                    NSArray *relatedObjectURIs = [copiedRelationships valueForKey:relationshipName];
                    NSRelationshipDescription *relDescription = [relationships objectForKey:relationshipName];  
                    /*  No need to set to one relationships because the inverse is set automatically by when an object is added
                        The copied base nodes also have their parent (to - one) relationship set by insert.
                        the newRelationshipSet points to the original retrieved set and this is what is updated on adding
                     */
                    if([relDescription isToMany]) {
                        NSMutableSet *newRelationshipsSet = [newObject mutableSetValueForKey:relationshipName];
                        for (NSURL *objectURI in relatedObjectURIs) {
                            NSUInteger indexOfObject = [[indexForURI objectForKey:objectURI] unsignedIntegerValue];
                            [newRelationshipsSet addObject:[newObjects objectAtIndex:indexOfObject]];
                        }
                    }                   
                }
            }
            return YES;
        }
    }    
    return NO;
}

//- (void)restoreExpansionStates:(NSManagedObject*)parent;
//{
//	NSMutableSet *childrenSet = [parent mutableSetValueForKey:@"children"];
//    NSLog(@"children are %@", childrenSet);
//	NSManagedObject *aManagedObject;
//    
//    for (aManagedObject in childrenSet) {
//        /*  if expanded and has children then restore their expansion states
//            'valueForKey:@children' will return an array. intValue because the returned
//            type is BOOL which is actually a char and is numerically compared here YES is defined as '1'.
//         */
//		if (![[aManagedObject valueForKey:@"isLeaf"] boolValue] && [[aManagedObject valueForKey:@"isExpanded"] boolValue]) {
//            // then restore expansion states.
//            
//            [testOutlineView expandItem:[self treeNodeForObject:aManagedObject]];
//        //            // And now recursively restore the expansion states of all children
//        //            [self restoreExpansionStates:aManagedObject];
//        }
//        //recursive bit, call method again with relatedObject
//    }
//    
//	while(aManagedObject = [enumerator nextObject]) {
//		// if expanded and has children then restore their expansion states
//		// 'valueForKey:@children' will return an array. intValue because the returned
//		// type is BOOL which is actually a char and is numerically compared here YES is defined as '1'.
//		if(([[aManagedObject valueForKey:@"isExpanded"] intValue] == YES) && ([[aManagedObject valueForKey:@"children"] count] > 0)) {
//			// then restore expansion states.
//            [collectionView expandItem:[collectionTreeController outlineItemForObject:aManagedObject]];
//            // And now recursively restore the expansion states of all children
//            [self restoreExpansionStates:aManagedObject];
//		}
//	}
//}


#pragma mark -
#pragma mark Handle Context Changes

// Handles posted notifications and is called when objects in the context
// change. Used here to intercept and handle redo/undo

- (void)objectsChangedInContext:(NSNotification *)note
{
	BOOL isESTreeNode;
	
	// Find out if an undo or redo has occured
	NSUndoManager *undoManager = [[self managedObjectContext]  undoManager];
	BOOL isUndoingOrRedoing = [undoManager isUndoing] || [undoManager isRedoing];
	
	// Querry the info dictionary to disover the object(s) undone or redone and
	// find the class these belong to
	NSSet *updatedObjects = [[note userInfo] objectForKey:NSUpdatedObjectsKey];
    NSSet *deletedObjects = [[note userInfo] objectForKey:NSDeletedObjectsKey];
    NSSet *insertedObjects = [[note userInfo] objectForKey:NSInsertedObjectsKey];
    
	if ([[updatedObjects anyObject] isKindOfClass:[ESTreeNode class]]) {
		isESTreeNode = YES;
	}			
	
	// If undoing or redoing, handle the appropriate model/view changes depending
	// on the class of MO
	if(isUndoingOrRedoing) {
		if(isESTreeNode) {
			
		}
	}
}


@end

#pragma mark -
#pragma mark Delegate Methods

@implementation TreeSortAppDelegate (NSOutlineViewDragAndDrop)

// items is an array of treeNodes.[items valueForKey:@"indexPath"] is a KVC trick to produce an array of the selected managedObject indexPaths 

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteBoard;
{
	[pasteBoard declareTypes:[NSArray arrayWithObject:ESNodeIndexPathPasteBoardType] owner:self];
	[pasteBoard setData:[NSKeyedArchiver archivedDataWithRootObject:[items valueForKey:@"indexPath"]] forType:ESNodeIndexPathPasteBoardType];
	return YES;
}


- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)proposedParentItem proposedChildIndex:(NSInteger)proposedChildIndex;
{
	if (proposedChildIndex == -1) // will be -1 if the mouse is hovering over a leaf node
		return NSDragOperationNone;
    
	NSArray *draggedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:ESNodeIndexPathPasteBoardType]];
	BOOL targetIsValid = YES;
	for (NSIndexPath *indexPath in draggedIndexPaths) {
		NSTreeNode *node = [treeController nodeAtIndexPath:indexPath];
		if (!node.isLeaf) {
			if ([proposedParentItem isDescendantOfNode:node] || proposedParentItem == node) { // can't drop a group on one of its descendants
				targetIsValid = NO;
				break;
			}
		}
	}
	return targetIsValid ? NSDragOperationMove : NSDragOperationNone;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)proposedParentItem childIndex:(NSInteger)proposedChildIndex;
{
	NSArray *droppedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:ESNodeIndexPathPasteBoardType]];
	
	NSMutableArray *draggedNodes = [NSMutableArray array];
	for (NSIndexPath *indexPath in droppedIndexPaths)
		[draggedNodes addObject:[treeController nodeAtIndexPath:indexPath]];
    	
	NSIndexPath *proposedParentIndexPath;
	if (!proposedParentItem)
		proposedParentIndexPath = [[[NSIndexPath alloc] init] autorelease]; // makes a NSIndexPath with length == 0
	else
		proposedParentIndexPath = [proposedParentItem indexPath];
    
	[treeController moveNodes:draggedNodes toIndexPath:[proposedParentIndexPath indexPathByAddingIndex:proposedChildIndex]];
    
	return YES;
}

@end


@implementation TreeSortAppDelegate (NSOutlineViewDelegate)

// Returns a Boolean that indicates whether a given row should be drawn in the “group row” style. Off by default.
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item;
{
	if ([[(ESTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf])
		return NO;
    return [[[item representedObject] isSpecialGroup] boolValue];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item;
{
	if ([[(ESTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf])
		return NO;
	return [[[item representedObject] canCollapse] boolValue];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item;
{
	if ([[(ESTreeNode *)[item representedObject] isLeaf] boolValue] || [(NSTreeNode *)item isLeaf])
		return NO;
	return [[[item representedObject] canExpand] boolValue];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
{
	return [[(ESTreeNode *)[item representedObject] isSelectable] boolValue];
}


- (void)outlineViewItemDidCollapse:(NSNotification *)notification;
{
	ESTreeNode *collapsedItem = [[[notification userInfo] valueForKey:@"NSObject"] representedObject];
	collapsedItem.isExpanded = [NSNumber numberWithBool:NO];
}


- (void)outlineViewItemDidExpand:(NSNotification *)notification;
{
	ESTreeNode *expandedItem = [[[notification userInfo] valueForKey:@"NSObject"] representedObject];
	expandedItem.isExpanded = [NSNumber numberWithBool:YES];
}

@end


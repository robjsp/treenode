//
//  OutlineViewController.m
//  TreeSort
//
//  Created by Newlands Russell on 10/10/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "OutlineViewController.h"
#import "ESTreeNode.h"
#import "ESCategory.h"
#import "NSArray_Extensions.h"
#import "NSTreeController_Extensions.h"
#import "NSTreeNode_Extensions.h"
#import "NSIndexPath_Extensions.h"
#import "NSManagedObject_Extensions.h"

NSString *ESNodeIndexPathPasteBoardType = @"ESNodeIndexPathPasteBoardType";
NSString *propertiesPasteBoardType = @"propertiesPasteBoardType";

@implementation OutlineViewController

- (id)init
{
    self = [super init];
    return self;
}


- (void)awakeFromNib;
{
	[testOutlineView registerForDraggedTypes:[NSArray arrayWithObject:ESNodeIndexPathPasteBoardType]];
    context = [[NSApp delegate] managedObjectContext];
}


- (NSArray *)treeNodeSortDescriptors;
{
	return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES] autorelease]];
}


#pragma mark -
#pragma mark create new tree items

- (IBAction)newLeaf:(id)sender;
{
	ESTreeNode *treeNode = [NSEntityDescription insertNewObjectForEntityForName:@"TreeNode" inManagedObjectContext:context];
    
    treeNode.isLeaf = [NSNumber numberWithBool:YES];
    static NSUInteger count = 0;
	treeNode.displayName = [NSString stringWithFormat:@"Leaf %i",++count];
	[treeController insertObject:treeNode atArrangedObjectIndexPath:[treeController indexPathForInsertion]];
}


- (IBAction)newGroup:(id)sender;
{
	ESTreeNode *treeNode = [NSEntityDescription insertNewObjectForEntityForName:@"TreeNode" inManagedObjectContext:context];
    
    treeNode.isLeaf = [NSNumber numberWithBool:NO];
    static NSUInteger count = 0;
	treeNode.displayName = [NSString stringWithFormat:@"Group %i",++count];
    
	[treeController insertObject:treeNode atArrangedObjectIndexPath:[treeController indexPathForInsertion]];	
}


#pragma mark -
#pragma mark Copy and Paste

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
    if(![self createObjectsFromPasteboard:pasteBoard])
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
        [selectedObjectProps addObjectsFromArray:[managedObject objectPropertyTreeInContext:context]];
    }
    
	NSData *copyData = [NSKeyedArchiver archivedDataWithRootObject:selectedObjectProps];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:propertiesPasteBoardType, nil] owner:self]; 
    [pasteBoard setData:copyData forType:propertiesPasteBoardType];
}


- (BOOL)createObjectsFromPasteboard:(NSPasteboard *)pasteBoard
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
            
            // Setup lookup dictionary to find related managedObjects, need to do this first so that we can find the base nodes
            for (i = 0; i < [copiedProperties count]; ++i) {
                NSDictionary *copiedDict = [copiedProperties objectAtIndex:i];
                NSURL *selfURI = [copiedDict valueForKey:@"selfURI"];
                [indexForURI setObject:[NSNumber numberWithUnsignedInteger:i] forKey:selfURI];
            }
            
            // Now create new managed objects setting the attributes of each from the copied properties
            for (NSDictionary *copiedDict in copiedProperties) {
                NSString *entityName = [copiedDict valueForKey:@"entityName"];
                NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
                
                // Set all the attributes of the object, do this before calling NSTreeController's insert Object method                               
                NSDictionary *attributes = [copiedDict valueForKey:@"attributes"];
                for (NSString *attributeName in attributes) {
                    [newManagedObject setValue:[attributes valueForKey:attributeName] forKey:attributeName];
                }
                
                /*  Since TreeNode objects are root objects, and the copied base node objects have no parent, their position can be set first.
                 */
                if ([entityName isEqualToString:@"TreeNode"]) {
                    NSURL *copiedParent = [[[copiedDict valueForKey:@"relationships"] valueForKey:@"parent"] firstObject];
                    if(![indexForURI objectForKey:copiedParent]) {
                        [treeController insertObject:newManagedObject atArrangedObjectIndexPath:insertionIndexPath];	
                        insertionIndexPath = [insertionIndexPath indexPathByIncrementingLastIndex];
                    }
                }
                
                [newObjects addObject:newManagedObject];
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
            // To ensure all expansion states are reset after a paste. Can only be done after relationships are set
            [testOutlineView reloadData];  
            return YES;
        }
    }    
    return NO;
}

@end


#pragma mark -
#pragma mark Delegate Methods

@implementation OutlineViewController (NSOutlineViewDragAndDrop)

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



@implementation OutlineViewController (NSOutlineViewDelegate)

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


- (void)outlineViewItemWillCollapse:(NSNotification *)notification
{
    /*  The following ensures that if a ancestor node is collapsed the descendent group nodes
     don't also collapse. It seems that this method is called for every descendent in a 
     collapse of an ancestor
     */
    
    ESTreeNode *itemToCollapse = [[[notification userInfo] valueForKey:@"NSObject"] representedObject];;
    BOOL visible = YES;    
    ESTreeNode *parent = [itemToCollapse valueForKey:@"parent"];
    
    /*  Walk up the tree from the node to see if it is expanded. If an ancestor node is collapsed
     then preserve the expanded state of the node
     */
    while (parent) {
        if (![[parent valueForKey:@"isExpanded"] boolValue]) {
            visible = NO;
            break;
        }
        parent = [parent valueForKey:@"parent"];
    }
    
    if(visible) {
        itemToCollapse.isExpanded = [NSNumber numberWithBool:NO];
    }
}


- (void)outlineViewItemDidCollapse:(NSNotification *)notification;
{   
}


- (void)outlineViewItemDidExpand:(NSNotification *)notification;
{
	ESTreeNode *expandedItem = [[[notification userInfo] valueForKey:@"NSObject"] representedObject];
	expandedItem.isExpanded = [NSNumber numberWithBool:YES];
    
    // To ensure all model expansion states are resynced with the view after a paste.
    [testOutlineView reloadData];
}

@end
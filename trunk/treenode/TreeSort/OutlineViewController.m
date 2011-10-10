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
    if (self) {
        context = [[NSApp delegate] managedObjectContext];
    }
    
    return self;
}


// The methods below set the name of the inserted object automatically by a 'static' count variable
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
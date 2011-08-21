//
//  NSTreeController_Extensions.h
//  SortedTree
//
//  Created by Russell on 01/06/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSTreeNode_Extensions.h"
#import "NSIndexPath_Extensions.h"
#import "NSArray_Extensions.h"


@interface NSTreeController (NSTreeController_Extensions)

// Searching and finding paths and nodes
- (NSArray *)rootNodes;
- (NSTreeNode *)nextSiblingOfNode:(NSTreeNode *)node;
- (NSTreeNode *)nextSiblingOfNodeAtIndexPath:(NSIndexPath *)indexPath;
- (NSTreeNode *)nodeAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForInsertion;
- (NSIndexPath *)indexPathToObject:(id)object;
- (NSTreeNode *)treeNodeForObject:(id)object;
- (NSArray *)shiftedIndexPathsOfNodes:(NSArray *)treeNodes;

// Conversion of tree to array for easy lookup
- (NSArray *)flattenedContent;
- (NSArray *)flattenedNodes;
- (NSArray *)flattenedSelectedNodes;
- (NSArray *)flattenedSelectedObjects;
- (NSArray *)flattenedSelectedLeafNodes;
- (NSArray *)flattenedSelectedLeafObjects;
- (NSArray *)flattenedSelectedGroupNodes;
- (NSArray *)flattenedSelectedGroupObjects;

// Selection methods
- (void)selectNone;
- (void)selectParentFromSelection;
- (void)setSelectedNode:(NSTreeNode *)node;
- (void)setSelectedObject:(id)object;

@end

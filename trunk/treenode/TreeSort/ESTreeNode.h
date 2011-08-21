//
//  ESTreeNode.h
//  SortedTree
//
//  Created by Russell on 01/06/2011.
//  Copyright (c) 2011 Jominy Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ESTreeNode;

@interface ESTreeNode : NSManagedObject
{
 @private
}

 @property (nonatomic, retain) NSNumber *isLeaf;
 @property (nonatomic, retain) NSString *displayName;
 @property (nonatomic, retain) NSNumber *sortIndex;
 @property (nonatomic, retain) NSNumber *isSelectable;
 @property (nonatomic, retain) NSSet *children;
 @property (nonatomic, retain) ESTreeNode *parent;

@end

@interface ESTreeNode (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(ESTreeNode *)value;
- (void)removeChildrenObject:(ESTreeNode *)value;
- (void)addChildren:(NSSet *)value;
- (void)removeChildren:(NSSet *)value;

@end
//
//  ESGroupNode.h
//  SortedTree
//
//  Created by Russell on 01/06/2011.
//  Copyright (c) 2011 Jominy Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ESTreeNode.h"


@interface ESGroupNode : ESTreeNode 
{
 @private
}

// Some useful properties
@property (nonatomic, retain) NSNumber *canCollapse;
@property (nonatomic, retain) NSNumber *canExpand;
@property (nonatomic, retain) NSNumber *isExpanded;
@property (nonatomic, retain) NSNumber *isSpecialGroup;

- (NSDictionary *)dictionaryRepresentation;
- (void)setValuesFromDictionaryRepresentation:(NSDictionary *)dict;

@end

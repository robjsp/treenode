//
//  ESLeafNode.h
//  SortedTree
//
//  Created by Russell on 01/06/2011.
//  Copyright (c) 2011 Jominy Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ESTreeNode.h"


@interface ESLeafNode : ESTreeNode
{
 @private
}

- (NSDictionary *)dictionaryRepresentation;
- (void)setValuesFromDictionaryRepresentation:(NSDictionary *)dict;

@end

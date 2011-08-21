//
//  ESLeafNode.m
//  SortedTree
//
//  Created by Russell on 01/06/2011.
//  Copyright (c) 2011 Jominy Research. All rights reserved.
//

#import "ESLeafNode.h"


@implementation ESLeafNode

- (void)awakeFromInsert;
{
	self.isLeaf = [NSNumber numberWithBool:YES];
}

// Write entity attributes into a dictionary for convenient access for example when pasting or moving
// where new comment collections are made and data needs to be copied from the old ones.
- (NSDictionary *)dictionaryRepresentation;
{
	NSMutableDictionary	*dict = [NSMutableDictionary dictionaryWithCapacity:3];
	
	// and the inherited treeNode properties...but not children, parent or sortIndex as these will get updated on insert
    [dict setValue:[self valueForKey:@"isLeaf"] forKey:@"isLeaf"];
    [dict setValue:[self valueForKey:@"displayName"] forKey:@"displayName"];
    [dict setValue:[self valueForKey:@"isSelectable"] forKey:@"isSelectable"];
	
    return dict; 
}

// Use a dictionary to set the entity attributes. Note that the return type is
// a dictionary, here id is used to stop later compiler errors
- (void)setValuesFromDictionaryRepresentation:(NSDictionary *)dict
{
	// and the inherited treeNode properties...but not children, parent or sortIndex as these will get updated on insert
    [self setValue:[dict valueForKey:@"isLeaf"] forKey:@"isLeaf"];
    [self setValue:[dict valueForKey:@"displayName"] forKey:@"displayName"];
    [self setValue:[dict valueForKey:@"isSelectable"] forKey:@"isSelectable"];	
}

@end

//
//  ESGroupNode.m
//  SortedTree
//
//  Created by Russell on 01/06/2011.
//  Copyright (c) 2011 Jominy Research. All rights reserved.
//

#import "ESGroupNode.h"


@implementation ESGroupNode

 @dynamic canCollapse;
 @dynamic canExpand;
 @dynamic isExpanded;
 @dynamic isSpecialGroup;

- (void)awakeFromInsert;
{
	self.isLeaf = [NSNumber numberWithBool:NO];
}

// Write entity attributes into a dictionary for convenient access for example when pasting or moving
// where new comment collections are made and data needs to be copied from the old ones.
- (NSDictionary *)dictionaryRepresentation;
{
	NSMutableDictionary	*dict = [NSMutableDictionary dictionaryWithCapacity:10];
	
	[dict setValue:[self valueForKey: @"canCollapse"] forKey:@"canCollapse"];
	[dict setValue:[self valueForKey:@"canExpand"] forKey:@"canExpand"];
    [dict setValue:[self valueForKey:@"isExpanded"] forKey:@"isExpanded"];
    [dict setValue:[self valueForKey:@"isSpecialGroup"] forKey:@"isSpecialGroup"];
    
    // To allow for archiving of parent and children Object ID's so that a tree can be reconstructed.
	[dict setValue:[[[self valueForKey:@"parent"] objectID] URIRepresentation] forKey:@"parentURI"];
    
    NSSet *children = [self valueForKeyPath:@"children"];
    NSMutableArray *childrenURIs = [NSMutableArray array];
    for(NSManagedObject *child in children) {
        [childrenURIs addObject:[[child objectID] URIRepresentation]];
    }
    [dict setValue:childrenURIs forKey:@"childrenURIs"];
    
    // and the inherited treeNode properties...but not children, parent or sortIndex as these will get updated on insert
    [dict setValue:[self valueForKey:@"isLeaf"] forKey:@"isLeaf"];
    [dict setValue:[self valueForKey:@"displayName"] forKey:@"displayName"];
    [dict setValue:[self valueForKey:@"isSelectable"] forKey:@"isSelectable"];
    [dict setValue:[self valueForKey:@"sortIndex"] forKey:@"sortIndex"];
    
    return dict; 
}

// Use a dictionary to set the entity attributes. Note that the return type is
// a dictionary, here id is used to stop later compiler errors
- (void)setValuesFromDictionaryRepresentation:(NSDictionary *)dict
{
    [self setValue:[dict valueForKey:@"canCollapse"] forKey:@"canCollapse"];
	[self setValue:[dict valueForKey:@"canExpand"] forKey:@"canExpand"];
    [self setValue:[dict valueForKey:@"isExpanded"] forKey:@"isExpanded"];
    [self setValue:[dict valueForKey:@"isSpecialGroup"] forKey:@"isSpecialGroup"];
    
    // and the inherited treeNode properties...but not children, parent or sortIndex as these will get updated on insert
    [self setValue:[dict valueForKey:@"isLeaf"] forKey:@"isLeaf"];
    [self setValue:[dict valueForKey:@"displayName"] forKey:@"displayName"];
    [self setValue:[dict valueForKey:@"isSelectable"] forKey:@"isSelectable"];
}

@end
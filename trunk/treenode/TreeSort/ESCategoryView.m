//
//  ESTableView.m
//  TreeSort
//
//  Created by Russell Newlands on 02/09/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "ESCategoryView.h"
#import "TreeSortAppDelegate.h"
#import "NSManagedObject_Extensions.h"
#import "NSArrayController_Extensions.h"

@implementation ESCategoryView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void)awakeFromNib;
{
    // Get the custom NSArrayController for the categoryView
	NSDictionary *bindingInfo = [self infoForBinding:NSContentBinding]; 
	categoryController = [bindingInfo valueForKey:NSObservedObjectKey];
        
    //Set the custom data types for drag and drop and copy and paste
    categoriesPBoardType = @"categoriesPBoardType";
    
    context = [[NSApp delegate] managedObjectContext];
    
    // Set up a sort order for the entity that depends on the displayOrder attribute
	tableSorter = [[NSSortDescriptor alloc] initWithKey:@"sortIndex"
                                              ascending:YES
                                               selector:@selector(compare:)];
	
    NSArray *sortDescriptors = [NSArray arrayWithObject:tableSorter];
	[categoryController setSortDescriptors:sortDescriptors];
    
    // Set the delegate and dataSource
    [self setDataSource:(id < NSTableViewDataSource >)self];
    [self setDelegate:(id < NSTableViewDelegate >)self];
}


#pragma mark -
#pragma mark Event Handling methods

// Intercept key presses
- (void)keyDown:(NSEvent *)theEvent {
    
//    TreeSortAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
//	
//	if(theEvent) {
//		switch([[theEvent characters] characterAtIndex:0])
//		{
//			case NSDeleteCharacter:
//				[appDelegate deleteItems];
//				break;
//                
//			default:
//				[super keyDown:theEvent];
//				break;
//		}
//	}
}


#pragma mark -
#pragma mark Copy and Paste

- (IBAction)copy:(id)sender;
{
    NSLog(@"Copy called");
    
    if([[categoryController selectedObjects] count] > 0 ) {
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [self writeToPasteboard:pasteBoard];
    }
}


- (IBAction)paste:(id)sender;
{
    NSLog(@"Paste called");
    
    // The generalPasteboard is used for copy and paste operations
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    
    if(![self createObjectsFromPasteboard:pasteBoard]) {
        NSLog(@"Paste unsuccessful. No treeNode property dictionary type found on pasteboard");
        NSBeep();
    }
}


- (IBAction)cut:(id)sender;
{
    NSLog(@"Cut called");
    
    if([[categoryController selectedObjects] count] > 0 ) {
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [self writeToPasteboard:pasteBoard];
    }
    
    [categoryController removeObjectsAtArrangedObjectIndexes:[categoryController selectionIndexes]];
}


- (IBAction)delete:(id)sender;
{
    NSLog(@"Delete called");
    [categoryController removeObjectsAtArrangedObjectIndexes:[categoryController selectionIndexes]]; 
}


- (void)writeToPasteboard:(NSPasteboard *)pasteBoard
{
    /*  The elected managed objects are found. The properties of each node are then
        read into a dictionary which is inserted into an array.
     */
    
    NSArray *selectedObjects = [categoryController selectedObjects];
    NSMutableArray *selectedObjectProps = [NSMutableArray array]; // Array of selected object properties for archiving
    
    // Return a dictionary of all objects attributes, their name and their relationship data. These will be ordered.
    for(id managedObject in selectedObjects) {
        [selectedObjectProps addObjectsFromArray:[managedObject objectPropertyTreeInContext:context]];
    }
    
	NSData *copyData = [NSKeyedArchiver archivedDataWithRootObject:selectedObjectProps];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:categoriesPBoardType, nil] owner:self]; 
    [pasteBoard setData:copyData forType:categoriesPBoardType];
    
    NSLog(@"Copied properties are %@", selectedObjectProps);
}


- (BOOL)createObjectsFromPasteboard:(NSPasteboard *)pasteBoard
{   
    NSArray *types = [pasteBoard types];
    if([types containsObject:categoriesPBoardType]) {
        NSData  *data = [pasteBoard dataForType:categoriesPBoardType];
        
        /*  The data is archived up as a series of NSDictionaries when copy or drag occurs, so unarchive first
         The objects are created and the URI representation used to set their properties. The properties copied
         include all attributes, the related object URI's and the original indexPaths for treeNode objects
         */
        
        NSArray *copiedProperties;
        if(data) {
            copiedProperties = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSLog(@"Pasted properties are %@", copiedProperties);

            NSUInteger insertionIndex = [categoryController indexForInsertion];

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
                
                [categoryController insertObject:newManagedObject atArrangedObjectIndex:insertionIndex];
                insertionIndex++;

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
            return YES;
        }
    }    
    return NO;
}


#pragma mark -
#pragma mark NSTableView Drag and Drop Delegate Methods

// This method is invoked by an tableView after determination that drag
// should begin but before the drag has started. An example of a datasource
// delegate protocol. This defines methods that tableView invokes to
// retrieve data and info about data from datasource delegate. All other
// responisibilities handled by regular delegate

- (BOOL)tableView:(NSTableView *)categoryTable writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pasteBoard
{	
    // Called when item dragging begins
    // Copy the row numbers to the pasteboard.
    NSLog(@"Drag Initiated");
    NSData *tableViewRowIndexes = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pasteBoard declareTypes:[NSArray arrayWithObject:categoriesPBoardType] owner:self];
    [pasteBoard setData:tableViewRowIndexes forType:categoriesPBoardType];
    return YES;
}


- (NSDragOperation)tableView:(NSTableView *)view
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(int)row
       proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    NSLog(@"Validating Drag");
    
    NSDragOperation result = NSDragOperationNone;
    
    // Check to see if the drop is on an item. Don't allow this, only allow inbetween row drops
    BOOL isDropOnItemProposal = (dropOperation == NSTableViewDropOn);
    
    if(!isDropOnItemProposal) {
        // copy if it's not from our view or if the option/alt key is being held down, otherwise move
        if ([info draggingSource] != view || [[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask)
            result = NSDragOperationCopy;
        else
            result = NSDragOperationMove;
    } else
        result = NSDragOperationNone;
    
    return result;
}



//NSPasteboard* pboard = [info draggingPasteboard];
//NSData* rowData = [pboard dataForType:MyPrivateTableViewDataType];
//NSIndexSet* rowIndexes = 
//[NSKeyedUnarchiver unarchiveObjectWithData:rowData];
//NSInteger dragRow = [rowIndexes firstIndex];

// Move the specified row to its new location...
// if we remove a row then everything moves down by one
// so do an insert prior to the delete
// --- depends which way were moving the data!!!
//if (dragRow < row) {
//    [nsAryOfDataValues insertObject:
//     [nsAryOfDataValues objectAtIndex:dragRow] atIndex:row];
//    [nsAryOfDataValues removeObjectAtIndex:dragRow];
//    [self.nsTableViewObj noteNumberOfRowsChanged];
//    [self.nsTableViewObj reloadData];
//    
//    return YES;
//    
//} // end if
//
//MyData * zData = [nsAryOfDataValues objectAtIndex:dragRow];
//[nsAryOfDataValues removeObjectAtIndex:dragRow];
//[nsAryOfDataValues insertObject:zData atIndex:row];
//[self.nsTableViewObj noteNumberOfRowsChanged];
//[self.nsTableViewObj reloadData];
//
//return YES;






- (BOOL)tableView:(NSTableView*)aTableView
       acceptDrop:(id <NSDraggingInfo>)info
              row:(int)row
    dropOperation:(NSTableViewDropOperation)dropOperation
{
    
    return YES;
//    NSPasteboard  *pboard = [info draggingPasteboard];
//	
//	if ([info draggingSourceOperationMask] == 0 ) //i.e. the dragging source does not permit drags
//		return NO;
//    
//	NSString  *type = [pboard availableTypeFromArray:[NSArray arrayWithObject:categoriesPBoardType]];
//	
//	// Does pasteboard type exist AND is it of type 'categoriesPBoardType'?
//	if (type && [type isEqualToString:categoriesPBoardType]) {
//		
//        NSData *rowData = [pboard dataForType:categoriesPBoardType];
//        NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
//        NSInteger dragRow = [rowIndexes firstIndex];
//        
//        // If draggingSource is the outlineView and the drag is a move (not a copy because modifier key not held down)
//        // This works because only matching bits will become 1 with the bitwise '&' operator
//        if ([info draggingSource] == aTableView && ([info draggingSourceOperationMask] & NSDragOperationMove)) {
//            // A cut then paste operation. Can't be bothered to do a move here.
//            // If deleting is set to cascade all children will automatically be deleted too
//            //				[self removeManagedObjectUsingDataURIs:data];
//            //				newManagedObjects = [self newTableObjectsFromData:data ofManagedObject:parentMO withDisplayOrder:newDisplayOrder];
//        }
//        else {
//            // The modifier key was held down so do a copy				
//            //				newManagedObjects = [self newTableObjectsFromData:data ofManagedObject:parentMO withDisplayOrder:newDisplayOrder];
//        }
//        
//        // if the app is in the background, then force the context to process changes so the view updates
//        // (otherwise, may wait until the app is brought forward)
//        //			[[[NSApp delegate] managedObjectContext] processPendingChanges];
//        
//        // if the app is in the background, then force the context to process changes so the view updates
//        // (otherwise, may wait until the app is brought forward)
//        //			[self resortManagedObjectArray:[tableArrayController arrangedObjects] withKey:@"displayOrder"];			
//        //			
//        //			NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
//        //			
//        //			if (newManagedObjects) {
//        //				[tableArrayController setSelectedObjects:newManagedObjects];								
//        //				if ([newManagedObjects count] > 1) {
//        //					[[context undoManager] setActionName:[tableProperties valueForKey:@"moveTableRowsMsg"]];	
//        //				} else {
//        //					[[context undoManager] setActionName:[tableProperties valueForKey:@"moveTableRowMsg"]];					
//        //				}
//        //			}
//        
//        return YES;			
//	}
//	
//	return NO;
}


- (void)dealloc
{
    [tableSorter release];
    [super dealloc];
}

@end

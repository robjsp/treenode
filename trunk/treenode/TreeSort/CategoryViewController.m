//
//  CategoryViewController.m
//  TreeSort
//
//  Created by Russell Newlands on 31/10/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import "CategoryViewController.h"
#import "ESCategory.h"

@implementation CategoryViewController

@synthesize categoryView;

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
    // Get the NSArrayController for the categoryView
	NSDictionary *bindingInfo = [categoryView infoForBinding:NSContentBinding]; 
	categoryController = [bindingInfo valueForKey:NSObservedObjectKey];
    
    //Set the custom data types for drag and drop and copy and paste
    categoriesPBoardType = @"categoriesPBoardType";
    
    context = [[NSApp delegate] managedObjectContext];
}


- (IBAction)newCategory:(id)sender;
{
    ESCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
    
    static NSUInteger count = 0;
    category.displayName = [NSString stringWithFormat:@"Category %i",++count];
    NSLog(@"newCategory with name = %@", category.displayName);
    
    [categoryController insertObject:category atArrangedObjectIndex:[[categoryController arrangedObjects] count]];	
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



NSPasteboard* pboard = [info draggingPasteboard];
NSData* rowData = [pboard dataForType:MyPrivateTableViewDataType];
NSIndexSet* rowIndexes = 
[NSKeyedUnarchiver unarchiveObjectWithData:rowData];
NSInteger dragRow = [rowIndexes firstIndex];

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
    NSPasteboard  *pboard = [info draggingPasteboard];
	
	if ([info draggingSourceOperationMask] == 0 ) //i.e. the dragging source does not permit drags
		return NO;
        
	NSString  *type = [pboard availableTypeFromArray:[NSArray arrayWithObject:categoriesPBoardType]];
	
	// Does pasteboard type exist AND is it of type 'categoriesPBoardType'?
	if (type && [type isEqualToString:categoriesPBoardType]) {
		
        NSData *rowData = [pboard dataForType:categoriesPBoardType];
        NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
        NSInteger dragRow = [rowIndexes firstIndex];
        
        // If draggingSource is the outlineView and the drag is a move (not a copy because modifier key not held down)
        // This works because only matching bits will become 1 with the bitwise '&' operator
        if ([info draggingSource] == aTableView && ([info draggingSourceOperationMask] & NSDragOperationMove)) {
            // A cut then paste operation. Can't be bothered to do a move here.
            // If deleting is set to cascade all children will automatically be deleted too
//				[self removeManagedObjectUsingDataURIs:data];
//				newManagedObjects = [self newTableObjectsFromData:data ofManagedObject:parentMO withDisplayOrder:newDisplayOrder];
        }
        else {
            // The modifier key was held down so do a copy				
//				newManagedObjects = [self newTableObjectsFromData:data ofManagedObject:parentMO withDisplayOrder:newDisplayOrder];
        }
        
        // if the app is in the background, then force the context to process changes so the view updates
        // (otherwise, may wait until the app is brought forward)
//			[[[NSApp delegate] managedObjectContext] processPendingChanges];
        
        // if the app is in the background, then force the context to process changes so the view updates
        // (otherwise, may wait until the app is brought forward)
//			[self resortManagedObjectArray:[tableArrayController arrangedObjects] withKey:@"displayOrder"];			
//			
//			NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
//			
//			if (newManagedObjects) {
//				[tableArrayController setSelectedObjects:newManagedObjects];								
//				if ([newManagedObjects count] > 1) {
//					[[context undoManager] setActionName:[tableProperties valueForKey:@"moveTableRowsMsg"]];	
//				} else {
//					[[context undoManager] setActionName:[tableProperties valueForKey:@"moveTableRowMsg"]];					
//				}
//			}
            
			return YES;			
	}
	
	return NO;
}


@end

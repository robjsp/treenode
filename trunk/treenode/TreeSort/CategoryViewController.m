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


@end

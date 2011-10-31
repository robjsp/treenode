//
//  CategoryViewController.h
//  TreeSort
//
//  Created by Russell Newlands on 31/10/2011.
//  Copyright 2011 Jominy Research. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESCategoryView;

@interface CategoryViewController : NSObject
{
    NSManagedObjectContext *context;
    NSArrayController *categoryController;
}

@property (assign) IBOutlet ESCategoryView *categoryView;

- (IBAction)newCategory:(id)sender;

@end

//
//  PhotoBoxFetchedResultsController.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/6/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxFetchedResultsController.h"

#import <MTLManagedObjectAdapter.h>

@interface PhotoBoxFetchedResultsController ()

@property (nonatomic, strong) NSCache *mantleItems;

@end

@implementation PhotoBoxFetchedResultsController

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.mantleItems objectForKey:indexPath];
    if (!object) {
        id managedObject = [super objectAtIndexPath:indexPath];
        NSError *error;
        object = [MTLManagedObjectAdapter modelOfClass:self.objectClass fromManagedObject:managedObject error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
        }
        [self.mantleItems setObject:object forKey:indexPath];
    }
    return object;
}

- (NSCache *)mantleItems {
    if (!_mantleItems) {
        _mantleItems = [[NSCache alloc] init];
    }
    return _mantleItems;
}

@end

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

@end

@implementation PhotoBoxFetchedResultsController

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [super objectAtIndexPath:indexPath];
    
    id object = [self.mantleItemsCache objectForKey:managedObject];
    if (!object) {
        
        NSError *error;
        object = [MTLManagedObjectAdapter modelOfClass:self.objectClass fromManagedObject:managedObject error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
        }
        [self.mantleItemsCache setObject:object forKey:managedObject];
    }
    return object;
}

- (NSCache *)mantleItemsCache {
    if (!_mantleItemsCache) {
        _mantleItemsCache = [[NSCache alloc] init];
    }
    return _mantleItemsCache;
}

@end

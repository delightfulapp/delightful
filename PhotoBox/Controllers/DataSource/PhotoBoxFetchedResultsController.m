//
//  PhotoBoxFetchedResultsController.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/6/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxFetchedResultsController.h"

#import <MTLManagedObjectAdapter.h>

@interface ModelManagedObject : NSObject

@property (nonatomic, strong) id model;
@property (nonatomic, strong) id managedObject;

@end

@implementation ModelManagedObject


@end

@interface PhotoBoxFetchedResultsController ()

@end

@implementation PhotoBoxFetchedResultsController

- (id)mantleObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [self objectAtIndexPath:indexPath];
    
    NSString *key = [managedObject valueForKey:self.itemKey];
    ModelManagedObject *object = [self.mantleItemsCache objectForKey:key];
    if (!object) {
        
        NSError *error;
        id managed = [MTLManagedObjectAdapter modelOfClass:self.objectClass fromManagedObject:managedObject error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
        }
        object = [[ModelManagedObject alloc] init];
        object.managedObject = managedObject;
        object.model = managed;
        [self.mantleItemsCache setObject:object forKey:key];
    }
    return object.model;
}

- (NSIndexPath *)indexPathForObject:(id)object {
    if ([object isKindOfClass:[MTLModel class]]) {
        NSString *key = [object valueForKey:self.itemKey];
        ModelManagedObject *obj = [self.mantleItemsCache objectForKey:key];
        if (obj) {
            return [super indexPathForObject:obj.managedObject];
        }
    } else {
        return [super indexPathForObject:object];
    }
    
    return [NSIndexPath indexPathForItem:0 inSection:0];
}

- (NSCache *)mantleItemsCache {
    if (!_mantleItemsCache) {
        _mantleItemsCache = [[NSCache alloc] init];
    }
    return _mantleItemsCache;
}

@end

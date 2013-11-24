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

@property (nonatomic, strong) NSCache *mantleItemsCache;

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
            CLS_LOG(@"Error: %@", error);
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
        [_mantleItemsCache setName:@"photobox.cache.mantleitems"];
    }
    return _mantleItemsCache;
}

- (void)clearCache {
    [self.mantleItemsCache removeAllObjects];
}

- (void)preLoadCache {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i< self.sections.count; i++) {
            id<NSFetchedResultsSectionInfo> section = self.sections[i];
            NSInteger numberOfObjectsInSection = section.numberOfObjects;
            for (int j=0; j<numberOfObjectsInSection; j++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
                [self mantleObjectAtIndexPath:indexPath];
            }
        }
    });
    
}

@end

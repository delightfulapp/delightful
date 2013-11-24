//
//  PhotoBoxRequestOperation.m
//  PhotoBox
//
//  Created by Nico Prananta on 10/4/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxRequestOperation.h"

@interface PhotoBoxRequestOperation ()

@property (strong, nonatomic, readwrite) id responseObject;
@property (strong, nonatomic) NSRecursiveLock *lock;

@end

@implementation PhotoBoxRequestOperation

@dynamic lock;
@synthesize responseObject = _responseObject;

// override Overcoat's responseObject to perform managed object serialization
- (id)responseObject {
    [self.lock lock];
    if (!_responseObject) {
        id responseJSON = self.responseJSON;
        if (responseJSON) {
            if (self.valueTransformer) {
                self.responseObject = [self.valueTransformer transformedValue:responseJSON];

                if (self.useCoreData) {
                    NSManagedObjectContext *workContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                    workContext.mergePolicy					= NSMergeByPropertyObjectTrumpMergePolicy;
                    workContext.persistentStoreCoordinator	= [NSPersistentStoreCoordinator persistentStoreCoordinator];
                    [self serializeToManagedObject:self.responseObject inContext:workContext];
                }
            }
            else {
                self.responseObject = self.responseJSON;
            }
        }
    }
    [self.lock unlock];
    
    return _responseObject;
}

- (void)serializeToManagedObject:(id)responseObject inContext:(NSManagedObjectContext *)context {
    NSError *error;
    if ([responseObject isKindOfClass:[NSArray class]]) {
        for (id obj in responseObject) {
            [MTLManagedObjectAdapter managedObjectFromModel:obj insertingIntoContext:context error:&error];
        }
    } else {
        [MTLManagedObjectAdapter managedObjectFromModel:responseObject insertingIntoContext:context error:&error];
    }

    [context save:&error];
    if (error) {
        CLS_LOG(@"Fail saving objects to db: %@", error);
    }
}

@end

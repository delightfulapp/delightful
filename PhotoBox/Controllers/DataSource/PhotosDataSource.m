//
//  PhotosDataSource.m
//  Delightful
//
//  Created by Nico Prananta on 2/6/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotosDataSource.h"

@implementation PhotosDataSource

@synthesize fetchedResultsController = _fetchedResultsController;

@synthesize paused = _paused;

- (void)setFetchedResultsController:(PhotoBoxFetchedResultsController*)fetchedResultsController
{
    if (_fetchedResultsController != fetchedResultsController) {
        _fetchedResultsController = fetchedResultsController;
        
        if (_fetchedResultsController) {
            _paused = NO;
            _fetchedResultsController.delegate = self;
            
            
            if ([self.collectionView numberOfSections] == 0) {
                NSError *error;
                [self.fetchedResultsController performFetch:&error];
                if (error) {
                    PBX_LOG(@"Error perform fetch: %@", error);
                } else {
                    NSInteger index = 0;
                    for (id<NSFetchedResultsSectionInfo>section in self.fetchedResultsController.sections) {
                        [self controller:self.fetchedResultsController didChangeSection:section atIndex:index forChangeType:NSFetchedResultsChangeInsert];
                        for (NSInteger item = 0; item < [section numberOfObjects]; item++) {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:index];
                            [self controller:self.fetchedResultsController didChangeObject:nil atIndexPath:nil forChangeType:NSFetchedResultsChangeInsert newIndexPath:indexPath];
                        }
                        index++;
                    }
                    if (self.sectionChanges.count > 0 && self.sectionChanges) {
                        [self controllerDidChangeContent:self.fetchedResultsController];
                    }
                    
                }
            }
        }
        
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.fetchedResultsController clearCache];
    [self.fetchedResultsController preLoadCache];
    
    if (self.sectionChanges.count > 0) {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in self.sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
            
            for (NSDictionary *change in self.objectChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                    }
                }];
            }
            
        } completion:^(BOOL finished) {
            for (int i = 0; i< self.fetchedResultsController.sections.count; i++) {
                for (int j=0; j<[self collectionView:self.collectionView numberOfItemsInSection:i]; j++) {
                    @autoreleasepool {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
                        [self itemAtIndexPath:indexPath];
                    }
                }
            }
        }];
    }
    
    
    [self.sectionChanges removeAllObjects];
    [self.objectChanges removeAllObjects];
}

@end

//
//  OGCoreDataStackVendor.m
//
//  Created by Jesper <jesper@orangegroove.net>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "OGCoreDataStackVendor.h"
#import "OGCoreDataStackPrivate.h"
#import "OGCoreDataStack.h"

@interface OGCoreDataStackVendor ()

@property (strong, nonatomic) NSFetchedResultsController*	fetchedResultsController;
@property (strong, nonatomic) NSMutableIndexSet*			insertedSections;
@property (strong, nonatomic) NSMutableIndexSet*			deletedSections;
@property (strong, nonatomic) NSMutableArray*				insertedObjects;
@property (strong, nonatomic) NSMutableArray*				deletedObjects;
@property (strong, nonatomic) NSMutableArray*				updatedObjects;

- (BOOL)indexPathIsValid:(NSIndexPath *)indexPath;

@end
@implementation OGCoreDataStackVendor

#pragma mark - Public

- (void)fetchEntity:(Class)entity withRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)cacheName
{
	NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:[entity entityName]];
	
	if (block)
		block(request);
	
	_fetchRequest			= request;
	_managedObjectContext	= context;
	_sectionNameKeyPath		= sectionNameKeyPath;
	_cacheName				= cacheName;
}

- (NSInteger)numberOfSections
{
	return (NSInteger)_fetchedResultsController.sections.count;
}

- (NSInteger)numberOfObjectsInSection:(NSInteger)section
{
	NSArray* sections = _fetchedResultsController.sections;
	
	if (section > ((NSInteger)sections.count)-1)
		return 0;
	
	id<NSFetchedResultsSectionInfo> sectionInfo = sections[(NSUInteger)section];
	
	return (NSInteger)sectionInfo.numberOfObjects;
}

- (NSInteger)totalNumberOfObjects
{
	NSInteger count = 0;
	
	for (NSInteger i = 0; i < self.numberOfSections; i++)
		count += [self numberOfObjectsInSection:i];
	
	return 0;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
	if (![self indexPathIsValid:indexPath])
		return nil;
	
	return [_fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForObject:(id)object
{
	return [_fetchedResultsController indexPathForObject:object];
}

- (id)firstObject
{
	NSIndexPath* indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
	
	return [self objectAtIndexPath:indexPath];
}

- (id)lastObject
{
	NSInteger section		= self.numberOfSections-1;
	NSInteger item			= [self numberOfObjectsInSection:section]-1;
	NSIndexPath* indexPath	= [NSIndexPath indexPathForItem:item inSection:section];
	
	return [self objectAtIndexPath:indexPath];
}

- (id)firstObjectInSection:(NSInteger)section
{
	NSIndexPath* indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
	
	return [self objectAtIndexPath:indexPath];
}

- (id)lastObjectInSection:(NSInteger)section
{
	NSInteger item			= [self numberOfObjectsInSection:section]-1;
	NSIndexPath* indexPath	= [NSIndexPath indexPathForItem:item inSection:section];
	
	return [self objectAtIndexPath:indexPath];
}

- (NSArray *)objectsInSection:(NSInteger)section
{
	NSArray* sections = _fetchedResultsController.sections;
	
	if (section > ((NSInteger)sections.count)-1)
		return nil;
	
	id<NSFetchedResultsSectionInfo> sectionInfo = sections[(NSUInteger)section];
	
	return sectionInfo.objects;
}

- (NSArray *)allObjects
{
	NSArray* sections		= _fetchedResultsController.sections;
	NSMutableArray* objects = [NSMutableArray array];
	
	for (id<NSFetchedResultsSectionInfo> sectionInfo in sections)
		[objects addObjectsFromArray:sectionInfo.objects];
	
	return [NSArray arrayWithArray:objects];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	if (_objectsUpdated)
		_objectsUpdated(self.insertedSections, self.deletedSections, self.insertedObjects, self.deletedObjects, self.updatedObjects);
	
	_deletedSections	= nil;
	_insertedSections	= nil;
	_deletedObjects		= nil;
	_insertedObjects	= nil;
	_updatedObjects		= nil;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	switch (type) {
			
		case NSFetchedResultsChangeInsert:
			
			[self.insertedSections addIndex:sectionIndex];
			
			break;
			
		case NSFetchedResultsChangeDelete:
			
			[self.deletedSections addIndex:sectionIndex];
			
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	switch (type) {
		case NSFetchedResultsChangeInsert:
			
			if (![self.insertedSections containsIndex:newIndexPath.section])
				[self.insertedObjects addObject:newIndexPath];
			
			break;
			
		case NSFetchedResultsChangeDelete:
			
			if (![self.deletedSections containsIndex:indexPath.section])
				[self.deletedObjects addObject:indexPath];
			
			break;
			
		case NSFetchedResultsChangeMove:
			
			if (![self.insertedSections containsIndex:newIndexPath.section])
				[self.insertedObjects addObject:newIndexPath];
			
			if (![self.deletedSections containsIndex:indexPath.section])
				[self.deletedObjects addObject:indexPath];
			
			break;
			
		case NSFetchedResultsChangeUpdate:
			
			[self.updatedObjects addObject:indexPath];
			
			break;
	}
}

#pragma mark - Helpers

- (BOOL)indexPathIsValid:(NSIndexPath *)indexPath
{
	if (indexPath.section >= _fetchedResultsController.sections.count)
		return NO;
	
	id<NSFetchedResultsSectionInfo> info = _fetchedResultsController.sections[(NSUInteger)indexPath.section];
	
	if (indexPath.item >= info.numberOfObjects)
		return NO;
	
	return YES;
}

#pragma mark - Properties

- (void)setVending:(BOOL)vending
{
	if (vending && !_vending) {
		
		if (!_fetchRequest || !_managedObjectContext) {
			
#ifdef DEBUG
			OGCoreDataStackLog(@"Cannot vend without fetchRequest and managedObjectContext");
#endif
			return;
		}
		
		_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:_sectionNameKeyPath cacheName:_cacheName];
		
		_fetchedResultsController.delegate	= self;
		NSError* error						= nil;
		vending								= [_fetchedResultsController performFetch:&error];
		
		if (!vending) {
#ifdef DEBUG
			NSLog(@"%@", error);
#endif
			self.vending = NO;
		}
	}
	else if (!vending) {
		
		_fetchedResultsController.delegate	= nil;
		_fetchedResultsController			= nil;
	}
	
	_vending = vending;
}

- (NSMutableIndexSet *)deletedSections
{
	if (_deletedSections)
		return _deletedSections;
	
	_deletedSections = [NSMutableIndexSet indexSet];
	
	return _deletedSections;
}

- (NSMutableIndexSet *)insertedSections
{
	if (_insertedSections)
		return _insertedSections;
	
	_insertedSections = [NSMutableIndexSet indexSet];
	
	return _insertedSections;
}

- (NSMutableArray *)insertedObjects
{
	if (_insertedObjects)
		return _insertedObjects;
	
	_insertedObjects = [NSMutableArray array];
	
	return _insertedObjects;
}

- (NSMutableArray *)deletedObjects
{
	if (_deletedObjects)
		return _deletedObjects;
	
	_deletedObjects = [NSMutableArray array];
	
	return _deletedObjects;
}

- (NSMutableArray *)updatedObjects
{
	if (_updatedObjects)
		return _updatedObjects;
	
	_updatedObjects = [NSMutableArray array];
	
	return _updatedObjects;
}

@end

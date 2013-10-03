//
//  NSManagedObjectContext+OGCoreDataStack.m
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

#import "NSManagedObjectContext+OGCoreDataStack.h"
#import "OGCoreDataStackPrivate.h"
#import "OGCoreDataStack.h"

static dispatch_once_t			_ogMainManagedObjectContextToken	= 0;
static dispatch_once_t			_ogWorkManagedObjectContextToken	= 0;
static NSManagedObjectContext*	_ogMainManagedObjectContext			= nil;
static NSManagedObjectContext*	_ogWorkManagedObjectContext			= nil;
static id						_ogWorkContextObserver				= nil;

@implementation NSManagedObjectContext (OGCoreDataStack)

#pragma mark - Lifecycle

+ (instancetype)mainContext
{
	dispatch_once(&_ogMainManagedObjectContextToken, ^{
		
		_ogMainManagedObjectContext								= [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		_ogMainManagedObjectContext.mergePolicy					= NSMergeByPropertyObjectTrumpMergePolicy;
		_ogMainManagedObjectContext.persistentStoreCoordinator	= [NSPersistentStoreCoordinator persistentStoreCoordinator];
		_ogWorkContextObserver									= [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:[self workContext] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			
			[_ogMainManagedObjectContext mergeChangesFromContextDidSaveNotification:note];
		}];
	});
	
	return _ogMainManagedObjectContext;
}

+ (instancetype)workContext
{
	dispatch_once(&_ogWorkManagedObjectContextToken, ^{
		
		_ogWorkManagedObjectContext								= [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
		_ogWorkManagedObjectContext.mergePolicy					= NSMergeByPropertyObjectTrumpMergePolicy;
		_ogWorkManagedObjectContext.persistentStoreCoordinator	= [NSPersistentStoreCoordinator persistentStoreCoordinator];
	});
	
	return _ogWorkManagedObjectContext;
}

- (BOOL)save
{
	if (!self.hasChanges)
		return YES;
	
	NSError* error	= nil;
	BOOL success	= [self save:&error];
	
#ifdef DEBUG
	if (!success)
		OGCoreDataStackLog(@"Save Error: %@", error.localizedDescription);
#endif
	
	return success;
}

#pragma mark - Operations

- (void)performBlock:(void (^)(NSArray *))block passObjects:(NSArray *)objects
{
	NSMutableArray* objectIDs = [NSMutableArray arrayWithCapacity:objects.count];
	
	for (NSManagedObject* object in objects)
		[objectIDs addObject:object.objectID];
	
	[self performBlock:^{
		
		NSMutableArray* passedObjects = [NSMutableArray array];
		
		for (NSManagedObjectID* objectID in objectIDs) {
			
			NSManagedObject* object = [NSManagedObject fetchWithObjectID:objectID context:self];
			
			if (object)
				[passedObjects addObject:object];
		}
		
		block([NSArray arrayWithArray:passedObjects]);
	}];
}

- (void)performBlockAndWait:(void (^)(NSArray *))block passObjects:(NSArray *)objects
{
	NSMutableArray* objectIDs = [NSMutableArray arrayWithCapacity:objects.count];
	
	for (NSManagedObject* object in objects)
		[objectIDs addObject:object.objectID];
	
	[self performBlockAndWait:^{
		
		NSMutableArray* passedObjects = [NSMutableArray array];
		
		for (NSManagedObjectID* objectID in objectIDs) {
			
			NSManagedObject* object = [NSManagedObject fetchWithObjectID:objectID context:self];
			
			if (object)
				[passedObjects addObject:object];
		}
		
		block([NSArray arrayWithArray:passedObjects]);
	}];
}

#pragma mark - Miscellaneous

- (BOOL)obtainPermanentIDsForObjects:(NSArray *)objects
{
	NSError* error	= nil;
	BOOL success	= [self obtainPermanentIDsForObjects:objects error:&error];
	
#ifdef DEBUG
	if (!success)
		OGCoreDataStackLog(@"ObtainPermanentIDs Error: %@", error.localizedDescription);
#endif
	
	return success;
}

#pragma mark - Private

+ (void)_ogResetMainManagedObjectContext
{
	if (_ogWorkContextObserver)
		[[NSNotificationCenter defaultCenter] removeObserver:_ogWorkContextObserver];
	
	_ogMainManagedObjectContextToken	= 0;
	_ogMainManagedObjectContext			= nil;
}

+ (void)_ogResetWorkManagedObjectContext
{
	_ogWorkManagedObjectContextToken	= 0;
	_ogWorkManagedObjectContext			= nil;
}

@end

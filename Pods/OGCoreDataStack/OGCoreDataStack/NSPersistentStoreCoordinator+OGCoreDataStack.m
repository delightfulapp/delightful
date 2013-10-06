//
//  NSPersistentStoreCoordinator+OGCoreDataStack.m
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

#import "NSPersistentStoreCoordinator+OGCoreDataStack.h"
#import "OGCoreDataStackPrivate.h"
#import "OGCoreDataStack.h"

static dispatch_once_t					_ogPersistentStoreCoordinatorToken	= 0;
static NSPersistentStoreCoordinator*	_ogPersistentStoreCoordinator		= nil;
static NSDictionary*					_ogPersistentStoreOptions			= nil;

@implementation NSPersistentStoreCoordinator (OGCoreDataStack)

#pragma mark - Lifecycle

+ (instancetype)persistentStoreCoordinator
{
	dispatch_once(&_ogPersistentStoreCoordinatorToken, ^{
		
		NSError* error					= nil;
		_ogPersistentStoreCoordinator	= [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel managedObjectModel]];
		
		if (!_ogPersistentStoreOptions)
			_ogPersistentStoreOptions = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
		
		if (![_ogPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:_ogSQLiteURL() options:_ogPersistentStoreOptions error:&error]) {
#ifdef DEBUG
			OGCoreDataStackLog(@"Add Persistent Store Error: %@", error.localizedDescription);
			OGCoreDataStackLog(@"Missing migration? %@", ![error.userInfo[@"sourceModel"] isEqual:error.userInfo[@"destinationModel"]] ? @"YES" : @"NO");
#endif
		}
	});
	
	return _ogPersistentStoreCoordinator;
}

+ (BOOL)clearPersistentStore
{
	if (!_ogPersistentStoreCoordinator.persistentStores.count)
		return YES;
	
	NSError* error	= nil;
	NSString* path	= _ogSQLiteURL().path;
	
	if (![_ogPersistentStoreCoordinator removePersistentStore:_ogPersistentStoreCoordinator.persistentStores[0] error:&error]) {
#ifdef DEBUG
		OGCoreDataStackLog(@"Remove Persistent Store Error: %@", error.localizedDescription);
#endif
		return NO;
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
		return YES;
	
	if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
#ifdef DEBUG
		OGCoreDataStackLog(@"Remove Persistent Store File Error: %@", error.localizedDescription);
#endif
		return NO;
	}
	
	[NSManagedObjectModel _ogResetManagedObjectModel];
	[NSManagedObjectContext _ogResetMainManagedObjectContext];
	[NSManagedObjectContext _ogResetWorkManagedObjectContext];
	
	_ogPersistentStoreCoordinatorToken	= 0;
	_ogPersistentStoreCoordinator		= nil;
	
	return YES;
}

#pragma mark - Configuration

+ (void)setPersistentStoreCoordinatorOptions:(NSDictionary *)options
{
	_ogPersistentStoreOptions = options;
}

@end

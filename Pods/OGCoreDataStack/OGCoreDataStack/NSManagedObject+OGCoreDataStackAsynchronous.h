//
//  NSManagedObject+OGCoreDataStackAsynchronous.h
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

//
//  Assumptions:
//  Any objects are returned to the main context.
//  All background work is done in the work context.
//

#import <CoreData/CoreData.h>
#import "OGCoreDataStackCommon.h"

@interface NSManagedObject (OGCoreDataStackAsynchronous)

/** @name Deleting */

/**
 Deletes objects asynchronously in the work context.
 @param block Passes the NSFetchRequest for configuration.
 @param completion The block to be run upon completion. Runs on the main thread.
 @warning Do set a predicate on the NSFetchRequest in the block, otherwise this method will delete all objects with this entity.
 */
+ (void)asynchronouslyDeleteWithRequest:(OGCoreDataStackFetchRequestBlock)block completion:(OGCoreDataStackDeleteCompletionBlock)completion;

/** @name Counting */

/**
 Deletes objects asynchronously in the work context.
 @param block Passes the NSFetchRequest for configuration.
 @param completion The block to be run upon completion. Runs on the main thread.
 */
+ (void)asynchronouslyCountWithRequest:(OGCoreDataStackFetchRequestBlock)block completion:(OGCoreDataStackCountCompletionBlock)completion;

/** @name Fetching */

/**
 Fetches objects asynchronously in the work context.
 @param block Passes the NSFetchRequest for configuration.
 @param completion The block to be run upon completion. Runs on the main thread.
 @note Because NSManagedObjects are not thread safe, objects are first fetched in the work context, and then re-fetched in the main context, but with simple predicate. This requires two roundtrips to the persistent store, so it is probably only useful for very complicated predicates.
 */
+ (void)asynchronouslyFetchWithRequest:(OGCoreDataStackFetchRequestBlock)block completion:(OGCoreDataStackFetchCompletionBlock)completion;

/**
 Fetches objects asynchronously where values match keyPath in the work context.
 @param keyPath The keyPath used for identification.
 @param values The identification values.
 @param block Passes the NSFetchRequest for configuration.
 @param allowNil Whether or not to allow objects not to exist. If this is NO, any objects not found for a value are created, and the value for keyPath is set.
 @note The intended use for this is mapping objects to remote database, where each object has an id.
 @param completion The block to be run upon completion. Runs on the main thread.
 @note Because NSManagedObjects are not thread safe, objects are first fetched in the work context, and then re-fetched in the main context, but with simple predicate. This requires two roundtrips to the persistent store, so it is probably only useful for very complicated predicates.
 */
+ (void)asynchronouslyFetchWithKeyPath:(NSString *)keyPath matchingValues:(NSArray *)values request:(OGCoreDataStackFetchRequestBlock)block allowNil:(BOOL)allowNil completion:(OGCoreDataStackFetchCompletionBlock)completion;

@end

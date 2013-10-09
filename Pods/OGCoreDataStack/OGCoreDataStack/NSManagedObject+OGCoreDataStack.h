//
//  NSManagedObject+OGCoreDataStack.h
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

#import <CoreData/CoreData.h>
#import "OGCoreDataStackCommon.h"

@interface NSManagedObject (OGCoreDataStack)

/** @name Lifecycle */

/**
 The entity name for this class. Override this if your entity is not named the same as your class.
 @return The entity name in the NSManagedObjectModel.
 */
+ (NSString *)entityName;

/** @name Inserting */

/**
 Inserts a new object into a context.
 @param context The context.
 @return The inserted object.
 */
+ (instancetype)insertInContext:(NSManagedObjectContext *)context;

/** @name Deleting */

/**
 Deletes the current object from its context.
 */
- (void)delete;

/**
 Deletes objects from a context.
 @param block Passes the NSFetchRequest for configuration.
 @param context The context in which to delete objects.
 @warning Do set a predicate on the NSFetchRequest in the block, otherwise this method will delete all objects with this entity.
 */
+ (void)deleteWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context;

/** @name Counting */

/**
 Counts objects in a context. This is faster than fetching objects and counting the result.
 @param block Passes the NSFetchRequest for configuration.
 @param context The context in which to count objects.
 */
+ (NSUInteger)countWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context;

/** @name Fetching */

/**
 Fetches a single object.
 @param block Passes the NSFetchRequest for configuration.
 @param context The context in which to fetch the object.
 @note If you do not set a predicate and/or a sort descriptor on the NSFetchRequest, which object will be fetched is undefined.
 */
+ (instancetype)fetchSingleWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context;

/**
 Fetches a single object with the specified NSManagedObjectID.
 @param objectID The NSManagedObjectID.
 @param context The context in which to fetch the object.
 @note Useful for passing objects between contexts.
 */
+ (instancetype)fetchWithObjectID:(NSManagedObjectID *)objectID context:(NSManagedObjectContext *)context;

/**
 Fetches objects.
 @param block Passes the NSFetchRequest for configuration.
 @param context The context in which to fetch the objects.
 */
+ (NSArray *)fetchWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context;

/**
 Fetches objects where values match keyPath.
 @param keyPath The keyPath used for identification.
 @param values The identification values.
 @param block Passes the NSFetchRequest for configuration.
 @param allowNil Whether or not to allow objects not to exist. If this is NO, any objects not found for a value are created, and the value for keyPath is set.
 @param context The context in which to fetch objects.
 @note The intended use for this is mapping objects to remote database, where each object has an id.
 */
+ (NSArray *)fetchWithKeyPath:(NSString *)keyPath matchingValues:(NSArray *)values request:(OGCoreDataStackFetchRequestBlock)block allowNil:(BOOL)allowNil context:(NSManagedObjectContext *)context;

/**
 Fetches objects and populates them with data. All objects are first fetched or inserted as needed, then populated.
 @param keyPath The keyPath used for identification. This must be the same in both the entity and the populationDictionaries.
 @param populationDictionaries The dictionaries used for population. @see translatedPopulationDictionary: and populateWithDictionary:typeCheck: for more details.
 @param block Passes the NSFetchRequest for configuration.
 @param batchSize How often to run the batchBlock. This is not called during insertions, but only during the population phase. 0 or batchBlock as nil disables this.
 @param batchBlock A non-nil block here will be called every for every batchSize populations.
 @param context The context in which to fetch objects.
 @note Any objects not existing before this method is run will be inserted.
 */
+ (NSArray *)createAndPopulateWithKeyPath:(NSString *)keyPath populationDictionaries:(NSArray *)populationDictionaries request:(OGCoreDataStackFetchRequestBlock)block batchSize:(NSUInteger)batchSize batchBlock:(OGCoreDataStackBatchPopulationBlock)batchBlock context:(NSManagedObjectContext *)context;

/** @name Populating */

/**
 Called before populateWithDictionary:typeCheck: so that keys and values can be transformed as needed.
 @param dictionary The dictionary to modify.
 @return The modified dictionary.
 @note The default implementation returns the parameter, so there's no need to call super.
 */
+ (NSMutableDictionary *)translatedPopulationDictionary:(NSMutableDictionary *)dictionary;

/**
 Populates an object with values from a dictionary. Keys in the dictionary must match attributes in the entity.
 @param dictionary The dictionary containing the values.
 @param typeCheck If YES, the types in the dictionary are checked before attempting to set the attribute to be of a compatible class.
 @note Relationships are not supported and must be handled manually.
 */
- (void)populateWithDictionary:(NSMutableDictionary *)dictionary typeCheck:(BOOL)typeCheck;

/** @name Miscellaneous */

/**
 Obtains a permanent NSManagedObjectID for the object in its context.
 @return Operation success.
 */
- (BOOL)obtainPermanentID;

@end

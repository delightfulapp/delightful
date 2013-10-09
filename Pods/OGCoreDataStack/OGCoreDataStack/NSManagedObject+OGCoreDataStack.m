//
//  NSManagedObject+OGCoreDataStack.m
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

#import "NSManagedObject+OGCoreDataStack.h"
#import "OGCoreDataStackPrivate.h"
#import "OGCoreDataStack.h"

static NSArray* fetchRequest(NSManagedObjectContext* context, NSFetchRequest* request)
{
	NSError* error		= nil;
	NSArray* objects	= [context executeFetchRequest:request error:&error];
	
#ifdef DEBUG
	if (error)
		OGCoreDataStackLog(@"Fetch Error: %@", error.localizedDescription);
#endif
	
	return objects;
}

static NSUInteger countRequest(NSManagedObjectContext* context, NSFetchRequest* request)
{
	NSError* error		= nil;
	NSUInteger count	= [context countForFetchRequest:request error:&error];
	
#ifdef DEBUG
	if (error)
		OGCoreDataStackLog(@"Count Error: %@", error.localizedDescription);
#endif
	
	return count;
}

static Class classForAttributeType(NSAttributeType attributeType)
{
	switch (attributeType) {
		case NSInteger16AttributeType:
		case NSInteger32AttributeType:
		case NSInteger64AttributeType:
		case NSFloatAttributeType:
		case NSDoubleAttributeType:
		case NSBooleanAttributeType:
			return [NSNumber class];
			
		case NSDecimalAttributeType:
			return [NSDecimalNumber class];
			
		case NSStringAttributeType:
			return [NSString class];
			
		case NSDateAttributeType:
			return [NSDate class];
			
		case NSBinaryDataAttributeType:
			return [NSData class];
			
		case NSUndefinedAttributeType:
			return [NSNull class];
	}
	
	return nil;
}


@implementation NSManagedObject (OGCoreDataStack)

#pragma mark - Lifecycke

+ (NSString *)entityName
{
	return NSStringFromClass(self.class);
}

#pragma mark - Inserting

+ (instancetype)insertInContext:(NSManagedObjectContext *)context
{
	return [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:context];
}

#pragma mark - Deleting

- (void)delete
{
	[self.managedObjectContext deleteObject:self];
}

+ (void)deleteWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context
{
	NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
	
	if (block)
		block(request);
	
	request.includesPropertyValues	= NO;
	request.sortDescriptors			= nil;
	NSArray* objects				= fetchRequest(context, request);
	
	for (NSManagedObject* object in objects)
		[context deleteObject:object];
}

#pragma mark - Counting

+ (NSUInteger)countWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context
{
	NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
	
	if (block)
		block(request);
	
	request.includesPropertyValues	= NO;
	request.sortDescriptors			= nil;
	
	return countRequest(context, request);
}

#pragma mark - Fetching

+ (instancetype)fetchSingleWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context
{
	NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
	
	if (block)
		block(request);
	
	NSArray* objects = fetchRequest(context, request);
	
	return objects.count ? objects[0] : nil;
}

+ (instancetype)fetchWithObjectID:(NSManagedObjectID *)objectID context:(NSManagedObjectContext *)context
{
	NSManagedObject* object = [context objectRegisteredForID:objectID];
	
	if (object)
		return object;
	
	object = [context objectWithID:objectID];
	
	if (!object.isFault)
		return object;
	
	NSError* error	= nil;
	object			= [context existingObjectWithID:objectID error:&error];
	
#ifdef DEBUG
	if (error)
		OGCoreDataStackLog(@"Fetch Existing Object Error: %@", error.localizedDescription);
#endif
	
	return object;
}

+ (NSArray *)fetchWithRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context
{
	NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
	
	if (block)
		block(request);
	
	return fetchRequest(context, request);
}

+ (NSArray *)fetchWithKeyPath:(NSString *)keyPath matchingValues:(NSArray *)values request:(OGCoreDataStackFetchRequestBlock)block allowNil:(BOOL)allowNil context:(NSManagedObjectContext *)context
{
	if (!keyPath.length)
		return nil;
	
	if (!values.count)
		return @[];
	
	NSFetchRequest* request	= [NSFetchRequest fetchRequestWithEntityName:self.entityName];
	
	if (block)
		block(request);
	
	request.predicate		= [NSPredicate predicateWithFormat:@"%K IN %@", keyPath, values];
	request.sortDescriptors	= nil;
	NSArray* objects		= fetchRequest(context, request);
	
	if (allowNil || objects.count >= values.count)
		return objects;
	
	NSMutableArray* missingValues	= [NSMutableArray arrayWithArray:values];
	NSMutableArray* missingObjects	= [NSMutableArray array];
	
	for (NSManagedObject* object in objects)
		[missingValues removeObject:[object valueForKey:keyPath]];
	
	for (id value in missingValues) {
		
		NSManagedObject* object = [self insertInContext:context];
		
		[object setValue:value forKey:keyPath];
		[missingObjects addObject:object];
	}
	
	objects = [objects arrayByAddingObjectsFromArray:missingObjects];
	
	if (request.sortDescriptors.count)
		objects = [objects sortedArrayUsingDescriptors:request.sortDescriptors];
	
	return objects;
}

+ (NSArray *)createAndPopulateWithKeyPath:(NSString *)keyPath populationDictionaries:(NSArray *)populationDictionaries request:(OGCoreDataStackFetchRequestBlock)block batchSize:(NSUInteger)batchSize batchBlock:(OGCoreDataStackBatchPopulationBlock)batchBlock context:(NSManagedObjectContext *)context
{
	NSMutableArray* dictionaries	= [NSMutableArray arrayWithArray:populationDictionaries];
	NSMutableArray* values			= [NSMutableArray arrayWithCapacity:populationDictionaries.count];
	BOOL shouldBreak				= batchSize > 0 && batchBlock != nil;
	
	for (NSDictionary* dictionary in populationDictionaries)
		[values addObject:dictionary[keyPath]];
	
	NSUInteger counter	= 0;
	NSArray* objects	= [self fetchWithKeyPath:keyPath matchingValues:values request:block allowNil:NO context:context];
	
	for (NSManagedObject* object in objects) {
		
		NSMutableDictionary* dictionary	= nil;
		id idValue						= [object valueForKey:keyPath];
		
		for (NSDictionary* dict in dictionaries)
			if ([dict[keyPath] isEqual:idValue]) {
				
				dictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
				break;
			}
		
		if (dictionary) {
			
			[dictionaries removeObject:dictionary];
			[object populateWithDictionary:dictionary typeCheck:YES];
		}
		
		if (shouldBreak) {
			
			counter++;
			
			if (counter % batchSize == 0)
				batchBlock();
		}
	}
	
	return objects;
}

#pragma mark - Populating

+ (NSMutableDictionary *)translatedPopulationDictionary:(NSMutableDictionary *)dictionary
{
	return dictionary;
}

- (void)populateWithDictionary:(NSMutableDictionary *)dictionary typeCheck:(BOOL)typeCheck
{
	NSDictionary* attributes			= self.entity.attributesByName;
	NSMutableArray* attributeKeys		= [NSMutableArray arrayWithArray:attributes.allKeys];
	dictionary							= [self.class translatedPopulationDictionary:dictionary];
#ifdef DEBUG
	NSArray* relationshipKeys			= self.entity.relationshipsByName.allKeys;
	NSMutableArray* missingKeys			= [NSMutableArray array];
	NSMutableArray* relationships		= [NSMutableArray array];
#endif
	
	[dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		
		if ([attributeKeys containsObject:key]) {
			
			NSAttributeDescription* attribute = attributes[key];
			
			if (!typeCheck || [obj isKindOfClass:classForAttributeType(attribute.attributeType)])
				[self setValue:obj forKey:key];
			
			[attributeKeys removeObject:key];
		}
#ifdef DEBUG
		else if ([relationshipKeys containsObject:key])
			[relationships addObject:key];
		else
			[missingKeys addObject:key];
#endif
	}];
	
#ifdef DEBUG
	NSMutableString* str = [NSMutableString stringWithFormat:@"Populating %@", NSStringFromClass(self.class)];
	
	if (relationships.count)
		[str appendFormat:@"\nRelationship keys found but not populated: %@", [relationships componentsJoinedByString:@" "]];
	
	if (missingKeys.count)
		[str appendFormat:@"\nUnused keys: %@", [missingKeys componentsJoinedByString:@" "]];
	
	OGCoreDataStackLog(@"%@", str);
#endif
}

#pragma mark - Miscellaneous

- (BOOL)obtainPermanentID
{
	return [self.managedObjectContext obtainPermanentIDsForObjects:@[self]];
}

@end

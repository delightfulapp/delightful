//
//  NSManagedObject+OGCoreDataStackAsynchronous.m
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

#import "NSManagedObject+OGCoreDataStackAsynchronous.h"
#import "OGCoreDataStackPrivate.h"
#import "OGCoreDataStack.h"

@implementation NSManagedObject (OGCoreDataStackAsynchronous)

#pragma mark - Deleting

+ (void)asynchronouslyDeleteWithRequest:(OGCoreDataStackFetchRequestBlock)block completion:(OGCoreDataStackDeleteCompletionBlock)completion
{
	NSManagedObjectContext* context = [NSManagedObjectContext workContext];
	
	[context performBlock:^{
		
		[self deleteWithRequest:block context:context];
//		[context save];
		
		if (completion)
			dispatch_async(dispatch_get_main_queue(), ^{ completion(); });
	}];
}

#pragma mark - Counting

+ (void)asynchronouslyCountWithRequest:(OGCoreDataStackFetchRequestBlock)block completion:(OGCoreDataStackCountCompletionBlock)completion
{
	NSManagedObjectContext* context = [NSManagedObjectContext workContext];
	
	[context performBlock:^{
		
		NSUInteger count = [self countWithRequest:block context:context];
		
		if (completion)
			dispatch_async(dispatch_get_main_queue(), ^{ completion(count); });
	}];
}

#pragma mark - Fetching

+ (void)asynchronouslyFetchWithRequest:(OGCoreDataStackFetchRequestBlock)block completion:(OGCoreDataStackFetchCompletionBlock)completion
{
	NSManagedObjectContext* context = [NSManagedObjectContext workContext];
	
	[context performBlock:^{
		
		NSArray* objects = [self fetchWithRequest:^(NSFetchRequest *request) {
			
			if (block)
				block(request);
			
			request.resultType		= NSManagedObjectIDResultType;
			request.sortDescriptors	= nil;
			
		} context:context];
		
		if (completion)
			dispatch_async(dispatch_get_main_queue(), ^{
				
				if (!objects.count)
					completion(@[]);
				else
					completion([self fetchWithRequest:^(NSFetchRequest *request) {
						
						if (block)
							block(request);
						
						request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", objects];
						
					} context:[NSManagedObjectContext mainContext]]);
			});
	}];
}

+ (void)asynchronouslyFetchWithKeyPath:(NSString *)keyPath matchingValues:(NSArray *)values request:(OGCoreDataStackFetchRequestBlock)block allowNil:(BOOL)allowNil completion:(OGCoreDataStackFetchCompletionBlock)completion
{
	NSManagedObjectContext* context = [NSManagedObjectContext workContext];
	
	[context performBlock:^{
		
		NSArray* objects = [self fetchWithKeyPath:keyPath matchingValues:values request:^(NSFetchRequest *request) {
			
			if (block)
				block(request);
			
			request.resultType		= NSManagedObjectIDResultType;
			request.sortDescriptors	= nil;
			
		} allowNil:allowNil context:context];
		
		if (completion)
			dispatch_async(dispatch_get_main_queue(), ^{
				
				if (!objects.count)
					completion(@[]);
				else
					completion([self fetchWithRequest:^(NSFetchRequest *request) {
						
						if (block)
							block(request);
						
						request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", objects];
						
					} context:[NSManagedObjectContext mainContext]]);
			});
	}];
}

@end

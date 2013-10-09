//
//  OGCoreDataStackVendor.h
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

@interface OGCoreDataStackVendor : NSObject
<NSFetchedResultsControllerDelegate>

@property (assign, nonatomic, getter=isVending)	BOOL								vending;
@property (strong, nonatomic, readonly)			NSFetchRequest*						fetchRequest;
@property (strong, nonatomic, readonly)			NSManagedObjectContext*				managedObjectContext;
@property (strong, nonatomic, readonly)			NSString*							sectionNameKeyPath;
@property (strong, nonatomic, readonly)			NSString*							cacheName;
@property (copy, nonatomic)						OGCoreDataStackVendorObjectsUpdated	objectsUpdated;

- (void)fetchEntity:(Class)entity withRequest:(OGCoreDataStackFetchRequestBlock)block context:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)cacheName;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfObjectsInSection:(NSInteger)section;
- (NSInteger)totalNumberOfObjects;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;

- (id)firstObject;
- (id)lastObject;
- (id)firstObjectInSection:(NSInteger)section;
- (id)lastObjectInSection:(NSInteger)section;

- (NSArray *)objectsInSection:(NSInteger)section;
- (NSArray *)allObjects;

@end

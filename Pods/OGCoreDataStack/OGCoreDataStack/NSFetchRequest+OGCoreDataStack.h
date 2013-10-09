//
//  NSFetchRequest+OGCoreDataStack.h
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

@interface NSFetchRequest (OGCoreDataStack)

/** @name Configuration */

/**
 A shorthand for setPredicate:[NSString stringWithFormat:format, ...]
 @param format The format string
 @param ... The parameters
 */
- (void)setPredicateWithFormat:(NSString *)format, ...;

/**
 A shorthand for adding NSSortDescriptors. The first added sort descriptor is the primary sort.
 @param sortDescriptor The NSSortDescriptor to add.
 @note Can be combined with addSortKey:ascending: but not with setSortDescriptors:
 */
- (void)addSortDescriptor:(NSSortDescriptor *)sortDescriptor;

/**
 A shorthand for adding NSSortDescriptors. The first added sort descriptor is the primary sort.
 @param key The keyPath to sort on.
 @param ascending Whether or not the sort is ascending or descending.
 @note Can be combined with addSortDescriptor: but not with setSortDescriptors:
 */
- (void)addSortKey:(NSString *)key ascending:(BOOL)ascending;

@end

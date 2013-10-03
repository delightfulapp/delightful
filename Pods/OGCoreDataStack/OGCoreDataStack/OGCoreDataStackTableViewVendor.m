//
//  OGCoreDataStackTableViewVendor.m
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

@implementation OGCoreDataStackTableViewVendor

#pragma mark - Lifecycle

- (id)init
{
	if (self = [super init]) {
		
		_insertionAnimation	= UITableViewRowAnimationAutomatic;
		_deletionAnimation	= UITableViewRowAnimationAutomatic;
		_updateAnimation	= UITableViewRowAnimationAutomatic;
		_reloadThreshold	= 50;
	}
	
	return self;
}

#pragma mark - Properties

- (void)setTableView:(UITableView *)tableView
{
	_tableView										= tableView;
	__weak OGCoreDataStackTableViewVendor* wSelf	= self;
	
	if (tableView)
		self.objectsUpdated = ^(NSIndexSet* insertedSections, NSIndexSet* deletedSections, NSArray* insertedItems, NSArray* deletedItems, NSArray* updatedItems) {
			
			NSUInteger count = insertedSections.count + deletedSections.count + insertedItems.count + deletedItems.count + updatedItems.count;
			
			if (count > wSelf.reloadThreshold)
				[tableView reloadData];
			else {
				
				[tableView beginUpdates];
				[tableView deleteSections:deletedSections withRowAnimation:wSelf.deletionAnimation];
				[tableView insertSections:insertedSections withRowAnimation:wSelf.insertionAnimation];
				[tableView deleteRowsAtIndexPaths:deletedItems withRowAnimation:wSelf.deletionAnimation];
				[tableView insertRowsAtIndexPaths:insertedItems withRowAnimation:wSelf.insertionAnimation];
				[tableView reloadRowsAtIndexPaths:updatedItems withRowAnimation:wSelf.updateAnimation];
				[tableView endUpdates];
			}
		};
	else
		self.objectsUpdated = nil;
}

@end

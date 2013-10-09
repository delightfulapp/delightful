//
//  OGCoreDataStackPrivate.m
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

#import "OGCoreDataStackPrivate.h"
#import "OGCoreDataStack.h"

NSURL* _ogMomdURL()
{
	NSArray* urls = [[NSBundle bundleWithIdentifier:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey]] URLsForResourcesWithExtension:@"momd" subdirectory:nil];
	
	if (urls.count == 1)
		return urls[0];
	
	OGCoreDataStackLog(@"Create Managed Object Model Error: Looking for 1 Momd in main bundle, found %lu", (unsigned long)urls.count);
	return nil;
}

NSURL* _ogSQLiteURL()
{
	NSString* filename	= _ogMomdURL().lastPathComponent;
	NSString* modelname	= [filename substringWithRange:NSMakeRange(0, filename.length-5)];
	NSArray* urls		= [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
	
	return [urls.lastObject URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", modelname]];
}

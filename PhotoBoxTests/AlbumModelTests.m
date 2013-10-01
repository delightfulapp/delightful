//
//  AlbumModelTests.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Album.h"
#import "PhotoBoxModel.h"
#import "Photo.h"
#import "Tag.h"

@interface AlbumModelTests : XCTestCase

@end

@implementation AlbumModelTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSerializeAlbum
{
    NSError *error;
    
    NSString * filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"album" ofType:@"json"];
    NSDictionary *albumDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:0 error:&error];
    Album *testAlbum = [MTLJSONAdapter modelOfClass:[Album class] fromJSONDictionary:albumDict error:&error];
    
    XCTAssert(testAlbum!=nil, @"Test album should not be nil");
    XCTAssert([testAlbum.albumId isEqualToString:@"4"], @"Expected test album id = f. Actual = %@", testAlbum.albumId);
    XCTAssert([testAlbum.count intValue]==13, @"Expected album count = 13. Actual = %d", [testAlbum.count intValue]);
    XCTAssert([testAlbum.name isEqualToString:[albumDict objectForKey:@"name"]], @"Expected album name = %@. Actual = %@", [albumDict objectForKey:@"name"], testAlbum.name);
    
    // test cover's original image
    XCTAssert(testAlbum.cover!=nil, @"Album cover should not be nil");
    XCTAssert(testAlbum.cover.originalImage!=nil, @"Original image should not be nil");
    XCTAssert([testAlbum.cover.originalImage.urlString isEqualToString:[[albumDict objectForKey:@"cover"] objectForKey:@"pathOriginal"]], @"Expected original image = %@. Actual = %@", [[albumDict objectForKey:@"cover"] objectForKey:@"pathOriginal"], testAlbum.cover.originalImage.urlString);
    
    // test cover's thumbnail image
    XCTAssert(testAlbum.cover.thumbnailImage!=nil, @"Thumbnail image should not be nil");
    XCTAssert([testAlbum.cover.thumbnailImage.urlString isEqualToString:[[[albumDict objectForKey:@"cover"] objectForKey:@"photo200x200xCR"] objectAtIndex:0]], @"Expected thumbnail image = %@. Actual = %@", [[[albumDict objectForKey:@"cover"] objectForKey:@"photo200x200xCR"] objectAtIndex:0], testAlbum.cover.thumbnailImage.urlString);
    
    // test cover's tag
    XCTAssert(testAlbum.cover.tags!=nil, @"Tags should not be nil");
    XCTAssert(testAlbum.cover.tags.count == 4, @"Tags count should be 4. Actual = %d", testAlbum.cover.tags.count);
    XCTAssert([((Tag *)testAlbum.cover.tags[0]).tagId isEqualToString:[[[albumDict objectForKey:@"cover"] objectForKey:@"tags"] objectAtIndex:0]], @"Expected first tag = %@. Actual = %@", [[[albumDict objectForKey:@"cover"] objectForKey:@"tags"] objectAtIndex:0], ((Tag *)testAlbum.cover.tags[0]).tagId);
}

@end

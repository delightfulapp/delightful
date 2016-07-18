//
//  CollectionViewSelectCellGestureRecognizerTests.m
//  Delightful
//
//  Created by Nico Prananta on 11/2/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Expecta/Expecta.h>

#import "CollectionViewSelectCellGestureRecognizer.h"

@interface CollectionViewSelectCellGestureRecognizerTests : XCTestCase

@end

@implementation CollectionViewSelectCellGestureRecognizerTests

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

- (void)testIsSelecting
{
    CollectionViewSelectCellGestureRecognizer *gesture = [[CollectionViewSelectCellGestureRecognizer alloc] initWithCollectionView:nil];
    id mockGesture = [OCMockObject partialMockForObject:gesture];
    
    NSArray *selectedIndexPaths = @[[NSIndexPath indexPathForItem:0 inSection:0]];
    [[[mockGesture expect] andReturn:selectedIndexPaths] selectedIndexPaths];
    
    expect([mockGesture isSelecting]).to.beTruthy;
    
    [mockGesture verify];
}

- (void)testCancelSelection {
    CollectionViewSelectCellGestureRecognizer *gesture = [[CollectionViewSelectCellGestureRecognizer alloc] initWithCollectionView:nil];
    [gesture.selectedIndexPaths addObject:[NSIndexPath indexPathForItem:0 inSection:0]];
    [gesture cancelSelection];
    
    expect([gesture isSelecting]).to.beFalsy;
}

@end

//
//  PhotosSubsetViewController.m
//  Delightful
//
//  Created by  on 10/22/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "PhotosSubsetViewController.h"

#import "PhotosSubsetDataSource.h"

@interface PhotosSubsetViewController ()

@end

@implementation PhotosSubsetViewController

- (id)initWithFilterBlock:(BOOL (^)(NSString *, NSString *, id))filterBlock name:(NSString *)filterName{
    self = [super init];
    if (self) {
        self.filterName = filterName;
        self.filterBlock = filterBlock;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [((PhotosSubsetDataSource *)self.dataSource) setFilterBlock:self.filterBlock name:self.filterName];
    [((YapDataSource *)self.dataSource) setPause:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"view will disappear");
    [((YapDataSource *)self.dataSource) setPause:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Class)dataSourceClass {
    return [PhotosSubsetDataSource class];
}


@end

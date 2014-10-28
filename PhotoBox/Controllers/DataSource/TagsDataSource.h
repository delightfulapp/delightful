//
//  TagsDataSource.h
//  Delightful
//
//  Created by  on 10/14/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "YapDataSource.h"

extern NSString *tagsAlphabeticalFirstViewName;
extern NSString *tagsAlphabeticalLastViewName;
extern NSString *numbersFirstViewName;
extern NSString *numbersLastViewName;

@class DLFYapDatabaseViewAndMapping;

typedef NS_ENUM(NSInteger, TagsSortKey) {
    TagsSortKeyName,
    TagsSortKeyNumberOfPhotos
};

@interface TagsDataSource : YapDataSource

- (void)sortBy:(TagsSortKey)sortBy ascending:(BOOL)ascending;

@end

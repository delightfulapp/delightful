//
//  PhotoBoxModel.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoBoxModel : NSObject

@property (nonatomic, strong) NSDictionary *rawDictionary;

@property (nonatomic, assign) int totalRows;
@property (nonatomic, assign) int totalPages;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) int currentRow;
@property (nonatomic, strong) NSString *itemId;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

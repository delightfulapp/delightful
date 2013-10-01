//
//  PhotoBoxModel.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MTLModel.h>

@interface PhotoBoxModel : MTLModel <MTLJSONSerializing, MTLManagedObjectSerializing>

@property (nonatomic, strong) NSDictionary *rawDictionary;

@property (nonatomic, assign) int totalRows;
@property (nonatomic, assign) int totalPages;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) int currentRow;
@property (nonatomic, copy) NSString *itemId;

- (id)initWithItemId:(NSString *)itemId;

@end

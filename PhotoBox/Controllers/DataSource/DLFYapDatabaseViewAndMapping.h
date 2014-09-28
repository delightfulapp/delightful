//
//  YapDatabaseViewAndMapping.h
//  Delightful
//
//  Created by  on 9/29/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <YapDatabaseView.h>
#import <YapDatabase.h>

@interface DLFYapDatabaseViewAndMapping : NSObject

@property (nonatomic, strong) YapDatabaseViewMappings *mapping;
@property (nonatomic, strong) YapDatabaseView *view;

+ (DLFYapDatabaseViewAndMapping *)databaseViewAndMappingForKeyToCompare:(NSString *)keyToCompare database:(YapDatabase *)database viewName:(NSString *)viewName asc:(BOOL)ascending grouped:(BOOL)grouped;

@end

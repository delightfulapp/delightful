//
//  DLFDatabase.m
//  Delightful
//
//  Created by  on 9/23/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "DLFDatabaseManager.h"

#import <YapDatabase.h>

NSString *photosCollectionName = @"photos";
NSString *albumsCollectionName = @"albums";
NSString *tagsCollectionName = @"tags";

@interface DLFDatabaseManager ()

@property (nonatomic, strong) YapDatabase *database;
@property (nonatomic, strong) YapDatabaseConnection *connection;

@end

@implementation DLFDatabaseManager

+ (instancetype)manager {
    static DLFDatabaseManager *_currentDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _currentDatabase = [[DLFDatabaseManager alloc] init];
    });
    
    return _currentDatabase;
}

- (YapDatabase *)currentDatabase {
    if (!_database) {
        _database = [[YapDatabase alloc] initWithPath:[self databasePath]];
    }
    return _database;
}

- (YapDatabaseConnection *)connection {
    if (!_connection) {
        _connection = [self.database newConnection];
    }
    return _connection;
}

- (NSString *)databasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    
    NSString *databaseName = @"database.sqlite";
    
    return [baseDir stringByAppendingPathComponent:databaseName];
}

- (void)removeAllItems {
    NSLog(@"Removing all items");
    [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeAllObjectsInAllCollections];
    }];
}

@end

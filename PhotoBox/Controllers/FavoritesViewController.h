//
//  FavoritesViewController.h
//  Delightful
//
//  Created by  on 11/16/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "YapBackedPhotosViewController.h"

typedef NS_ENUM(NSInteger, MigratingState) {
    MigratingStateDone,
    MigratingStateRunning
};

@interface FavoritesViewController : YapBackedPhotosViewController

- (NSString *)noPhotosMessage;

@property (nonatomic, assign) MigratingState migratingState;

@end

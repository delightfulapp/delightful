//
//  SortTableViewController.h
//  Delightful
//
//  Created by  on 10/19/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const dateUploadedDescSortKey;
extern NSString *const dateUploadedAscSortKey;
extern NSString *const dateTakenDescSortKey;
extern NSString *const dateTakenAscSortKey;
extern NSString *const nameDescSortKey;
extern NSString *const nameAscSortKey;
extern NSString *const countDescSortKey;
extern NSString *const countAscSortKey;
extern NSString *const dateLastPhotoAddedDescSortKey;
extern NSString *const dateLastPhotoAddedAscSortKey;


@protocol SortingDelegate <NSObject>

@optional
- (void)sortTableViewController:(id)sortTableViewController didSelectSort:(NSString *)sort;

@end

@interface SortTableViewController : UITableViewController

@property (nonatomic, weak) id<SortingDelegate>sortingDelegate;

@property (nonatomic) Class resourceClass;

@property (nonatomic, strong) NSString *selectedSort;

@end

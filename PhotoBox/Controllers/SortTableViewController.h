//
//  SortTableViewController.h
//  Delightful
//
//  Created by  on 10/19/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SortingDelegate <NSObject>

@optional
- (void)sortTableViewController:(id)sortTableViewController didSelectSort:(NSString *)sort;

@end

@interface SortTableViewController : UITableViewController

@property (nonatomic, weak) id<SortingDelegate>sortingDelegate;

@property (nonatomic) Class resourceClass;

@property (nonatomic, strong) NSString *selectedSort;

@end

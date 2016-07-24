//
//  TagsSuggestionTableViewController.h
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TagsSuggestionTableViewController;

@protocol TagsSuggestionTableViewControllerPickerDelegate <NSObject>

@optional
- (void)tagsSuggestionViewController:(TagsSuggestionTableViewController *)tagsViewController didSelectTag:(NSString *)tag;

@end

@interface TagsSuggestionTableViewController : UITableViewController

@property (nonatomic, copy) NSArray *suggestions;

@property (nonatomic, weak) id<TagsSuggestionTableViewControllerPickerDelegate>pickerDelegate;

@end

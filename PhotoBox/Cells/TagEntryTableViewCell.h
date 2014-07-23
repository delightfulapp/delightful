//
//  TagEntryTableViewCell.h
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagEntryTableViewCell : UITableViewCell

@property (nonatomic, strong, readonly) UITextField *tagField;
@property (nonatomic, strong, readonly) UIButton *tagPickerButton;

+ (NSString *)defaultCellReuseIdentifier;

@end

//
//  TagEntryTableViewCell.h
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "TagsAlbumPermissionPickerTableViewCell.h"

@interface TagEntryTableViewCell : TagsAlbumPermissionPickerTableViewCell

@property (nonatomic, strong, readonly) UITextField *tagField;
@property (nonatomic, strong, readonly) UIButton *tagPickerButton;

@end

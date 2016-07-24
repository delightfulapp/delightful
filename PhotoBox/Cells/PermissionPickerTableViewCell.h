//
//  PermissionPickerTableViewCell.h
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "TagsAlbumPermissionPickerTableViewCell.h"

@interface PermissionPickerTableViewCell : TagsAlbumPermissionPickerTableViewCell

@property (nonatomic, strong, readonly) UISwitch *permissionSwitch;
@property (nonatomic, strong, readonly) UILabel *permissionLabel;

@end

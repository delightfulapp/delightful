//
//  UploadDescriptionTableViewCell.h
//  Delightful
//
//  Created by  on 1/5/15.
//  Copyright (c) 2015 Touches. All rights reserved.
//

#import "TagsAlbumPermissionPickerTableViewCell.h"

@interface DescriptionTextView : UITextView

@property (nonatomic, weak) UILabel *placeholderLabel;

@end

@interface UploadDescriptionTableViewCell : TagsAlbumPermissionPickerTableViewCell

@property (nonatomic, strong, readonly) DescriptionTextView *textView;

@end

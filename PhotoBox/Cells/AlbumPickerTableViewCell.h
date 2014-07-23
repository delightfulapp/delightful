//
//  AlbumPickerTableViewCell.h
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumPickerTableViewCell : UITableViewCell

@property (nonatomic, strong, readonly) UILabel *albumLabel;

@property (nonatomic, strong, readonly) UILabel *selectedAlbumLabel;

+ (NSString *)defaultCellReuseIdentifier;

@end

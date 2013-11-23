//
//  PhotoCell.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoCell.h"

#import "Photo.h"

#import "NSString+Additionals.h"

#import "UICollectionViewCell+Additionals.h"

#import <UIView+AutoLayout.h>

@interface PhotoCell ()

@property (nonatomic, strong) UIView *selectedView;

@end

@implementation PhotoCell

@synthesize item = _item;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setText:nil];
}

- (void)setup {
    [super setup];
    
    [self.photoTitle autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView withOffset:-10];
    [self.photoTitle autoCenterInSuperviewAlongAxis:ALAxisVertical];
    [self.photoTitle autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withOffset:-20];
    [self.photoTitleBackgroundView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView];
    [self.photoTitleBackgroundView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.photoTitle withOffset:20];
    [self.photoTitleBackgroundView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.photoTitle];
    [self.photoTitleBackgroundView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.photoTitle];

    [self.photoTitle setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]];
    [self.photoTitle setBackgroundColor:[UIColor clearColor]];
    [self.photoTitle setNumberOfLines:2];
    [self.contentView insertSubview:self.photoTitle aboveSubview:self.photoTitleBackgroundView];
    [self.photoTitleBackgroundView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
}

- (void)setItem:(id)item {
    if (_item != item) {
        _item = item;
        
        Photo *photo = (Photo *)item;
        [self.cellImageView setImageWithURL:[NSURL URLWithString:photo.thumbnailImage.urlString] placeholderImage:nil];
        [self setText:[self photoCellTitle]];
    }
}

- (void)setNumberOfColumns:(NSInteger)numberOfColumns {
    if (_numberOfColumns != numberOfColumns) {
        _numberOfColumns = numberOfColumns;
        if (self.item) {
            [self setText:[self photoCellTitle]];
        }
    }
}

- (void)setSelected:(BOOL)selected {
    if (self.isSelected!=selected) {
        [super setSelected:selected];
        [self showSelectedView:selected];
    }
}

- (void)setText:(id)text {
    [self.photoTitleBackgroundView setHidden:(text)?NO:YES];
    [self.photoTitle setAttributedText:text];
}

- (void)showSelectedView:(BOOL)selected {
    if (selected) {
        if (!self.selectedView) {
            self.selectedView = [[UIView alloc] initWithFrame:self.bounds];
            [self.selectedView setBackgroundColor:[UIColor whiteColor]];
            [self.selectedView setAlpha:0.5];
            [self.contentView addSubview:self.selectedView];
        }
    } else {
        if (self.selectedView) {
            [self.selectedView removeFromSuperview];
            self.selectedView = nil;
        }
    }
}

#pragma mark - Getters

- (id)photoCellTitle {
    if (self.item) {
        if (_numberOfColumns < 3) {
            Photo *photo = (Photo *)self.item;
            NSString *title = photo.filenameOriginal;
            NSString *subtitle = nil;
            if (_numberOfColumns == 1) {
                subtitle = [photo.dateTakenString localizedDate];
            }
            return [self attributedPhotoCellTitleForTitle:title subtitle:subtitle];
            
        }
    }
    return nil;
}

- (NSAttributedString *)attributedPhotoCellTitleForTitle:(NSString *)title subtitle:(NSString *)subtitle {
    NSString *combined = title;
    if (subtitle) {
        combined = [combined stringByAppendingFormat:@"\n%@", subtitle];
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:combined];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:[combined rangeOfString:title]];
    if (subtitle) {
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:[combined rangeOfString:subtitle]];
    }
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, combined.length)];
    
    return attributedString;
}

- (UILabel *)photoTitle {
    if (!_photoTitle) {
        _photoTitle = [self addSubviewToContentViewWithClass:[UILabel class]];
    }
    return _photoTitle;
}

- (UIView *)photoTitleBackgroundView {
    if (!_photoTitleBackgroundView) {
        _photoTitleBackgroundView = [self addSubviewToContentViewWithClass:[UIView class]];
        
    }
    return _photoTitleBackgroundView;
}

@end

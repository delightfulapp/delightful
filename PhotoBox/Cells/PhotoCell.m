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
    
    [self.photoTitleBackgroundView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView];
    [self.photoTitleBackgroundView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.photoTitle withOffset:-10];
    [self.photoTitleBackgroundView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView];
    [self.photoTitleBackgroundView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.contentView];
    
    [self.dateTitle autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.contentView withOffset:-10];
    [self.dateTitle autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.dateTitle autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withOffset:-20];
    
    [self.photoTitle autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.dateTitle withOffset:-5];
    [self.photoTitle autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.photoTitle autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withOffset:-20];

    [self.photoTitle setBackgroundColor:[UIColor clearColor]];
    [self.photoTitle setNumberOfLines:1];
    [self.photoTitle setFont:[UIFont boldSystemFontOfSize:14]];
    [self.photoTitle setTextColor:[UIColor whiteColor]];
    [self.photoTitle setLineBreakMode:NSLineBreakByTruncatingMiddle];
    
    [self.dateTitle setBackgroundColor:[UIColor clearColor]];
    [self.dateTitle setNumberOfLines:1];
    [self.dateTitle setFont:[UIFont systemFontOfSize:10]];
    [self.dateTitle setTextColor:[UIColor whiteColor]];
    
    [self.contentView insertSubview:self.photoTitle aboveSubview:self.photoTitleBackgroundView];
    [self.photoTitleBackgroundView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
}

- (void)setItem:(id)item {
    if (_item != item) {
        _item = item;
        
        Photo *photo = (Photo *)item;
        NSURL *URL = [NSURL URLWithString:photo.thumbnailImage.urlString];
        if (!URL) {
            URL = photo.pathOriginal;
        }
        [self.cellImageView setImageWithURL:URL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                [photo setPlaceholderImage:image];
            }
        }];
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
    [self.photoTitle setText:text];
    if (text) {
        [self.dateTitle setText:[self dateString]];
    } else [self.dateTitle setText:nil];
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
            return  photo.filenameOriginal;
        }
    }
    return nil;
}

- (id)dateString {
    if (_numberOfColumns < 3) {
        Photo *photo = (Photo *)self.item;
        return  [photo.dateTakenString localizedDate];
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

- (UILabel *)dateTitle {
    if (!_dateTitle) {
        _dateTitle = [self addSubviewToContentViewWithClass:[UILabel class]];
    }
    return _dateTitle;
}

- (UIView *)photoTitleBackgroundView {
    if (!_photoTitleBackgroundView) {
        _photoTitleBackgroundView = [self addSubviewToContentViewWithClass:[UIView class]];
        
    }
    return _photoTitleBackgroundView;
}

@end

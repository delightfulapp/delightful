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

#import "PureLayout.h"

@interface PhotoCell ()

@end

@implementation PhotoCell

@synthesize item = _item;


- (void)setup {
    [super setup];
    
    [self.photoTitle setHidden:YES];
    [self.photoTitleBackgroundView setHidden:YES];
    [self.dateTitle setHidden:YES];
    
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
        [self.cellImageView sd_setImageWithURL:URL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                [photo setPlaceholderImage:image];
            }
        }];
        
        if (self.showTitles) {
            [self setText:[self photoCellTitle]];
        }
    }
}

- (void)setShowTitles:(BOOL)showTitles {
    if (_showTitles != showTitles) {
        _showTitles = showTitles;
        
        if (_showTitles) {
            [self.photoTitleBackgroundView setHidden:NO];
            [self.photoTitle setHidden:NO];
            [self.dateTitle setHidden:NO];
            [self setText:[self photoCellTitle]];
        } else {
            [self.photoTitleBackgroundView setHidden:YES];
            [self.photoTitle setHidden:YES];
            [self.dateTitle setHidden:YES];
        }
    }
}

- (void)setText:(id)text {
    [self.photoTitle setText:text];
    if (text) {
        [self.dateTitle setText:[self dateString]];
    } else [self.dateTitle setText:nil];
}

#pragma mark - Getters

- (id)photoCellTitle {
    if (self.item) {
        Photo *photo = (Photo *)self.item;
        return  photo.filenameOriginal;
    }
    return nil;
}

- (id)dateString {
    if (self.item) {
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

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

@interface PhotoCell ()

@property (nonatomic, strong) UIView *selectedView;

@end

@implementation PhotoCell

@synthesize item = _item;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setText:nil];
}

- (void)setItem:(id)item {
    if (_item != item) {
        _item = item;
        
        Photo *photo = (Photo *)item;
        [self.cellImageView setImageWithURL:[NSURL URLWithString:photo.thumbnailImage.urlString] placeholderImage:nil];
    }
}

- (void)setNumberOfColumns:(NSInteger)numberOfColumns {
    if (_numberOfColumns != numberOfColumns) {
        NSLog(@"Setting number of columns");
        _numberOfColumns = numberOfColumns;
        if (self.item) {
            [self setText:[self photoCellTitle]];
        }
    }
}

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

- (void)setSelected:(BOOL)selected {
    if (self.isSelected!=selected) {
        [super setSelected:selected];
        [self showSelectedView:selected];
    }
}

- (void)setText:(id)text {
    [self.albumTitleBackgroundView setHidden:(text)?NO:YES];
    [self.albumTitle setAttributedText:text];
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

@end

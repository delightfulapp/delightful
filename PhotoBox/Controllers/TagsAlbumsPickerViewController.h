//
//  TagsAlbumsPickerViewController.h
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TagsAlbumsPickerCollectionViewSections) {
    TagsAlbumsPickerCollectionViewSectionsTitle,
    TagsAlbumsPickerCollectionViewSectionsTags,
    TagsAlbumsPickerCollectionViewSectionsAlbums,
    TagsAlbumsPickerCollectionViewSectionsPermission,
    TagsAlbumsPickerCollectionViewSectionsResizeAfterUpload,
    TagsAlbumsPickerCollectionViewSectionsCount
};

typedef NS_ENUM(NSInteger, TagsSectionRows) {
    TagsSectionRowsEntryField,
    TagsSectionRowsSmartTags,
    TagsSectionRowsCount
};

typedef NS_ENUM(NSInteger, TitleSectionRows) {
    TitleSectionRowsTitle,
    TitleSectionRowsDescription,
    TitleSectionRowsCount
};

@class TagsAlbumsPickerViewController;
@class Album;

@protocol TagsAlbumsPickerViewControllerDelegate <NSObject>

@optional
- (void)tagsAlbumsPickerViewController:(TagsAlbumsPickerViewController *)tagsAlbumsPickerViewController didFinishSelectTagsAndAlbum:(NSArray *)assets;

@end

@interface TagsAlbumsPickerViewController : UITableViewController

@property (nonatomic, weak) id<TagsAlbumsPickerViewControllerDelegate>delegate;

@property (nonatomic, copy) NSArray *selectedAssets;

@end

//
//  TagsAlbumsPickerViewController.h
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TagsAlbumsPickerCollectionViewSections) {
    TagsAlbumsPickerCollectionViewSectionsTags,
    TagsAlbumsPickerCollectionViewSectionsAlbums,
    TagsAlbumsPickerCollectionViewSectionsPermission,
    TagsAlbumsPickerCollectionViewSectionsCount
};

@class TagsAlbumsPickerViewController;
@class Album;

@protocol TagsAlbumsPickerViewControllerDelegate <NSObject>

@optional
- (void)tagsAlbumsPickerViewController:(TagsAlbumsPickerViewController *)tagsAlbumsPickerViewController didFinishWithTags:(NSString *)tags album:(Album *)album private:(BOOL)privatePhotos;

@end

@interface TagsAlbumsPickerViewController : UITableViewController

@property (nonatomic, weak) id<TagsAlbumsPickerViewControllerDelegate>delegate;

@end

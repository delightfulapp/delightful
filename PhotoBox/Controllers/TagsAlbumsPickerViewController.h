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

@interface TagsAlbumsPickerViewController : UITableViewController

@end

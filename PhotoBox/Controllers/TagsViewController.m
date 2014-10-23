//
//  TagsViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "TagsViewController.h"

#import "Tag.h"

#import "TagRowCell.h"

#import "PhotosViewController.h"

#import "AppDelegate.h"

#import "UIViewController+Additionals.h"

#import "NSAttributedString+DelighftulFonts.h"

#import "TagsDataSource.h"

#import "SyncEngine.h"

#import "SortTableViewController.h"

#import "PhotosSubsetViewController.h"

#import "PHoto.h"

@interface TagsViewController () <UICollectionViewDelegate, SortingDelegate>

@property (nonatomic, strong) NSString *currentSort;

@end

@implementation TagsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.collectionView registerClass:[TagRowCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
    [self.collectionView setDelegate:self];
    
    [self setTitle:NSLocalizedString(@"Tags", nil)];
    
    self.currentSort = @"name,asc";
    
    UIButton *sortingButton = [[UIButton alloc] init];
    NSMutableAttributedString *sortingSymbol = [[NSAttributedString symbol:dlf_icon_menu_sort size:25] mutableCopy];
    [sortingButton setAttributedTitle:sortingSymbol forState:UIControlStateNormal];
    [sortingButton sizeToFit];
    [sortingButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -10)];
    [sortingButton addTarget:self action:@selector(didTapSortButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:sortingButton];
    [self.navigationItem setRightBarButtonItem:leftItem];
    
    [self.collectionView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[SyncEngine sharedEngine] startSyncingTags];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didTapSortButton:(id)sender {
    SortTableViewController *sort = [[SortTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [sort setResourceClass:Tag.class];
    [sort setSortingDelegate:self];
    [sort setSelectedSort:self.currentSort];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sort];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)restoreContentInset {
    [self.collectionView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    [self.collectionView setScrollIndicatorInsets:self.collectionView.contentInset];
}

#pragma mark - SortingDelegate

- (void)sortTableViewController:(id)sortTableViewController didSelectSort:(NSString *)sort {
    if (![self.currentSort isEqualToString:sort]) {
        self.currentSort = sort;
        NSArray *sortArray = [sort componentsSeparatedByString:@","];
        BOOL ascending = YES;
        TagsSortKey selectedSortKey;
        if ([[sortArray objectAtIndex:0] isEqualToString:NSStringFromSelector(@selector(name))]) {
            selectedSortKey = TagsSortKeyName;
        } else {
            selectedSortKey = TagsSortKeyNumberOfPhotos;
        }
        if ([[[sortArray objectAtIndex:1] lowercaseString] isEqualToString:@"desc"]) {
            ascending = NO;
        }
        [((TagsDataSource *)self.dataSource) sortBy:selectedSortKey ascending:ascending];
        [sortTableViewController dismissViewControllerAnimated:YES completion:^{
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }];
    } else {
        [sortTableViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Getters

- (Class)dataSourceClass {
    return TagsDataSource.class;
}

- (ResourceType)resourceType {
    return TagResource;
}

- (Class)resourceClass {
    return [Tag class];
}

- (NSString *)cellIdentifier {
    return @"tagCell";
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Tag *tag = (Tag *)[self.dataSource itemAtIndexPath:indexPath];
    
    NSString *tagId = [tag.tagId copy];
    
    PhotosSubsetViewController *subsetController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"photosSubsetViewController"];
    [subsetController setItem:tag];
    [subsetController setFilterName:[NSString stringWithFormat:@"tag-%@", tagId]];
    [subsetController setFilterBlock:^BOOL(NSString *collection, NSString *key, id object) {
        if (![object isKindOfClass:[Photo class]]) {
            return NO;
        }
        for (NSString *a in ((Photo *)object).tags) {
            if ([a isEqualToString:tagId]) {
                return YES;
            }
        }
        return NO;
    }];
    
    [self.navigationController pushViewController:subsetController animated:YES];
}

#pragma mark - Collection View Flow Layout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.frame);
    return CGSizeMake(collectionViewWidth, 44);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

#pragma mark - Syncing Notification

- (void)didFinishSyncingNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *resource = userInfo[SyncEngineNotificationResourceKey];
    if ([resource isEqualToString:NSStringFromClass([self resourceClass])]) {
        [self.navigationItem setLeftBarButtonItem:nil];
    }
}

@end

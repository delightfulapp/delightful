//
//  AlbumsViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "AlbumsViewController.h"

#import "AlbumCell.h"
#import "Album.h"

#import "PhotosViewController.h"
#import "PhotosSectionHeaderView.h"

#import "ConnectionManager.h"

@interface AlbumsViewController () <UIActionSheetDelegate>

@end

@implementation AlbumsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAlbumsCount:0 max:0];    
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user.png"] style:UIBarButtonItemStylePlain target:self action:@selector(userTapped:)];
    [self.navigationItem setLeftBarButtonItem:left];
    
    [self.navigationItem.backBarButtonItem setTitle:NSLocalizedString(@"Albums", nil)];
}

- (void)setAlbumsCount:(int)count max:(int)max{
    if (count == 0) {
        self.title = NSLocalizedString(@"Albums", nil);
    } else {
        self.title = [NSString stringWithFormat:@"%@ (%d/%d)", NSLocalizedString(@"Albums", nil), count, max];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)sortDescriptors {
    return @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
}

- (ResourceType)resourceType {
    return AlbumResource;
}

- (Class)resourceClass {
    return [Album class];
}

- (void)didFetchItems {
    int count = [self.dataSource numberOfItems];
    [self setAlbumsCount:count max:self.totalItems];
}

- (NSString *)segue {
    return @"pushPhotosFromAlbums";
}

- (NSString *)sectionHeaderIdentifier {
    return @"albumSection";
}

- (NSString *)cellIdentifier {
    return @"albumCell";
}

- (CollectionViewHeaderCellConfigureBlock)headerCellConfigureBlock {
    void (^configureCell)(PhotosSectionHeaderView*, id,NSIndexPath*) = ^(PhotosSectionHeaderView* cell, id item,NSIndexPath *indexPath) {
        [cell.titleLabel setText:@"＞"];
        [cell.locationLabel setText:NSLocalizedString(@"All Photos", nil)];
        [cell setHideLocation:YES];
        int count = cell.gestureRecognizers.count;
        if (count == 0) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnAllAlbum:)];
            [tap setNumberOfTapsRequired:1];
            [tap setNumberOfTouchesRequired:1];
            [cell addGestureRecognizer:tap];
        }
    };
    return configureCell;
}

#pragma mark - Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:[self segue]]) {
        AlbumCell *cell = (AlbumCell *)sender;
        Album *album;
        if (!cell) {
            album = [Album allPhotosAlbum];
        } else {
            album = cell.item;
        }
        PhotosViewController *destination = (PhotosViewController *)segue.destinationViewController;
        [destination setItem:album];
    }
}

#pragma mark - Tap

- (void)tapOnAllAlbum:(UITapGestureRecognizer *)gesture {
    [self performSegueWithIdentifier:[self segue] sender:nil];
}

- (void)userTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to logout?", Nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Log out", nil), nil];
    [actionSheet showInView:self.navigationController.view];
}

#pragma mark - Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:{
            [[ConnectionManager sharedManager] logout];
            break;
        }
        default:
            break;
    }
}

@end

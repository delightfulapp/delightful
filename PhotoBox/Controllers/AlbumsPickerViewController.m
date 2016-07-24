//
//  AlbumsPickercollectionViewController.m
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "AlbumsPickerViewController.h"

#import "Album.h"

#import "APIClient.h"

#import "MBProgressHUD.h"

typedef NS_ENUM(NSInteger, AlbumsPickerState) {
    AlbumsPickerStateNormal,
    AlbumsPickerStateFetching
};

@interface AlbumsPickerViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *albums;

@property (nonatomic, strong) NSMutableArray *tempAlbums;

@property (nonatomic, assign) BOOL isFetchingAlbums;

@property (nonatomic, assign) AlbumsPickerState state;

@property (nonatomic, assign) int page;

@end

@implementation AlbumsPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    self.title = NSLocalizedString(@"Albums", nil);
    
    self.page = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setState:(AlbumsPickerState)state {
    _state = state;
    
    if (state == AlbumsPickerStateFetching) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithCustomView:activityView];
        [activityView startAnimating];
        [self.navigationItem setRightBarButtonItem:addButton];
        self.isFetchingAlbums = YES;
    } else {
        [self.navigationItem setRightBarButtonItem:nil];
        self.isFetchingAlbums = NO;
        if (self.selectedAlbum) {
            UIBarButtonItem *dontSetAlbumButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Don't set album", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dontSetAlbumButtonTapped:)];
            [self.navigationItem setRightBarButtonItem:dontSetAlbumButton];
        }
    }
}

- (NSString *)collectionView:(UICollectionView *)collectionView titleForHeaderInSection:(NSInteger)section {
    if ([(NSArray *)[self.albums objectAtIndex:section] count] > 0) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    return nil;
}

- (void)showRightBarButtonItem:(BOOL)show {
    if (show) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAlbumButtonTapped:)];
        UIBarButtonItem *noAlbum = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"No album", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dontSetAlbumButtonTapped:)];
        [self.navigationItem setRightBarButtonItems:@[addButton, noAlbum]];
    } else {
        [self.navigationItem setRightBarButtonItems:nil];
    }
}

#pragma mark - Table view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(albumsPickerViewController:didSelectAlbum:)]) {
        Album *album = (Album *)[self.dataSource itemAtIndexPath:indexPath];
        [self.delegate albumsPickerViewController:self didSelectAlbum:album];
    }
}

#pragma mark - Button actions

- (void)dontSetAlbumButtonTapped:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(albumsPickerViewController:didSelectAlbum:)]) {
        [self.delegate albumsPickerViewController:self didSelectAlbum:nil];
    }
}

- (void)addAlbumButtonTapped:(id)sender {
    
    if (self.state == AlbumsPickerStateFetching) {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New album", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Create", nil), nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
}

- (void)saveNewAlbum:(NSString *)albumName {
    if ([albumName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid album's name", nil) message:NSLocalizedString(@"Album name cannot be empty", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil];
        [alert show];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[APIClient sharedClient] createNewAlbum:albumName success:^(id responseObject) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (self.delegate && [self.delegate respondsToSelector:@selector(albumsPickerViewController:didSelectAlbum:)]) {
                [self.delegate albumsPickerViewController:self didSelectAlbum:responseObject];
            }
        } failure:^(NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self newAlbumDidFailWithError:error];
        }];
    }
}

- (void)newAlbumDidFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot make new album", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    UITextField *textField = [alertView textFieldAtIndex:0];
    CLS_LOG(@"Text = %@", textField.text);
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1:
            [self saveNewAlbum:textField.text];
            break;
        default:
            break;
    }
}

@end

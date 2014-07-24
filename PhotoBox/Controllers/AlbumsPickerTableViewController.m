//
//  AlbumsPickerTableViewController.m
//  Delightful
//
//  Created by  on 7/23/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "AlbumsPickerTableViewController.h"

#import "Album.h"

#import "PhotoBoxClient.h"

#import <MBProgressHUD.h>

typedef NS_ENUM(NSInteger, AlbumsPickerState) {
    AlbumsPickerStateNormal,
    AlbumsPickerStateFetching
};

@interface AlbumsPickerTableViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *albums;

@property (nonatomic, strong) NSMutableArray *tempAlbums;

@property (nonatomic, assign) BOOL isFetchingAlbums;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIButton *headerViewButton;

@property (nonatomic, assign) AlbumsPickerState state;

@property (nonatomic, assign) int page;

@end

@implementation AlbumsPickerTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    self.title = NSLocalizedString(@"Albums", nil);
    
    self.page = 1;
    
    [self setupHeaderView];
    
    //[self.tableView setBackgroundColor:[UIColor redColor]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.headerViewButton removeFromSuperview];
    self.headerViewButton = nil;
    [self.headerView removeFromSuperview];
    self.headerView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupHeaderView {
    if (!self.headerView) {
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.navigationController.view.frame), self.tableView.contentInset.top, CGRectGetWidth(self.view.frame), 44)];
        self.headerView.alpha = 0;
        [self.headerView setBackgroundColor:[UIColor whiteColor]];
        UIButton *newAlbumButton = [[UIButton alloc] initWithFrame:self.headerView.bounds];
        [newAlbumButton setTitle:NSLocalizedString(@"Fetching albums ...", nil) forState:UIControlStateNormal];
        [newAlbumButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [newAlbumButton setTitleColor:[[[[UIApplication sharedApplication] delegate] window] tintColor] forState:UIControlStateNormal];
        [newAlbumButton addTarget:self action:@selector(addAlbumButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:newAlbumButton];
        self.headerViewButton = newAlbumButton;
    }
    [self.navigationController.view insertSubview:self.headerView belowSubview:self.navigationController.navigationBar];
    
    self.tableView.contentInset = ({
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.top += (CGRectGetHeight(self.headerView.frame) + CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]));
        inset;
    });
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    
    self.headerView.frame = ({
        CGRect frame = self.headerView.frame;
        frame.origin.y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        frame;
    });
    
    [self.headerView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.headerView.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.headerView.layer setShadowRadius:0];
    [self.headerView.layer setShadowOpacity:0.1];
    [self.headerView.layer setShadowPath:[UIBezierPath bezierPathWithRect:self.headerView.bounds].CGPath];
    
    [self fetchAlbums];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.headerView.frame = ({
            CGRect frame = self.headerView.frame;
            frame.origin.x = 0;
            frame;
        });
        [self.headerView setAlpha:1];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)setState:(AlbumsPickerState)state {
    _state = state;
    
    if (state == AlbumsPickerStateFetching) {
        [self.headerViewButton setTitle:NSLocalizedString(@"Fetching albums ...", nil) forState:UIControlStateNormal];
        [self.headerViewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithCustomView:activityView];
        [activityView startAnimating];
        [self.navigationItem setRightBarButtonItem:addButton];
        self.isFetchingAlbums = YES;
    } else {
        [self.headerViewButton setTitle:NSLocalizedString(@"Create new album", nil) forState:UIControlStateNormal];
        [self.headerViewButton setTitleColor:[[[[UIApplication sharedApplication] delegate] window] tintColor] forState:UIControlStateNormal];
        [self.navigationItem setRightBarButtonItem:nil];
        self.isFetchingAlbums = NO;
        if (self.selectedAlbum) {
            UIBarButtonItem *dontSetAlbumButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Don't set album", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dontSetAlbumButtonTapped:)];
            [self.navigationItem setRightBarButtonItem:dontSetAlbumButton];
        }
    }
}

- (void)fetchAlbums {
    if (!self.isFetchingAlbums) {
        self.isFetchingAlbums = YES;
        self.state = AlbumsPickerStateFetching;
        
        [[PhotoBoxClient sharedClient] getResource:AlbumResource action:ListAction resourceId:nil page:self.page success:^(NSArray *objects) {
            
            if (objects.count > 0) {
                if (!self.tempAlbums) {
                    self.tempAlbums = [NSMutableArray array];
                }
                [self.tempAlbums addObjectsFromArray:objects];
                
                self.page++;
                self.isFetchingAlbums = NO;
                [self fetchAlbums];
            } else {
                NSLog(@"Done fetching all albums ");
                UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
                
                for (Album *theAlbum in self.tempAlbums) {
                    NSInteger sect = [theCollation sectionForObject:theAlbum collationStringSelector:@selector(name)];
                    theAlbum.sectionNumber = sect;
                }
                
                NSInteger highSection = [[theCollation sectionTitles] count];
                NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
                for (int i = 0; i < highSection; i++) {
                    NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
                    [sectionArrays addObject:sectionArray];
                }
                
                for (Album *theAlbum in self.tempAlbums) {
                    [(NSMutableArray *)[sectionArrays objectAtIndex:theAlbum.sectionNumber] addObject:theAlbum];
                }
                
                if (!self.albums) {
                    self.albums = [NSMutableArray array];
                }
                
                for (NSMutableArray *sectionArray in sectionArrays) {
                    NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray
                                                        collationStringSelector:@selector(name)];
                    [self.albums addObject:sortedSection];
                }
                
                self.state = AlbumsPickerStateNormal;
                self.isFetchingAlbums = NO;
                [self.tableView reloadData];
            }
            
        } failure:^(NSError *error) {
            self.state = AlbumsPickerStateNormal;
            self.isFetchingAlbums = NO;
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.albums.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)[self.albums  objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"albumCell"];
    }
    Album *album = (Album *)[(NSArray *)[self.albums objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = album.name;
    
    if (self.selectedAlbum && [self.selectedAlbum.albumId isEqualToString:album.albumId]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.albums.count == 0) {
        return nil;
    }
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([(NSArray *)[self.albums objectAtIndex:section] count] > 0) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(albumsPickerViewController:didSelectAlbum:)]) {
        [self.delegate albumsPickerViewController:self didSelectAlbum:[(NSArray *)[self.albums objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
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
        [[PhotoBoxClient sharedClient] POST:@"v1/album/create.json" parameters:@{@"name": albumName} resultClass:[Album class] resultKeyPath:@"result" completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (error) {
                [self newAlbumDidFailWithError:error];
            } else {
                NSLog(@"New album = %@", responseObject);
                if (self.delegate && [self.delegate respondsToSelector:@selector(albumsPickerViewController:didSelectAlbum:)]) {
                    [self.delegate albumsPickerViewController:self didSelectAlbum:responseObject];
                }
            }
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
    NSLog(@"Text = %@", textField.text);
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

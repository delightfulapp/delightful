//
//  PhotoBoxViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotoBoxViewController.h"

#import "ConnectionManager.h"

#import "PhotoBoxCell.h"

@interface PhotoBoxViewController ()

@end

@implementation PhotoBoxViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    if (![[ConnectionManager sharedManager] baseURL]) {
        [[ConnectionManager sharedManager] setBaseURL:[NSURL URLWithString:@"http://nicnocquee.trovebox.com"]
                                          consumerKey:@"1aea715c0f861ee8c4421b6904396d"
                                       consumerSecret:@"8043463882"
                                           oauthToken:@"c2a234a82d5caf468bcc5ed84fc8b8"
                                          oauthSecret:@"a5669d36c8"];
    }
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    self.dataSource = [[CollectionViewDataSource alloc] init];
    self.collectionView.dataSource = self.dataSource;
    [self setupDataSourceConfigureBlock];
    [self.collectionView setAlwaysBounceVertical:YES];
    [self.collectionView setAlwaysBounceVertical:YES];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.collectionView addSubview:self.refreshControl];
    self.page = 1;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    int count = self.items.count;
    if (count == 0) {
        [self fetchResource];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupDataSourceConfigureBlock {
    [self.dataSource setConfigureCellBlock:[self cellConfigureBlock]];
}

- (CollectionViewCellConfigureBlock)cellConfigureBlock {
    void (^configureCell)(PhotoBoxCell*, id) = ^(PhotoBoxCell* cell, id item) {
        [cell setItem:item];
    };
    return configureCell;
}

- (void)fetchResource {
    if (!self.isFetching) {
        [[PhotoBoxClient sharedClient] getResource:self.resourceType
                                            action:ListAction
                                        resourceId:self.resourceId
                                              page:self.page
                                           success:^(id object) {
                                               self.items = object;
                                               [self.dataSource setItems:self.items];
                                               [self.collectionView reloadData];
                                               self.isFetching = NO;
                                           } failure:^(NSError *error) {
                                               [self showError:error];
                                           }];
    }
    
}

- (void)refresh {
    
}

-(void)showError:(NSError *)error {
    self.isFetching = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil];
    [alert show];
}

@end

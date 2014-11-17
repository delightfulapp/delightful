//
//  FavoritesViewController.m
//  Delightful
//
//  Created by  on 11/16/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "FavoritesViewController.h"

#import "YapDataSource.h"

#import "FavoritesManager.h"

#import "DLFYapDatabaseViewAndMapping.h"

#import <UIView+AutoLayout.h>

@interface FavoritesDataSource : YapDataSource

@property (nonatomic, strong) DLFYapDatabaseViewAndMapping *favoritesMapping;

@end

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    BOOL needToRestoreOffset = NO;
    if (self.collectionView.contentOffset.y == -self.collectionView.contentInset.top) {
        needToRestoreOffset = YES;
    }
    [self restoreContentInset];
    if (needToRestoreOffset) {
        self.collectionView.contentOffset = CGPointMake(0,  -self.collectionView.contentInset.top);
    }
    
    [((YapDataSource *)self.dataSource) setPause:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Class)dataSourceClass {
    return [FavoritesDataSource class];
}

- (void)showEmptyLoading:(BOOL)show {
    if (!show) {
        [super showEmptyLoading:show];
    } else {
        UIView *view = self.collectionView.backgroundView;
        
        if (!view) {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
            [self.collectionView setBackgroundView:view];
            [view setBackgroundColor:[UIColor whiteColor]];
        }
        
        UILabel *textLabel = (UILabel *)[view viewWithTag:10000];
        if (!textLabel) {
            textLabel = [[UILabel alloc] initForAutoLayout];
            [textLabel setNumberOfLines:0];
            [textLabel setTag:10000];
            [view addSubview:textLabel];
            [textLabel autoCenterInSuperview];
            
            [textLabel setTextColor:[UIColor lightGrayColor]];
            [textLabel setFont:[UIFont systemFontOfSize:12]];
            [textLabel setTextAlignment:NSTextAlignmentCenter];
        }
        
        [textLabel setText:[self noPhotosMessage]];
        [textLabel sizeToFit];
    }
}

- (NSString *)noPhotosMessage {
    return NSLocalizedString(@"Favorited photos will appear here", nil);
}

@end

@implementation FavoritesDataSource

- (void)setupMapping {
    self.favoritesMapping = [[FavoritesManager sharedManager] databaseViewMapping];
}

- (void)setDefaultMapping {
    self.selectedViewMapping = self.favoritesMapping;
}

@end

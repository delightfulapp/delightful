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

#import "UIViewController+DelightfulViewControllers.h"

#import <JASidePanelController.h>

#import "AppDelegate.h"

@interface TagsViewController ()

@end

@implementation TagsViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self.tabBarItem setTitle:NSLocalizedString(@"Tags", nil)];
    [self.tabBarItem setImage:[[UIImage imageNamed:@"Tags"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setup];
    [self.collectionView registerClass:[TagRowCell class] forCellWithReuseIdentifier:[self cellIdentifier]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters

- (ResourceType)resourceType {
    return TagResource;
}

- (Class)resourceClass {
    return [Tag class];
}

- (NSString *)sectionHeaderIdentifier {
    return @"tagSection";
}

- (NSString *)cellIdentifier {
    return @"tagCell";
}

- (NSArray *)sortDescriptors {
    return @[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(tagId)) ascending:YES]];
}

- (int)pageSize {
    return 0;
}

#pragma mark - Do stuff

/**
 *  We're subclassing AlbumsViewController so let's just override this method to set the title of this view controller.
 *
 *  @param count Number of tags.
 *  @param max   Total number of tags.
 */

- (void)setAlbumsCount:(int)count max:(int)max{
    if (count == 0) {
        self.title = NSLocalizedString(@"Tags", nil);
    } else {
        self.title = [NSString stringWithFormat:@"%@ (%d/%d)", NSLocalizedString(@"Tags", nil), count, max];
    }
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Tag *tag = (Tag *)[self.dataSource itemAtIndexPath:indexPath];
    [self loadPhotosInTag:tag];
}

- (void)loadPhotosInTag:(Tag *)tag {    
    PhotosViewController *photosViewController = [UIViewController mainPhotosViewController];
    [photosViewController setItem:tag];
    [photosViewController setTitle:[NSString stringWithFormat:@"#%@",tag.tagId]];
    [photosViewController setRelationshipKeyPathWithItem:@"tags"];
    [photosViewController setResourceType:PhotoWithTagsResource];
    [photosViewController refresh];
    
    JASidePanelController *panelController = (JASidePanelController *)[[((AppDelegate *)[[UIApplication sharedApplication] delegate]) window] rootViewController];
    [panelController toggleLeftPanel:nil];
}

#pragma mark - Collection View Flow Layout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.frame);
    return CGSizeMake(collectionViewWidth, 44);
}

@end

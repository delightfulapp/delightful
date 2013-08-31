//
//  PhotosViewController.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "PhotosViewController.h"

#import "Album.h"
#import "Photo.h"

@interface PhotosViewController ()

@end

@implementation PhotosViewController

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
    
    NSString *identifier = @"photoCell";
    [self.dataSource setCellIdentifier:identifier];
    
    [self setPhotosCount:0 max:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ResourceType)resourceType {
    return PhotoResource;
}

- (NSString *)resourceId {
    return self.item.itemId;
}

- (void)didFetchItems {
    int count = self.items.count;
    [self setPhotosCount:count max:self.totalItems];
}


- (void)setPhotosCount:(int)count max:(int)max{
    NSString *title = NSLocalizedString(@"Photos", nil);
    Album *album = (Album *)self.item;
    if (album) {
        title = album.name;
    }
    if (count == 0) {
        self.title = title;
    } else {
        self.title = [NSString stringWithFormat:@"%@ (%d/%d)", title, count, max];
    }
}


@end

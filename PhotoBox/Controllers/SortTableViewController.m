//
//  SortTableViewController.m
//  Delightful
//
//  Created by  on 10/19/14.
//  Copyright (c) 2014 Touches. All rights reserved.
//

#import "SortTableViewController.h"

#import "Photo.h"
#import "Album.h"
#import "Tag.h"

@interface SortTableViewController ()

@property (nonatomic, copy) NSArray *rows;

@end

@implementation SortTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.resourceClass || self.resourceClass == Photo.class) {
        _rows = @[
                  @[NSLocalizedString(@"Date uploaded", nil), NSLocalizedString(@"9->1", nil), @"dateUploaded,desc"],
                  @[NSLocalizedString(@"Date uploaded", nil), NSLocalizedString(@"1->9", nil), @"dateUploaded,asc"],
                  @[NSLocalizedString(@"Date taken", nil), NSLocalizedString(@"9->1", nil), @"dateTaken,desc"],
                  @[NSLocalizedString(@"Date taken", nil), NSLocalizedString(@"1->9", nil), @"dateTaken,asc"],
                  ];
    } else if (self.resourceClass == Album.class) {
        _rows = @[
                  @[NSLocalizedString(@"Name", nil), NSLocalizedString(@"Z->A", nil), @"name,desc"],
                  @[NSLocalizedString(@"Name", nil), NSLocalizedString(@"A->Z", nil), @"name,asc"],
                  @[NSLocalizedString(@"Last updated", nil), NSLocalizedString(@"9->1", nil), @"dateLastPhotoAdded,desc"],
                  @[NSLocalizedString(@"Last updated", nil), NSLocalizedString(@"1->9", nil), @"dateLastPhotoAdded,asc"],
                  ];
    }
    
    
    self.title = NSLocalizedString(@"Sort", nil);
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(didTapCancel:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setRows:(NSArray *)rows {
    if (_rows != rows) {
        _rows = rows;
        
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    NSArray *text = self.rows[indexPath.row];
    [cell.textLabel setText:text[0]];
    [cell.detailTextLabel setText:text[1]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *selectedSort = self.rows[indexPath.row];
    if (self.sortingDelegate && [self.sortingDelegate respondsToSelector:@selector(sortTableViewController:didSelectSort:)]) {
        [self.sortingDelegate sortTableViewController:self didSelectSort:selectedSort[2]];
    }
}

@end

//
//  SortTableViewController.m
//  Delightful
//
//  Created by  on 10/19/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import "SortTableViewController.h"

#import "Photo.h"
#import "Album.h"
#import "Tag.h"

#import "NSAttributedString+DelighftulFonts.h"

NSString *const dateUploadedDescSortKey = @"dateUploaded,desc";
NSString *const dateUploadedAscSortKey = @"dateUploaded,asc";
NSString *const dateTakenDescSortKey = @"dateTaken,desc";
NSString *const dateTakenAscSortKey = @"dateTaken,asc";
NSString *const nameDescSortKey = @"name,desc";
NSString *const nameAscSortKey = @"name,asc";
NSString *const countDescSortKey = @"count,desc";
NSString *const countAscSortKey = @"count,asc";
NSString *const dateLastPhotoAddedDescSortKey = @"dateLastPhotoAdded,desc";
NSString *const dateLastPhotoAddedAscSortKey = @"dateLastPhotoAdded,asc";

@interface SortTableViewController ()

@property (nonatomic, copy) NSArray *rows;

@end

@implementation SortTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.resourceClass || self.resourceClass == Photo.class) {
        _rows = @[
                  @[NSLocalizedString(@"Date uploaded", nil), [NSAttributedString symbol:dlf_icon_sort_numeric_desc size:17], dateUploadedDescSortKey],
                  @[NSLocalizedString(@"Date uploaded", nil), [NSAttributedString symbol:dlf_icon_sort_numeric_asc size:17], dateUploadedAscSortKey],
                  @[NSLocalizedString(@"Date taken", nil), [NSAttributedString symbol:dlf_icon_sort_numeric_desc size:17], dateTakenDescSortKey],
                  @[NSLocalizedString(@"Date taken", nil), [NSAttributedString symbol:dlf_icon_sort_numeric_asc size:17], dateTakenAscSortKey],
                  ];
    } else if (self.resourceClass == Album.class) {
        _rows = @[
                  @[NSLocalizedString(@"Name", nil), [NSAttributedString symbol:dlf_icon_sort_alpha_desc size:17], nameDescSortKey],
                  @[NSLocalizedString(@"Name", nil), [NSAttributedString symbol:dlf_icon_sort_alpha_asc size:17], nameAscSortKey],
                  @[NSLocalizedString(@"Last updated", nil), [NSAttributedString symbol:dlf_icon_sort_numeric_desc size:17], dateLastPhotoAddedDescSortKey],
                  @[NSLocalizedString(@"Last updated", nil), [NSAttributedString symbol:dlf_icon_sort_numeric_asc size:17], dateLastPhotoAddedAscSortKey],
                  ];
    } else if (self.resourceClass == Tag.class) {
        _rows = @[
                  @[NSLocalizedString(@"Name", nil), [NSAttributedString symbol:dlf_icon_sort_alpha_desc size:17], nameDescSortKey],
                  @[NSLocalizedString(@"Name", nil), [NSAttributedString symbol:dlf_icon_sort_alpha_asc size:17], nameAscSortKey],
                  @[NSLocalizedString(@"Number of photos", nil), [NSAttributedString symbol:dlf_icon_sort_numeric_desc size:17], countDescSortKey],
                  @[NSLocalizedString(@"Number of photos", nil), [NSAttributedString symbol:dlf_icon_sort_numeric_asc size:17], countAscSortKey],
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
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", text[0]]];
    NSMutableAttributedString *sortAttr = [text[1] mutableCopy];
    [sortAttr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, sortAttr.string.length)];
    [attr appendAttributedString:sortAttr];
    [cell.textLabel setAttributedText:attr];
    NSString *sort = text[2];
    if ([self.selectedSort isEqualToString:sort]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
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

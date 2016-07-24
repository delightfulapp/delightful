//
//  InfoTableViewCell.h
//  Delightful
//
//  Created by Nico Prananta on 5/18/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *infoTextLabel;

- (void)setText:(NSString *)text detail:(NSString *)detail;

@end

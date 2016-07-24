//
//  SmartTagButton.h
//  Delightful
//
//  Created by  on 12/18/14.
//  Copyright (c) 2014-2016 DelightfulDev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TagState) {
    TagStateSelected,
    TagStateNotSelected
};

@interface SmartTagButton : UIButton

@property (nonatomic, assign) TagState tagState;
@property (nonatomic, strong) NSString *assetIdentifier;

@end

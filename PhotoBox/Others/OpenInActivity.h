//
//  OpenInActivity.h
//  Scribeit
//
//  Created by Nico Prananta on 12/26/12.
//  Copyright (c) 2012 Appsccelerated. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenInActivity;

@protocol OpenInActivityDelegate <NSObject>

- (void)didTapOnOpenInActivity:(OpenInActivity *)openInActivity;

@end

@interface OpenInActivity : UIActivity

@property (nonatomic, weak) id<OpenInActivityDelegate>delegate;

@end

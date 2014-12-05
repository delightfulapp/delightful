//
//  IntroViewController.h
//  PhotoBox
//
//  Created by Nico Prananta on 10/23/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SeeThroughCircleView;

@interface IntroViewController : UIViewController
@property (weak, nonatomic) IBOutlet SeeThroughCircleView *versionView;
@property (weak, nonatomic) IBOutlet UITextView *whatsNewLabel;
@end

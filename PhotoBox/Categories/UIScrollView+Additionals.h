//
//  UIScrollView+Additionals.h
//  Monoco
//
//  Created by Nico Prananta on 5/16/12.
//  Copyright (c) 2012 FlutterScape. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (Additionals)

- (BOOL)hasReachedBottom;
- (void)scrollToBottom;
- (void)scrollToTop;

@end

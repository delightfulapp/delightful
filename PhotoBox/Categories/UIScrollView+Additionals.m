//
//  UIScrollView+Additionals.m
//  Monoco
//
//  Created by Nico Prananta on 5/16/12.
//  Copyright (c) 2012 FlutterScape. All rights reserved.
//

#import "UIScrollView+Additionals.h"

@implementation UIScrollView (Additionals)

- (BOOL)hasReachedBottom {
    float bottomEdge = self.contentOffset.y + self.frame.size.height;
    if (bottomEdge >= self.contentSize.height) {
        return YES;
    }
    return NO;
}

- (void)scrollToBottom {
    CGSize size = self.contentSize;
    CGSize frameSize = self.frame.size;
    [self setContentOffset:CGPointMake(0, size.height-frameSize.height) animated:YES];
}

- (void)scrollToTop {
    [self setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end

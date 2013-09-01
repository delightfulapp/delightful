//
//  OpenInActivity.m
//  Scribeit
//
//  Created by Nico Prananta on 12/26/12.
//  Copyright (c) 2012 Appsccelerated. All rights reserved.
//

#import "OpenInActivity.h"

@implementation OpenInActivity

- (NSString *)activityType {
    return @"openin.activity";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Open in", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"activity.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)performActivity {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapOnOpenInActivity:)]) {
        [self.delegate didTapOnOpenInActivity:self];
    }
    [self activityDidFinish:YES];
}

@end

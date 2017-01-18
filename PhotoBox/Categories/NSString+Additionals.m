//
//  NSString+Additionals.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/6/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "NSString+Additionals.h"

@implementation NSString (Additionals)

- (BOOL)isValidURL {
    NSError *error;
    NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:&error];
    NSInteger numberOfMatches = [detector numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)];
    if (numberOfMatches > 0) {
        return YES;
    }
    return NO;
}

- (NSString *)stringWithHttpSchemeAddedIfNeeded {
    NSString *urlToTest = self;
    if (![self hasPrefix:@"http://"] && ![self hasPrefix:@"https://"]) {
        urlToTest = [NSString stringWithFormat:@"http://%@", self];
    }
    return urlToTest;
}

- (NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end {
    NSScanner* scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}

- (NSDate *)date {
    static NSDateFormatter *df;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
    });

    return [df dateFromString:self];
}

- (NSString *)localizedDate {
    NSDate *date = [self date];
    return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)htmlLinkString {
    return [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", self, self];
}

@end

//
//  MWInterpollationEffect.m
//  NGAParallaxMotion Demo
//
//  Created by Łukasz Przytuła on 06.09.2013.
//  Copyright (c) 2013 Numerical Garden. All rights reserved.
//

#import "MWInterpollationMotionEffect.h"

@implementation MWInterpollationMotionEffect

- (instancetype)initWithKeyPath:(NSString *)keyPath interpollationIntensity:(CGFloat)interpollationIntensity type:(MWInterpolatingMotionEffectType)type
{
  self = [super init];
  if (self) {
    self.keyPath = keyPath;
    self.interpollationIntensity = interpollationIntensity;
    self.type = type;
  }
  return self;
}

- (NSDictionary *)keyPathsAndRelativeValuesForViewerOffset:(UIOffset)viewerOffset
{
  if (!self.keyPath) {
    return @{};
  }
  CGFloat offset = (self.type == MWInterpolatingMotionEffectTypeTiltAlongHorizontalAxis ? viewerOffset.horizontal : viewerOffset.vertical);
  return @{self.keyPath: @(offset * self.interpollationIntensity)};
}

@end

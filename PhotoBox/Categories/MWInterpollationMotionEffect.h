//
//  MWInterpollationEffect.h
//  NGAParallaxMotion Demo
//
//  Created by Łukasz Przytuła on 06.09.2013.
//  Copyright (c) 2013 Numerical Garden. All rights reserved.
//

typedef enum {
MWInterpolatingMotionEffectTypeTiltAlongHorizontalAxis,
MWInterpolatingMotionEffectTypeTiltAlongVerticalAxis
} MWInterpolatingMotionEffectType;

#import <UIKit/UIKit.h>

@interface MWInterpollationMotionEffect : UIMotionEffect

@property (nonatomic) MWInterpolatingMotionEffectType type;
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic) CGFloat interpollationIntensity;

- (instancetype)initWithKeyPath:(NSString *)keyPath interpollationIntensity:(CGFloat)interpollationIntensity type:(MWInterpolatingMotionEffectType)type;

@end

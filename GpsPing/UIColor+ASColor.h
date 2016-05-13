//
//  UIColor+ASColor.h
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ASColor)

+ (UIColor*)as_colorWithImage:(UIImage*)image;
+ (UIColor *)getRandomColor;
+ (UIColor*)as_darkblueColor;
+ (UIColor*)as_redColor;
@end

//
//  UIColor+ASColor.h
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ASColor)

+(UIColor*)as_greenColor;
+(UIColor*)as_grayColor;
+(UIColor*)as_colorWithImage:(UIImage*)image;
+(UIColor *)getRandomColor;
@end

//
//  UIColor+ASColor.m
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "UIColor+ASColor.h"
#import <UIImage+ResizeMagick.h>

@implementation UIColor (ASColor)

+(UIColor*)as_colorWithImage:(UIImage*)image {
//    cell.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"green.png"]];
    UIImage *imageForColor = [image resizedImageByHeight:[UIScreen mainScreen].bounds.size.height];
    return [UIColor colorWithPatternImage:imageForColor];
}

@end

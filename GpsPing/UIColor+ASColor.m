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

+(UIColor*)as_greenColor
{
    return [UIColor colorWithRed:0.3333 green:0.5451 blue:0.1843 alpha:1.0];
}

+(UIColor*)as_grayColor
{
    return [UIColor colorWithRed:0.4107 green:0.4107 blue:0.4107 alpha:1.0];
}

+(UIColor*)as_colorWithImage:(UIImage*)image {
    UIImage *imageForColor = [image resizedImageByHeight:[UIScreen mainScreen].bounds.size.height];
    return [UIColor colorWithPatternImage:imageForColor];
}

+(UIColor *)getRandomColor
{
    CGFloat hue = ( arc4random() % 256 / 255.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 127 / 255.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 127 / 255.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end

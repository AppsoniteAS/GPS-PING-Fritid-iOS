//
//  UIImage+ASAnnotations.m
//  GpsPing
//
//  Created by Pavel Ivanov on 28/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "UIImage+ASAnnotations.h"

@implementation UIImage (ASAnnotations)

+(UIImage*)getUserAnnotationImageWithColor:(UIColor*)color
{
    
    return [self generateImageWithBottomImage:[UIImage imageNamed:@"annotation_user_frame"]
                                        image:[[UIImage imageNamed:@"annotation_user_icon"] imageTintedWithColor:color]];
}

+(UIImage*)getLastPointAnnotationImageWithColor:(UIColor*)color
{
    return [self generateImageWithBottomImage:[UIImage imageNamed:@"annotation_point_frame"]
                                        image:[[UIImage imageNamed:@"annotation_point_icon"] imageTintedWithColor:color]];
}

+(UIImage*)getLastPointAnnotationImageWithColorName:(NSString*) name andRotation: (CGFloat) rotation{
    return [UIImage imageNamed: [NSString stringWithFormat: @"direction-%@", name ]];
}

+(UIImage*)getPointAnnotationImageWithColorName:(NSString*) name andRotation: (CGFloat) rotation{
    return  [UIImage imageNamed: [NSString stringWithFormat: @"direction-%@-small", name ]];
}


+(UIImage*)getPointAnnotationImageWithColor:(UIColor*)color
{
    return [self generateImageWithBottomImage:[UIImage imageNamed:@"annotation_circle_point_frame"]
                                        image:[[UIImage imageNamed:@"annotation_circle_point_icon"] imageTintedWithColor:color]];
}

+(UIImage*)generateImageWithBottomImage:(UIImage*)bottomImage
                                  image:(UIImage*)image {
    CGSize newSize = CGSizeMake(bottomImage.size.width, bottomImage.size.height);
    UIGraphicsBeginImageContext( newSize );
    [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)imageTintedWithColor:(UIColor *)color
{
    if (color) {
        // Construct new image the same size as this one.
        UIImage *image;
        
        UIGraphicsBeginImageContext([self size]);
        CGRect rect = CGRectZero;
        rect.size = [self size];
        
        // Composite tint color at its own opacity.
        [color set];
        UIRectFill(rect);

        // Mask tint color-swatch to this image's opaque mask.
        // We want behaviour like NSCompositeDestinationIn on Mac OS X.
        [self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    return self;
}

@end

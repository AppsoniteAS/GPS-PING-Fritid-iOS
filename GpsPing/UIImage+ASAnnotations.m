//
//  UIImage+ASAnnotations.m
//  GpsPing
//
//  Created by Pavel Ivanov on 28/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//
@import CoreImage;
@import CoreGraphics;


#import "UIImage+ASAnnotations.h"

@implementation UIImage (ASAnnotations)

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, 0.0);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



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
    UIImage* im =  [UIImage imageNamed: [NSString stringWithFormat: @"direction-%@", name ]];

    return [im imageRotatedByDegrees:rotation];
}



+(UIImage*)getPointAnnotationImageWithColorName:(NSString*) name andRotation: (CGFloat) rotation{
    return  [[UIImage imageNamed: [NSString stringWithFormat: @"direction-%@-small", name ]] imageRotatedByDegrees:rotation];
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


+ (UIImage*) combineImages: (UIImage*) image1 andImage: (UIImage*) image2 withVerticalOffset: (CGFloat) offset{
    //CGSize size = CGSizeMake(image1.size.width, image1.size.height + image2.size.height);
    CGSize size = image1.size;
    
    
    image2 = [UIImage scaleImage:image2 ToSize:CGSizeMake(image1.size.width  * 0.7 , image1.size.width* 0.7)];
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0); // Use this call
    
    [image1 drawInRect:CGRectMake(0,0,size.width, size.height)];
    // DDLogInfo(@"%@ %@",NSStringFromCGSize(image1.size),  NSStringFromCGSize(image2.size));
    [image2 drawInRect:CGRectMake(size.width / 2.0 - image2.size.width / 2.0,  offset , image2.size.width, image2.size.height)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return finalImage;
}

+ (UIImage *)scaleImage: (UIImage*) image ToSize:(CGSize)newSize {
    
    CGRect scaledImageRect = CGRectZero;
    
    CGFloat aspectWidth = newSize.width / image.size.width;
    CGFloat aspectHeight = newSize.height / image.size.height;
    CGFloat aspectRatio = MAX ( aspectWidth, aspectHeight );
    
    scaledImageRect.size.width = image.size.width * aspectRatio;
    scaledImageRect.size.height = image.size.height * aspectRatio;
    scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0f;
    scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0f;
    
    UIGraphicsBeginImageContextWithOptions( newSize, NO, 0 );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // DDLogInfo(@"logo aspect fill scale: %f", scaledImage.scale);
    
    return scaledImage;
    
}

@end

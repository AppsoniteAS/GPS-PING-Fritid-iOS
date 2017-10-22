//
//  UIImage+ASAnnotations.h
//  GpsPing
//
//  Created by Pavel Ivanov on 28/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ASAnnotations)
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
+(UIImage*)getUserAnnotationImageWithColor:(UIColor*)color;
+(UIImage*)getLastPointAnnotationImageWithColor:(UIColor*)color;
+(UIImage*)getPointAnnotationImageWithColor:(UIColor*)color;
+(UIImage*)getLastPointAnnotationImageWithColorName:(NSString*) name andRotation: (CGFloat) rotation;
+(UIImage*)getPointAnnotationImageWithColorName:(NSString*) name andRotation: (CGFloat) rotation;
@end

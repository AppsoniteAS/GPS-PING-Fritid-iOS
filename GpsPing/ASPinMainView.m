//
//  ASPinMainView.m
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/18/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import "ASPinMainView.h"
#import <YYWebImage.h>
#import "ASS3Manager.h"
#import "UIImage+ASAnnotations.h"
#define degreesToRadians(deg) (deg / 180.0 * M_PI)

@interface ASPinMainView()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewArrow;
@property (weak, nonatomic) IBOutlet UIView *viewArrowContainer;
@property (assign, nonatomic) CGFloat cornerRadius;
@end;

@implementation ASPinMainView


- (void)awakeFromNib{
    [super awakeFromNib];
    self.cornerRadius = 15;
    [self.imageViewPhoto.layer setCornerRadius:self.cornerRadius];
    [self.imageViewPhoto.layer setMasksToBounds:true];
    [self.viewArrowContainer.layer setCornerRadius:9];
    [self.viewArrowContainer.layer setMasksToBounds:true];
    [self.viewArrowContainer.layer setBorderWidth:1];
    [self.viewArrowContainer.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.imageViewPhoto.layer setBorderWidth:1];
    [self.imageViewPhoto.layer setBorderColor:[UIColor whiteColor].CGColor];
}


- (void) handleByImage: (UIImage*) image {
    [self.imageViewPhoto setImage:image];
}

- (void) handleByImageName: (NSString*) name arrowColor: (UIColor*) arrowColor rotation:(CGFloat) rotation{
        [self.imageViewPhoto yy_setImageWithURL:[ [ASS3Manager sharedInstance] getURLByImageIdentifier: name ]placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            if (from == YYWebImageFromDiskCache) {
            }
        }];
    
        self.imageViewArrow.alpha = arrowColor ? 1.0 : 0.0;
    self.imageViewArrow.image = [[UIImage imageNamed:@"direction2"] imageRotatedByDegrees:rotation];
    self.imageViewArrow.center = [self setPointToAngle:rotation - 90.0f center:self.center radius:CGRectGetWidth(self.imageViewPhoto.frame)/2.0];
    self.viewArrowContainer.center = self.imageViewArrow.center;
    self.viewArrowContainer.backgroundColor = arrowColor;
}

-(CGPoint)setPointToAngle:(int)angle center:(CGPoint)centerPoint radius:(double)radius
{
    return CGPointMake(radius*cos(degreesToRadians(angle)) + centerPoint.x, radius*sin(degreesToRadians(angle)) + centerPoint.y);
}

+ (ASPinMainView*) getMarkerView{
    ASPinMainView* marker = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ASPinMainView class]) owner:nil options:nil][0];
    return marker;
}

@end

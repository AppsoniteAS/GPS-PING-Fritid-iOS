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

@interface ASPinMainView()
@property (assign, nonatomic) CGFloat cornerRadius;
@end;

@implementation ASPinMainView


- (void)awakeFromNib{
    [super awakeFromNib];
    self.cornerRadius = 5;
    [self.imageViewPhoto.layer setCornerRadius:self.cornerRadius];
    [self.imageViewPhoto.layer setMasksToBounds:true];
}


- (void) handleByImage: (UIImage*) image {
    [self.imageViewPhoto setImage:image];
}

- (void) handleByImageName: (NSString*) name {
        [self.imageViewPhoto yy_setImageWithURL:[ [ASS3Manager sharedInstance] getURLByImageIdentifier: name ]placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            if (from == YYWebImageFromDiskCache) {
            }
        }];

}


+ (ASPinMainView*) getMarkerView{
    ASPinMainView* marker = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ASPinMainView class]) owner:nil options:nil][0];
    return marker;
}

@end

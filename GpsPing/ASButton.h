//
//  ASButton.h
//  GpsPing
//
//  Created by Pavel Ivanov on 18/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ASButtonStyle) {
    ASButtonStyleRed,
    ASButtonStyleGrey
};

@interface ASButton : UIButton

@property (nonatomic, assign) ASButtonStyle style;

@end

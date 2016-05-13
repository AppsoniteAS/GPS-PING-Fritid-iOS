//
//  ASButton.m
//  GpsPing
//
//  Created by Pavel Ivanov on 18/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASButton.h"

#define RED_STYLE_COLOR                   [UIColor as_redColor]
#define GREY_STYLE_COLOR                    [UIColor colorWithRed:0.8589 green:0.8589 blue:0.8589 alpha:1.0]
#define RED_STYLE_TITLE_COLOR             [UIColor whiteColor]
#define RED_STYLE_TITLE_HIGHLIGHTED_COLOR [UIColor colorWithRed:0.3523 green:0.3523 blue:0.3523 alpha:1.0]
#define GREY_STYLE_TITLE_COLOR            [UIColor colorWithRed:0.3523 green:0.3523 blue:0.3523 alpha:1.0]
#define GREY_STYLE_TITLE_HIGHLIGHTED_COLOR  GREY_STYLE_TITLE_COLOR

@implementation ASButton

-(void)awakeFromNib
{
//    self.layer.cornerRadius = 6.0;
//    self.layer.borderColor = GREEN_STYLE_BORDER_COLOR.CGColor;
    self.titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:20];

    self.style = ASButtonStyleRed;
    [self configWithBaseStyle];
    [self styleButton:NO];
}

-(void)setStyle:(ASButtonStyle)style
{
    _style = style;
    [self configWithBaseStyle];
}

-(void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self styleButton:!enabled];
}

-(void)styleButton:(BOOL)isHighlighted {
    if (isHighlighted) {
        self.backgroundColor = GREY_STYLE_COLOR;
//        self.layer.borderWidth = 0;
        self.style = ASButtonStyleGrey;
        [self configWithBaseStyle];
    } else {
        self.backgroundColor = RED_STYLE_COLOR;

//        self.layer.borderWidth = 0;
        self.style = ASButtonStyleRed;
        [self configWithBaseStyle];
    }
}

-(void)configWithBaseStyle {
    if (self.style == ASButtonStyleRed) {
        [self setTitleColor:RED_STYLE_TITLE_COLOR             forState:UIControlStateNormal];
        [self setTitleColor:RED_STYLE_TITLE_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
    } else {
        [self setTitleColor:GREY_STYLE_TITLE_COLOR            forState:UIControlStateNormal];
        [self setTitleColor:GREY_STYLE_TITLE_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
    }
}

@end

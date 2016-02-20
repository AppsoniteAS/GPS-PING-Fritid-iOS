//
//  ASButton.m
//  GpsPing
//
//  Created by Pavel Ivanov on 18/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASButton.h"

#define GREEN_STYLE_COLOR                   [UIColor colorWithRed:0.3333 green:0.5451 blue:0.1843 alpha:1.0]
#define GREEN_STYLE_BORDER_COLOR            [UIColor colorWithRed:0.5451 green:0.7647 blue:0.2902 alpha:1.0]
#define GREY_STYLE_COLOR                    [UIColor colorWithRed:0.8589 green:0.8589 blue:0.8589 alpha:1.0]
#define GREEN_STYLE_TITLE_COLOR             [UIColor whiteColor]
#define GREEN_STYLE_TITLE_HIGHLIGHTED_COLOR GREY_STYLE_TITLE_COLOR
#define GREY_STYLE_TITLE_COLOR              [UIColor colorWithRed:0.3523 green:0.3523 blue:0.3523 alpha:1.0]
#define GREY_STYLE_TITLE_HIGHLIGHTED_COLOR  GREY_STYLE_TITLE_COLOR

@implementation ASButton

-(void)awakeFromNib
{
    self.layer.cornerRadius = 6.0;
    self.layer.borderColor = GREEN_STYLE_BORDER_COLOR.CGColor;
    self.titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:20];

    self.style = ASButtonStyleGreen;
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
        self.layer.borderWidth = 0;
    } else {
        self.backgroundColor = GREEN_STYLE_COLOR;

        self.layer.borderWidth = 2.3;
    }
}

-(void)configWithBaseStyle {
    if (self.style == ASButtonStyleGreen) {
        [self setTitleColor:GREEN_STYLE_TITLE_COLOR             forState:UIControlStateNormal];
        [self setTitleColor:GREEN_STYLE_TITLE_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
    } else {
        [self setTitleColor:GREY_STYLE_TITLE_COLOR             forState:UIControlStateNormal];
        [self setTitleColor:GREY_STYLE_TITLE_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
    }
}

@end

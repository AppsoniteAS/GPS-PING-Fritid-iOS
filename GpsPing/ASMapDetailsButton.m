//
//  ASMapDetailsButton.m
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/1/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import "ASMapDetailsButton.h"


#define GREEN_STYLE_COLOR                   [UIColor colorWithRed:0.3333 green:0.5451 blue:0.1843 alpha:1.0]
#define GREEN_STYLE_BORDER_COLOR            [UIColor colorWithRed:0.5451 green:0.7647 blue:0.2902 alpha:1.0]
#define GREY_STYLE_COLOR                    [UIColor colorWithRed:0.8589 green:0.8589 blue:0.8589 alpha:1.0]
#define GREEN_STYLE_TITLE_COLOR             [UIColor whiteColor]
#define GREEN_STYLE_TITLE_HIGHLIGHTED_COLOR GREY_STYLE_TITLE_COLOR
#define GREY_STYLE_TITLE_COLOR              [UIColor colorWithRed:0.3523 green:0.3523 blue:0.3523 alpha:1.0]
#define GREY_STYLE_TITLE_HIGHLIGHTED_COLOR  GREY_STYLE_TITLE_COLOR


@implementation ASMapDetailsButton

-(void)awakeFromNib
{
    self.layer.cornerRadius = 11.0;
    self.titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:20];
    
    //[self configWithBaseStyle];
}


-(void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (enabled) {
        [self configWithBaseStyle];
    } else {
        [self configDisabledStyle];
    }
}

-(void)configWithBaseStyle {
   
        [self setTitleColor:GREEN_STYLE_TITLE_COLOR             forState:UIControlStateNormal];
        [self setTitleColor:GREEN_STYLE_TITLE_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
        self.backgroundColor = GREEN_STYLE_COLOR;

}

-(void)configDisabledStyle {
    [self setTitleColor:GREY_STYLE_TITLE_COLOR             forState:UIControlStateNormal];
    [self setTitleColor:GREY_STYLE_TITLE_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
    self.backgroundColor = GREY_STYLE_COLOR;
    
}

@end

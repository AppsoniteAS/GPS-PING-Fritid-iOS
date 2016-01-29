//
//  ASSearchBar.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/29/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASSearchBar.h"

@implementation ASSearchBar

- (void)layoutSubviews {
    self.backgroundImage = [[UIImage alloc] init];
    self.backgroundColor = [UIColor colorWithRed: 139.0/255 green: 195.0/255.0 blue: 74.0/255.0 alpha: 1.0];
    [super layoutSubviews];
}

@end

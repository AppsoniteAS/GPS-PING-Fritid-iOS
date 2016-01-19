//
//  ASNavigationController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASNavigationController.h"
#import "UIColor+ASColor.h"

@implementation ASNavigationController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor as_colorWithImage:[UIImage imageNamed:@"background"]];
}

@end

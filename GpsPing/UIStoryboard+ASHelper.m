//
//  UIStoryboard+ASHelper.m
//  GpsPing
//
//  Created by Pavel Ivanov on 20/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "UIStoryboard+ASHelper.h"

@implementation UIStoryboard (ASHelper)

+(UIStoryboard*)trackerStoryboard
{
    return [UIStoryboard storyboardWithName:@"Trackers"
                                     bundle:[NSBundle mainBundle]];
}

+(UIStoryboard*)mainMenuStoryboard
{
    return [UIStoryboard storyboardWithName:@"Main"
                                     bundle:[NSBundle mainBundle]];
}

+(UIStoryboard*)mapStoryboard
{
    return [UIStoryboard storyboardWithName:@"Map"
                                     bundle:[NSBundle mainBundle]];
}

@end

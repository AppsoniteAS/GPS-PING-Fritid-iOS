//
//  UIStoryboard+ASHelper.h
//  GpsPing
//
//  Created by Pavel Ivanov on 20/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (ASHelper)

+(UIStoryboard*)trackerStoryboard;
+(UIStoryboard*)trackerConfigurationStoryboard;
+(UIStoryboard*)mainMenuStoryboard;
+(UIStoryboard*)mapStoryboard;
+(UIStoryboard*)connectStoryboard;
+(UIStoryboard*)authStoryboard;
+(UIStoryboard*)introStoryboard;

@end

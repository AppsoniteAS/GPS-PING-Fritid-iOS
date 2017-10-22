//
//  ASQuestionListTableViewController.h
//  GpsPing
//
//  Created by Pavel Ivanov on 08/09/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DTTableViewManager/DTTableViewManager.h>

@interface ASQuestionListTableViewController : DTTableViewController
@property (strong, nonatomic) NSString* trackerType;
@end

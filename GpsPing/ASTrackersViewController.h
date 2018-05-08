//
//  ASTrackersViewController.h
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <DTTableViewManager/DTTableViewManager.h>
@protocol ASTrackersViewControllerProtocol <NSObject>

- (void) fetchFromServer;

@end
@interface ASTrackersViewController : DTTableViewController

@end

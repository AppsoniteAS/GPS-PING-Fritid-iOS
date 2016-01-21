//
//  ASViewController.h
//  GpsPing
//
//  Created by Maks Niagolov on 1/21/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASViewController : UIViewController
@property (nonatomic, weak    ) IBOutlet UIScrollView *scrollView;
- (void)registerForKeyboardNotifications;
@end

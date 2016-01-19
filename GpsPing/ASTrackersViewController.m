//
//  ASTrackersViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASTrackersViewController.h"
#import "ASTrackerModel.h"
#import "ASTrackerCell.h"

@interface ASTrackersViewController ()

@end

@implementation ASTrackersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerCellClass:[ASTrackerCell class]
              forModelClass:[ASTrackerModel class]];
    [self.memoryStorage addItems:@[[[ASTrackerModel alloc] init],
                                   [[ASTrackerModel alloc] init],
                                   [[ASTrackerModel alloc] init]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

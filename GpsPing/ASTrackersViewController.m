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
    [self.memoryStorage addItems:@[
                                   
                                   [ASTrackerModel initTrackerWithName:@"Judy" number:@"123123123" imei:@"567567567" type:kASTrackerTypeTkStar isChoosed:YES],
                                   
                                   [ASTrackerModel initTrackerWithName:@"Jonathan" number:@"123123123" imei:@"567567567" type:kASTrackerTypeTkStarPet isChoosed:NO],
                                   
                                   [ASTrackerModel initTrackerWithName:@"Richard" number:@"123123123" imei:@"567567567" type:kASTrackerTypeAnywhere isChoosed:YES]]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    ASTrackerModel *model = [self.memoryStorage itemAtIndexPath:indexPath];
    if (model.isChoosed) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
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

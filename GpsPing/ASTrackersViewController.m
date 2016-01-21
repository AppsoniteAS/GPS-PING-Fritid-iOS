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
#import "Masonry.h"
#import "ASTrackerConfigurationViewController.h"

@interface ASTrackersViewController ()

@end

@implementation ASTrackersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fillData];
    [self registerCellClass:[ASTrackerCell class]
              forModelClass:[ASTrackerModel class]];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.memoryStorage removeAllTableItems];
    [self.memoryStorage addItems:[ASTrackerModel getTrackersFromUserDefaults]];
    [self.tableView reloadData];
}

-(void)fillData {
    [[ASTrackerModel initTrackerWithName:@"Judy" number:@"987123123" imei:@"567567567" type:kASTrackerTypeTkStar isChoosed:YES] saveInUserDefaults];
    [[ASTrackerModel initTrackerWithName:@"Jonathan" number:@"51231233" imei:@"567567567" type:kASTrackerTypeTkStarPet isChoosed:NO] saveInUserDefaults];
    [[ASTrackerModel initTrackerWithName:@"Richard" number:@"122353423" imei:@"567567567" type:kASTrackerTypeAnywhere isChoosed:YES] saveInUserDefaults];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    ASTrackerModel *model = [self.memoryStorage itemAtIndexPath:indexPath];
    if (model.isChoosed) {
//        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    ASTrackerConfigurationViewController *configVC = [ASTrackerConfigurationViewController initialize];
    configVC.trackerObject = [self.memoryStorage itemAtIndexPath:indexPath];
    configVC.shouldShowInEditMode = YES;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:configVC];
    [self presentViewController:navVC animated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ASTrackerModel *model = [self.memoryStorage itemAtIndexPath:indexPath];
        [ASTrackerModel removeTrackerWithNumber:model.trackerNumber];
        [self.memoryStorage removeItem:model];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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

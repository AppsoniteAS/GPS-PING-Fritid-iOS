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
#import "AGApiController.h"
#import "ASSimpleTrackerCell.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface ASTrackersViewController () <ASTrackerCellProtocol>

@property (nonatomic, strong) AGApiController   *apiController;

@end

@implementation ASTrackersViewController

objection_requires(@keypath(ASTrackersViewController.new, apiController))

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self registerCellClass:[ASTrackerCell class]
              forModelClass:[ASTrackerModel class]];
    [self reloadTrackers];
    [self fetchFromServer];
   
}

- (void) fetchFromServer{
    [[self.apiController getTrackers] subscribeNext:^(NSArray *trackers) {
        NSArray *memoryTrackers = [ASTrackerModel getTrackersFromUserDefaults];
        for (ASTrackerModel *tracker in trackers) {
            for(ASTrackerModel *memoryTracker in memoryTrackers){
                if([memoryTracker.imeiNumber isEqualToString:tracker.imeiNumber]){
                    tracker.isChoosed = memoryTracker.isChoosed;
                    tracker.isRunning = memoryTracker.isRunning;
                }
            }
            [tracker saveInUserDefaults];
            [self reloadTrackers];
        }
    } error:^(NSError *error) {
        ;
    }];
}

- (void) reloadTrackers{
    [self.memoryStorage removeAllTableItems];
    [self.memoryStorage addItems:[ASTrackerModel getTrackersFromUserDefaults]];
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchFromServer];
   // [self reloadTrackers];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASSimpleTrackerCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"ASSimpleTrackerCell" forIndexPath:indexPath];
   // ((ASSimpleTrackerCell*)cell).delegate = self;
    ASTrackerModel *model = [self.memoryStorage itemAtIndexPath:indexPath];
    if (model.isChoosed) {
//        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    [cell handleByTracker:model];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASTrackerModel *model = [self.memoryStorage itemAtIndexPath:indexPath];
    ASTrackerConfigurationViewController *configVC = [ASTrackerConfigurationViewController initializeWithTrackerModel:model];
    if (!configVC){
        return;
    }
    [self.navigationController pushViewController:configVC animated:true];
    return;
    
//    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:configVC];
//    [self presentViewController:navVC animated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ASTrackerModel *model = [self.memoryStorage itemAtIndexPath:indexPath];
        [[self.apiController removeTrackerByImei:model.imeiNumber] subscribeNext:^(id x) {
            [ASTrackerModel removeTrackerWithNumber:model.trackerNumber];
            [self.memoryStorage removeItem:model];
        }];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(void)trackerCell:(ASTrackerCell *)cell didTapShowOnMap:(BOOL)needToShow forModel:(ASTrackerModel *)model
{
    if (!needToShow) {
        return;
    }
    
    model.isChoosed = YES;
    [model saveInUserDefaults];
    [self.memoryStorage reloadItem:model];
    for (ASTrackerModel *item in [self.memoryStorage itemsInSection:0]) {
        if (![item.imeiNumber isEqualToString:model.imeiNumber]) {
            item.isChoosed = NO;
            [item saveInUserDefaults];
            [self.memoryStorage reloadItem:item];
        }
    }
}

@end

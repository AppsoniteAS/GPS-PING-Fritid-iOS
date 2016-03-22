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

#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface ASTrackersViewController () <ASTrackerCellProtocol>

@property (nonatomic, strong) AGApiController   *apiController;

@end

@implementation ASTrackersViewController

objection_requires(@keypath(ASTrackersViewController.new, apiController))

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    ((ASTrackerCell*)cell).delegate = self;
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

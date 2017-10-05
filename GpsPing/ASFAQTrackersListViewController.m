//
//  ASFAQTrackersListViewController.m
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/5/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import "ASFAQTrackersListViewController.h"
#import "ASQuestionListTableViewController.h"
#import "ASAddTrackerCell.h"
#import "ASTrackerModel.h"
#import "UIStoryboard+ASHelper.h"
#import "ASFAQTrackerListCell.h"

@interface ASFAQTrackersListViewController ()<UITableViewDelegate, UITableViewDataSource,ASFAQTrackerListCellProtocol>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* trackers;

@end

@implementation ASFAQTrackersListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.trackers = @[kASTrackerTypeTk909, kASTrackerTypeTkS1, kASTrackerTypeTkA9];
    [self.tableView reloadData];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view datasource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.trackers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ASFAQTrackerListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ASFAQTrackerListCell" forIndexPath:indexPath];
    [cell handleBtTrackerName:self.trackers[indexPath.row] forcedName: (indexPath.row == 0 ? @"Original GPS Tracker" :  self.trackers[indexPath.row])];
    cell.delegate = self;
    return cell;
}

#pragma mark - Table view delegate


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 210;
}

#pragma mark - ASFAQTrackerListCellProtocol

- (void)didSelectTracker:(NSString *)trackerName{
    ASQuestionListTableViewController* trackerController = [[UIStoryboard faqStoryboard] instantiateViewControllerWithIdentifier:@"ASQuestionListTableViewController"];
   // trackerController.trackerName = trackerName;
    [self.navigationController pushViewController: trackerController animated:YES];
}

@end

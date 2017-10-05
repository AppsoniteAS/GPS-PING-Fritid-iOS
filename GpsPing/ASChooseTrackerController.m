//
//  ASChooseTrackerController.m
//  GpsPing
//
//  Created by Юджин Топсекретович on 9/5/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import "ASChooseTrackerController.h"
#import "ASAddTrackerCell.h"
#import "ASNewTrackerViewController.h"
#import "ASTrackerConfigurationViewController.h"

@interface ASChooseTrackerController ()<UITableViewDelegate, UITableViewDataSource, ASAddTrackerCellProtocol>

@property (strong, nonatomic) NSArray* trackers;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ASChooseTrackerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.trackers = @[kASTrackerTypeTkStarPet, kASTrackerTypeTkStarBike, kASTrackerTypeLK209, kASTrackerTypeLK330, kASTrackerTypeVT600, kASTrackerTypeTkS1, kASTrackerTypeTkA9];
    [self.tableView reloadData];
}


#pragma mark - Table view datasource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.trackers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ASAddTrackerCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ASAddTrackerCell" forIndexPath:indexPath];
    [cell handleBtTrackerName:self.trackers[indexPath.row]];
    cell.delegate = self;
    return cell;
}

#pragma mark - Table view delegate


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 183;
}

#pragma mark - ASAddTrackerCellProtocol

- (void)didSelectTracker:(NSString *)trackerName{
    ASNewTrackerViewController* trackerController = [self.storyboard instantiateViewControllerWithIdentifier:@"ASNewTrackerViewController_main"];
    trackerController.trackerName = trackerName;
    [self.navigationController pushViewController: trackerController animated:YES];
}

- (IBAction)cancelBtnTap:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end

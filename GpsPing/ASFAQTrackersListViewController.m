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
@import SafariServices;

@interface ASFAQTrackersListViewController ()<UITableViewDelegate, UITableViewDataSource,ASFAQTrackerListCellProtocol>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *labelTableTitle;
@property (strong, nonatomic) NSArray* trackers;
@property (strong, nonatomic) NSArray* trackersName;


@end

@implementation ASFAQTrackersListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.trackers = @[kASTrackerTypeTk909, kASTrackerTypeTkS1, kASTrackerTypeTkA9];
    self.trackersName = @[@"Original GPS Tracker", @"GPS Ping Marcel", @"GPS Ping Isabella"];
    [self.tableView reloadData];
    
    self.labelTableTitle.text = NSLocalizedString(@"select_your_tracker", nil);
    
}

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
    [cell handleBtTrackerName:self.trackers[indexPath.row] forcedName:  self.trackersName[indexPath.row]];
    cell.delegate = self;
    return cell;
}

#pragma mark - Table view delegate


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 210;
}

#pragma mark - ASFAQTrackerListCellProtocol

- (void)didSelectTracker:(NSString *)trackerName{
    if ([trackerName isEqualToString: @"S1"]){
        [self openLink:@"https://fritid.gpsping.no/brukerveiledning_marcel/"];
        return;
    }
    ASQuestionListTableViewController* trackerController = [[UIStoryboard faqStoryboard] instantiateViewControllerWithIdentifier:@"ASQuestionListTableViewController"];
    trackerController.trackerType = trackerName;
    [self.navigationController pushViewController: trackerController animated:YES];
}

- (void)openLink:(NSString *)url {
    NSURL *URL = [NSURL URLWithString:url];
    
    if (URL) {
        if ([SFSafariViewController class] != nil) {
            SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:URL];
            [self presentViewController:sfvc animated:YES completion:nil];
        } else {
            if (![[UIApplication sharedApplication] openURL:url]) {
                NSLog(@"%@%@",@"Failed to open url:",[url description]);
            }
        }
    } 
}

@end

//
//  ASFriendsListViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 26/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASFriendsListViewController.h"
#import "ASFriendTableViewCell.h"
#import "AGApiController.h"
#import "ASFriendModel.h"

@interface ASFriendsListViewController ()

@property (nonatomic, strong) AGApiController   *apiController;

@end

@implementation ASFriendsListViewController

objection_requires(@keypath(ASFriendsListViewController.new, apiController))

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    [self registerCellClass:[ASFriendTableViewCell class]
              forModelClass:[ASFriendModel class]];
    [[self.apiController getFriends] subscribeNext:^(id x) {
        [self.memoryStorage removeAllTableItems];
        [self.memoryStorage addItems:x];
        [self.tableView reloadData];
    }];
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

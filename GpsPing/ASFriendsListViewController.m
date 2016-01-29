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
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self registerCellClass:[ASFriendTableViewCell class]
              forModelClass:[ASFriendModel class]];
}

- (void)viewWillAppear:(BOOL)animated {
    [[self.apiController getFriends] subscribeNext:^(id x) {
        [self.memoryStorage removeAllTableItems];
        [self.memoryStorage addItems:x];
        [self.tableView reloadData];
    }];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ASFriendModel *friend = [self.memoryStorage itemAtIndexPath:indexPath];
        [[self.apiController removeFriendWithId:[NSString stringWithFormat:@"%@",friend.userId]] subscribeNext:^(id x) {
            [self.memoryStorage removeItem:friend];
        }];
    }
}

@end

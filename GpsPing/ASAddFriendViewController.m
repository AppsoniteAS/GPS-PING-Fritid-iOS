//
//  ASAddFriendTableViewController.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/27/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASAddFriendViewController.h"
#import "ASAddFriendTableViewCell.h"
#import "ASSearchBar.h"
#import "ASAddFriendViewModel.h"

@interface ASAddFriendViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) ASAddFriendViewModel     *viewModel;
@property (nonatomic, strong) ASSearchBar       *searchBar;
@end

@implementation ASAddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self->_viewModel = [[ASAddFriendViewModel alloc] init];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    
    self.searchBar = [[ASSearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;

//    [self.tableView setContentOffset:CGPointMake(0, 44) animated:YES];
    
    [RACObserve(self.viewModel, arrayUsers) subscribeNext:^(id x) {
        [self.tableView reloadData];
    }];
    
}

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.arrayUsers.count;
}

-(ASAddFriendTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ASAddFriendTableViewCell class])];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(ASAddFriendTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell updateWithModel:self.viewModel.arrayUsers[indexPath.row]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ASAddFriendTableViewCell *cell = (ASAddFriendTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.imageAdd.image = [UIImage imageNamed:@"friend_list_icon_not_confirmed"];
    [[self.viewModel addFriendAtIndexPath:indexPath] subscribeNext:^(id x) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.viewModel searchUsersWithQuery:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.viewModel searchUsersWithQuery:searchBar.text];
}

@end

//
//  ASFriendsListViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 26/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASFriendsListViewController.h"
#import "ASFriendTableViewCell.h"
#import "ASRequestTableViewCell.h"
#import "AGApiController.h"
#import "ASFriendModel.h"
#import "ASAddFriendModel.h"

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
    [self registerCellClass:[ASRequestTableViewCell class]
              forModelClass:[ASAddFriendModel class]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshListOfFriends];
}

#pragma mark - UITableView delegate
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[self.memoryStorage itemAtIndexPath:indexPath] isKindOfClass:[ASFriendModel class]]) {
            ASFriendModel *friend = [self.memoryStorage itemAtIndexPath:indexPath];
            [[self.apiController removeFriendWithId:[NSString stringWithFormat:@"%@",friend.userId]] subscribeNext:^(id x) {
                [self.memoryStorage removeItem:friend];
            }];
        } else {
            ASAddFriendModel *addFriend = [self.memoryStorage itemAtIndexPath:indexPath];
            [[self.apiController declineFriendshipWithFriendId:[NSString stringWithFormat:@"%@",addFriend.userId]] subscribeNext:^(id x) {
                [self.memoryStorage removeItem:addFriend];
            }];
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[ASRequestTableViewCell class]]) {
        ASAddFriendModel *addFriend = [self.memoryStorage itemAtIndexPath:indexPath];
        [[[self.apiController confirmFriendshipWithFriendId:[NSString stringWithFormat:@"%@",addFriend.userId]] deliverOnMainThread] subscribeNext:^(id x) {
            [self refreshListOfFriends];
        }];
    } else {
        ASFriendModel *friend = [self.memoryStorage itemAtIndexPath:indexPath];
        [self setFriend:friend ssSeeingTrackers:!friend.isSeeingTracker.boolValue];
    }
}

-(void)setFriend:(ASFriendModel*)friend ssSeeingTrackers:(BOOL)isSeeing {
    [[self.apiController setSeeingTracker:isSeeing friendId:friend.userId.stringValue] subscribeNext:^(id x) {
        friend.isSeeingTracker = @(isSeeing);
        [self.memoryStorage reloadItem:friend];
    }];
}

-(void)refreshListOfFriends{
    [[[self.apiController getFriends] doError:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    } ]subscribeNext:^(id x) {
        NSLog(@"completed refreshListOfFriends");
        [self.memoryStorage setItems:x forSectionIndex:0];
        [self.tableView reloadData];
    }];
}

@end

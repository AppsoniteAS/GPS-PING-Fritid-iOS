//
//  ASFriendTableViewCell.m
//  GpsPing
//
//  Created by Pavel Ivanov on 27/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASFriendTableViewCell.h"
#import "ASFriendModel.h"

@implementation ASFriendTableViewCell

-(void)updateWithModel:(id)model
{
    ASFriendModel *friendModel = model;
//    self.trackerModel = model;
    self.fullnameLabel.text = friendModel.displayName;
    self.usernameLabel.text = friendModel.userName;
    if (!friendModel.confirmationStatus.boolValue) {
        self.friendStatusImageView.image = [UIImage imageNamed:@"friend_list_icon_not_confirmed"];
    } else if (friendModel.isSeeingTracker.boolValue) {
        self.friendStatusImageView.image = [UIImage imageNamed:@"friend_list_icon_visible"];
    } else {
        self.friendStatusImageView.image = [UIImage imageNamed:@"friend_list_icon_invisible"];
    }
}

@end

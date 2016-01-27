//
//  ASFriendTableViewCell.h
//  GpsPing
//
//  Created by Pavel Ivanov on 27/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <DTTableViewManager/DTTableViewManager.h>

@interface ASFriendTableViewCell : DTTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *friendStatusImageView;
@property (nonatomic) IBOutlet UILabel *fullnameLabel;
@property (nonatomic) IBOutlet UILabel *usernameLabel;
@end

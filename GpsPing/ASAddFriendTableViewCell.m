//
//  ASAddFriendTableViewCell.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/28/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASAddFriendTableViewCell.h"

@implementation ASAddFriendTableViewCell

-(void)updateWithModel:(id)model {
    ASAddFriendModel *friendModel = model;
    self.labelFullname.text = friendModel.displayName;
    self.labelUsername.text = friendModel.userName;
    self.imageAdd.image = [self.imageAdd.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end

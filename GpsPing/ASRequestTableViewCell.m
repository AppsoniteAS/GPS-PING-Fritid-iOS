//
//  ASRequestTableViewCell.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/31/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASRequestTableViewCell.h"
#import "ASAddFriendModel.h"

@implementation ASRequestTableViewCell

-(void)updateWithModel:(id)model
{
    ASAddFriendModel *addFriendModel = model;
    self.labelFullname.text = addFriendModel.displayName;
    self.labelUsername.text = addFriendModel.userName;
    self.imageAdd.image = [self.imageAdd.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end

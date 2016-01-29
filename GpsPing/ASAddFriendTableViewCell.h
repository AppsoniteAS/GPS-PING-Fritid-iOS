//
//  ASAddFriendTableViewCell.h
//  GpsPing
//
//  Created by Maks Niagolov on 1/28/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASAddFriendModel.h"

@interface ASAddFriendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageAdd;
@property (nonatomic) IBOutlet UILabel *labelFullname;
@property (nonatomic) IBOutlet UILabel *labelUsername;

-(void)updateWithModel:(ASAddFriendModel*)model;

@end

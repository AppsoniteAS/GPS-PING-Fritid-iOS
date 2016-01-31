//
//  ASRequestTableViewCell.h
//  GpsPing
//
//  Created by Maks Niagolov on 1/31/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <DTTableViewManager/DTTableViewManager.h>

@interface ASRequestTableViewCell : DTTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageAdd;
@property (nonatomic) IBOutlet UILabel *labelFullname;
@property (nonatomic) IBOutlet UILabel *labelUsername;
@end

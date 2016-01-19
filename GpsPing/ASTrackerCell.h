//
//  ASTrackerCell.h
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <DTTableViewManager/DTTableViewManager.h>

@interface ASTrackerCell : DTTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackerNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *imeiNumbrLabel;
@property (weak, nonatomic) IBOutlet UIImageView *trackerImage;
@property (weak, nonatomic) IBOutlet UIImageView *chooseIndicator;

@end

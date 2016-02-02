//
//  ASTrackerCell.h
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <DTTableViewManager/DTTableViewManager.h>
#import "ASTrackerModel.h"

@class ASTrackerCell;

@protocol ASTrackerCellProtocol <NSObject>

-(void)trackerCell:(ASTrackerCell*)cell didTapShowOnMap:(BOOL)needToShow forModel:(ASTrackerModel*)model;

@end

@interface ASTrackerCell : DTTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackerNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *imeiNumbrLabel;
@property (weak, nonatomic) IBOutlet UIImageView *trackerImage;
@property (weak, nonatomic) IBOutlet UIImageView *chooseIndicator;
@property (weak, nonatomic) IBOutlet UIButton *showOnMapButton;
@property (weak, nonatomic) id<ASTrackerCellProtocol> delegate;

@property (nonatomic) ASTrackerModel *trackerModel;

@end

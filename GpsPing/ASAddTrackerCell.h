//
//  ASAddTrackerCell.h
//  GpsPing
//
//  Created by Юджин Топсекретович on 9/5/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ASAddTrackerCellProtocol <NSObject>

- (void) didSelectTracker: (NSString*) trackerName;

@end

@interface ASAddTrackerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnTracker;
@property (weak, nonatomic) id<ASAddTrackerCellProtocol> delegate;
- (void) handleBtTrackerName: (NSString*) trackerName;
- (IBAction)pressedBtnTracker:(UIButton *)sender;

@end

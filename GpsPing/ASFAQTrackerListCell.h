//
//  ASFAQTrackerListCell.h
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/5/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ASFAQTrackerListCellProtocol <NSObject>

- (void) didSelectTracker: (NSString*) trackerName;

@end
@interface ASFAQTrackerListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnTracker;
@property (weak, nonatomic) id<ASFAQTrackerListCellProtocol> delegate;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
- (void) handleBtTrackerName: (NSString*) trackerName forcedName: (NSString*) forcedName;
- (IBAction)pressedBtnTracker:(UIButton *)sender;
@end

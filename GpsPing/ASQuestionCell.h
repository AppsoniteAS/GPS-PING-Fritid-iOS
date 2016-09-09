//
//  ASQuestionCell.h
//  GpsPing
//
//  Created by Pavel Ivanov on 08/09/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DTTableViewManager/DTTableViewManager.h>

@interface ASQuestionCell : DTTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

+(CGFloat)heightOfCellForText:(NSString*)text;

@end

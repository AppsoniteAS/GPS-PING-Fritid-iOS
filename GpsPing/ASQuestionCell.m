//
//  ASQuestionCell.m
//  GpsPing
//
//  Created by Pavel Ivanov on 08/09/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASQuestionCell.h"

@interface ASQuestionCell ()

@end

@implementation ASQuestionCell
-(void)updateWithModel:(NSString*)model {
    self.titleLabel.text = model;

    UILabel *label = self.titleLabel;
    CGSize constraint = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
}

+(CGFloat)heightOfCellForText:(NSString*)text {
    CGFloat labelSizeWidth = [UIScreen mainScreen].bounds.size.width - 15 - 48;
    UIFont *font = [UIFont fontWithName:@"Roboto-Light" size:15.0];
    
    CGSize constraint = CGSizeMake(labelSizeWidth, CGFLOAT_MAX);
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [text boundingRectWithSize:constraint
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:font}
                                                  context:context].size;
    
    CGSize size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    CGFloat sumOfVerticalSpacesToAndFromLabel = 10.0;
    return size.height + sumOfVerticalSpacesToAndFromLabel + 1; // plus 1 for separator i guess
}

@end

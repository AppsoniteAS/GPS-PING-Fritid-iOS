//
//  ASSelectTracker.m
//  GpsPing
//
//  Created by Pavel Ivanov on 22/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASSelectTrackerViewController.h"
#import "ASTrackerCell.h"
#import "UIStoryboard+ASHelper.h"

@interface ASSelectTrackerViewController()

@end

@implementation ASSelectTrackerViewController

+(instancetype)initialize
{
	    return [[UIStoryboard mainMenuStoryboard] instantiateViewControllerWithIdentifier:NSStringFromClass([ASSelectTrackerViewController class])];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self registerCellClass:[ASTrackerCell class]
              forModelClass:[ASTrackerModel class]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.memoryStorage removeAllTableItems];
    [self.memoryStorage addItems:[ASTrackerModel getTrackersFromUserDefaults]];
    [self.tableView reloadData];
}

- (IBAction)backgroundViewTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASTrackerModel *tracker = [self.memoryStorage itemAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(selectTracker:trackerChoosed:)]) {
        [self.delegate selectTracker:self trackerChoosed:tracker];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view == self.view) {
        return YES;
    }
    return NO;
}



@end

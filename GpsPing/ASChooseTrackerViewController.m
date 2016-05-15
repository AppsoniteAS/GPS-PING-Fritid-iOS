//
//  ASChooseTrackerViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 20/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASChooseTrackerViewController.h"
#import "ASTrackerModel.h"
#import "ASTrackerConfigurationViewController.h"

@implementation ASChooseTrackerViewController

-(void)viewDidLayoutSubviews
{
    for (UIButton *button in self.buttons) {
        button.layer.cornerRadius = button.frame.size.width/2;
        button.layer.borderColor = [UIColor as_darkestBlueColor].CGColor;
        button.layer.borderWidth = 5.0f;
    }
}

- (IBAction)tkStarButtonTap:(id)sender {
    [self goToNextScreenWithChoosedType:kASTrackerTypeTkStar];
}
- (IBAction)anywhereButtonTap:(id)sender {
    [self goToNextScreenWithChoosedType:kASTrackerTypeAnywhere];
}
- (IBAction)tkPetButtonTap:(id)sender {
    [self goToNextScreenWithChoosedType:kASTrackerTypeTkStarPet];
}

-(void)goToNextScreenWithChoosedType:(NSString *)trackerType
{
    ASTrackerConfigurationViewController *configVC = [ASTrackerConfigurationViewController initialize];
    
    configVC.trackerObject = [ASTrackerModel initTrackerWithName:nil
                                                          number:nil
                                                            imei:nil
                                                            type:trackerType
                                                       isChoosed:NO
                                                       isRunning:NO];
    [self.navigationController pushViewController:configVC animated:YES];
}
- (IBAction)cancelButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

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

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    for (UIButton *button in self.buttons) {
        button.layer.cornerRadius = [UIScreen mainScreen].bounds.size.width * 500/3/414/2;
        button.layer.borderColor = [UIColor colorWithRed:0.4796 green:0.7302 blue:0.2274 alpha:1.0].CGColor;
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
    
    configVC.trackerObject = [ASTrackerModel initTrackerWithName:nil number:nil imei:nil type:trackerType isChoosed:NO];
    [self.navigationController pushViewController:configVC animated:YES];
}

@end

//
//  ASIntroViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 07/09/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASIntroViewController.h"
#import "ASUserProfileModel.h"
#import <FCOverlay/FCOverlay.h>

@interface ASIntroViewController ()

@end

@implementation ASIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kASUserDefaultsDidShowIntro];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)close:(id)sender {
    [FCOverlay dismissOverlayAnimated:YES completion:nil];
}

@end

//
//  ASHelpPopupViewController.m
//  GpsPing
//
//  Created by Sergey Belozerov on 30/08/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASHelpPopupViewController.h"
#import <FCOverlay/FCOverlay.h>

@interface ASHelpPopupViewController ()
@property (nonatomic, weak) IBOutlet UIView* viewShadow;
- (IBAction)closeController:(id)sender;

@end

@implementation ASHelpPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    self.view.backgroundColor = [UIColor clearColor];
}

-(void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
                     }];
}

-(void)viewWillDisappear:(BOOL)animated {
    self.view.backgroundColor = [UIColor clearColor];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeController:(id)sender {
    [FCOverlay dismissOverlayAnimated:YES completion:nil];
}
@end

//
//  ViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 18/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
- (IBAction)showAbout:(id)sender;

@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.startStopButton.layer.borderColor = [UIColor colorWithRed:0.4796 green:0.7302 blue:0.2274 alpha:1.0].CGColor;
    self.startStopButton.layer.borderWidth = 6.0;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    self.startStopButton.layer.cornerRadius = self.startStopButton.frame.size.width/2;
}

- (IBAction)showAbout:(id)sender {
    UIViewController* controller = [[UIStoryboard storyboardWithName:@"About" bundle:nil] instantiateInitialViewController];
    [self presentViewController:controller animated:YES completion:nil];
//    [self.navigationController pushViewController:controller animated:YES];
}
@end

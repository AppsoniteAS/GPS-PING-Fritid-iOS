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
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;
@property (weak, nonatomic) IBOutlet UIImageView *iv1;
@property (weak, nonatomic) IBOutlet UIImageView *iv2;
@property (weak, nonatomic) IBOutlet UIImageView *iv3;
@property (weak, nonatomic) IBOutlet UIImageView *iv4;
@property (weak, nonatomic) IBOutlet UIImageView *iv5;

@end

@implementation ASIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.iv1.image = [ UIImage imageNamed: NSLocalizedString( @"into_1", @"1en")] ;
    self.iv2.image = [ UIImage imageNamed: NSLocalizedString( @"into_2", @"2en")] ;
    self.iv3.image = [ UIImage imageNamed: NSLocalizedString( @"into_3", @"3en")] ;
    self.iv4.image = [ UIImage imageNamed: NSLocalizedString( @"into_4", @"4en")] ;
    self.iv5.image = [ UIImage imageNamed: NSLocalizedString( @"into_5", @"5en")] ;

    
    self.label1.hidden = true;
    self.label2.hidden = true;
    self.label3.hidden = true;
    self.label4.hidden = true;
    self.label5.hidden = true;

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

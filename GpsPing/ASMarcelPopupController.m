//
//  ASMarcelPopupController.m
//  GpsPing
//
//  Created by Eugene Yakubovich on 05/04/2018.
//  Copyright © 2018 Robin Grønvold. All rights reserved.
//

#import "ASMarcelPopupController.h"

@interface ASMarcelPopupController ()
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;

@end

@implementation ASMarcelPopupController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.label1.text = NSLocalizedString(@"marcel_popup_1", nil);
    self.label2.text = NSLocalizedString(@"marcel_popup_2", nil);
    // Do any additional setup after loading the view.
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

@end

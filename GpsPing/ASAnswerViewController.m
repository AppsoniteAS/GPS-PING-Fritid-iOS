//
//  ASAnswerViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 09/09/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASAnswerViewController.h"

@interface ASAnswerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;

@end

@implementation ASAnswerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.questionLabel.text = self.faqEntry.allKeys.firstObject;
    self.answerLabel.text = self.faqEntry.allValues.firstObject;
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

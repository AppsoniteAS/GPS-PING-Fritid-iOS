//
//  ASQuestionListTableViewController.m
//  GpsPing
//
//  Created by Pavel Ivanov on 08/09/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASQuestionListTableViewController.h"
#import "ASQuestionCell.h"
#import "ASAnswerViewController.h"
#import "UIStoryboard+ASHelper.h"
#import "ASTrackerModel.h"

@interface ASQuestionListTableViewController ()
@property (nonatomic, strong) NSArray *faq;
@end

@implementation ASQuestionListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    bool S1A9 =  [self.trackerType isEqualToString:kASTrackerTypeTkS1 ]  ||  [self.trackerType isEqualToString:kASTrackerTypeTkA9 ] ;
    
    self.faq = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource: S1A9 ? @"FAQ 6" : @"FAQ" ofType:@"plist"]];
    NSMutableArray *allQuestions = @[].mutableCopy;
    
    for (NSDictionary *qa in self.faq) {
        [allQuestions addObject:qa.allKeys.firstObject];
    }
    
    [self registerCellClass:[ASQuestionCell class] forModelClass:[NSString class]];
    [self.memoryStorage addItems:allQuestions];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *item = [self.memoryStorage itemAtIndexPath:indexPath];
    return [ASQuestionCell heightOfCellForText:item];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ASAnswerViewController *answerViewController = [[UIStoryboard faqStoryboard] instantiateViewControllerWithIdentifier:NSStringFromClass([ASAnswerViewController class])];
    answerViewController.faqEntry = [self.faq objectAtIndex:indexPath.row];
    [self showViewController:answerViewController sender:self];
}

@end

//
//  ASAddFriendViewModel.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/29/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASAddFriendViewModel.h"
#import "AGApiController.h"
#import "ASAddFriendModel.h"

#import <CocoaLumberjack.h>
static DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface ASAddFriendViewModel()
@property (nonatomic, strong) AGApiController   *apiController;
@end

@implementation ASAddFriendViewModel
objection_requires(@keypath(ASAddFriendViewModel.new, apiController))

- (instancetype)init {
    self = [super init];
    if (self) {
        [[JSObjection defaultInjector] injectDependencies:self];
    }
    return self;
}

- (void)searchUsersWithQuery:(NSString*)query {
    @weakify(self)
    [[self.apiController searchFriendWithQueryString:query] subscribeNext:^(NSArray* x) {
        @strongify(self)
        self.arrayUsers = x;
    }];
}

- (RACSignal*)addFriendAtIndexPath:(NSIndexPath *)indexPath {
    ASAddFriendModel* user = self.arrayUsers[indexPath.row];
    return [self.apiController addFriendWithId:[NSString stringWithFormat:@"%@",user.userId]];
}

@end

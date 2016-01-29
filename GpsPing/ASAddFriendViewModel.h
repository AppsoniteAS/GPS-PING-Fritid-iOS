//
//  ASAddFriendViewModel.h
//  GpsPing
//
//  Created by Maks Niagolov on 1/29/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
#import "ASAddFriendModel.h"

@interface ASAddFriendViewModel : NSObject

@property (nonatomic, strong) NSArray       *arrayUsers;

- (void)searchUsersWithQuery:(NSString*)query;
- (RACSignal*)addFriendAtIndexPath:(NSIndexPath *)indexPath;

@end

//
//  ASProfileViewModel.h
//  GpsPing
//
//  Created by Maks Niagolov on 1/21/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface ASProfileViewModel : NSObject

@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* fullName;
@property (strong, nonatomic) NSString* email;
@property (readonly, nonatomic) RACCommand* submit;

- (void)logOut;

@end

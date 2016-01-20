//
//  ASSignInViewModel.h
//  GpsPing
//
//  Created by Maks Niagolov on 1/20/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface ASSignInViewModel : NSObject
@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* password;
@property (readonly, nonatomic) RACCommand* submit;
@end

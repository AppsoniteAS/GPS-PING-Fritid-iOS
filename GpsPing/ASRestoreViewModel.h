//
//  ASResoreViewModel.h
//  GpsPing
//
//  Created by Eugene Yakubovich on 06/04/2018.
//  Copyright © 2018 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface ASRestoreViewModel : NSObject
@property (strong, nonatomic) NSString* email;

-(RACCommand *)restore ;
@end

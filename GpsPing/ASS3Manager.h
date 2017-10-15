//
//  ASS3Manager.h
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/15/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>
#import <CocoaLumberjack.h>
#import <ReactiveCocoa.h>
@import UIKit;

@interface ASS3Manager : NSObject
DECLARE_SINGLTON

- (RACSignal*) handleS3: (NSString*) imageName image: (UIImage*) image;
@end

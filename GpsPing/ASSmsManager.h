//
//  ASSmsManager.h
//  GpsPing
//
//  Created by Pavel Ivanov on 21/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "ASTrackerModel.h"

@interface UIViewController(ASSmsManager)

@property (nonatomic, strong) RACSubject *smsSendSignal;

-(RACSignal *)as_sendSMS:(NSString *)text ToRecipient:(NSString*)recipient;

@end

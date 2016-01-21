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

#import "ASTrackerModel.h"

@protocol ASSmsManagerProtocol <NSObject>

-(void)smsManagerMessageWasSentWithResult:(MessageComposeResult)result;

@end

@interface UIViewController (ASSmsManager)

-(void)as_sendSMS:(NSString *)text
        recipient:(NSString*)recipient;

@end

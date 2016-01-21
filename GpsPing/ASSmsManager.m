//
//  ASSmsManager.m
//  GpsPing
//
//  Created by Pavel Ivanov on 21/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASSmsManager.h"
#import <CocoaLumberjack.h>
static DDLogLevel ddLogLevel = DDLogLevelDebug;

@implementation UIViewController (ASSmsManager)

-(void)as_sendSMS:(NSString *)text
     recipient:(NSString*)recipient
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = text;
        controller.recipients = @[recipient];
        controller.messageComposeDelegate = self;
        controller.navigationBarHidden=YES;
        [self presentViewController:controller animated:NO completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    if ([self respondsToSelector:@selector(smsManagerMessageWasSentWithResult:)]) {
        NSObject <ASSmsManagerProtocol> *obj = (id)self;
        [obj smsManagerMessageWasSentWithResult:result];
    } else {
        DDLogWarn(@"messageWasSentWithResult: should be implemeted for sms callback");
    }

    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end

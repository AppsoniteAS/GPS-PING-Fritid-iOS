//
//  ASSmsManager.m
//  GpsPing
//
//  Created by Pavel Ivanov on 21/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASSmsManager.h"
#import <CocoaLumberjack.h>

static DDLogLevel ddLogLevel = DDLogLevelVerbose;

@implementation UIViewController (ASSmsManager)

-(void)as_sendSMS:(NSString *)text
     recipient:(NSString*)recipient
{
    DDLogVerbose(@"%s text: %@ recipient: %@", __PRETTY_FUNCTION__, text, recipient);
#if TARGET_OS_SIMULATOR
    NSObject <ASSmsManagerProtocol> *obj = (id)self;
    [obj smsManagerMessageWasSentWithResult:MessageComposeResultSent];
    [[[UIAlertView alloc] initWithTitle:@"SMS is not supported on simulator"
                                message:[NSString stringWithFormat:@"Attempt to send SMS with params: text = %@, recipient = %@", text, recipient]
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles: nil] show];
#else
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = text;
        controller.recipients = @[recipient];
        controller.messageComposeDelegate = (id)self;
        controller.navigationBarHidden=YES;
        [self presentViewController:controller animated:NO completion:nil];
    }
#endif
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    if ([self respondsToSelector:@selector(smsManagerMessageWasSentWithResult:)]) {
        if (result == MessageComposeResultSent) {
            NSObject <ASSmsManagerProtocol> *obj = (id)self;
            [obj smsManagerMessageWasSentWithResult:result];
        }
    } else {
        DDLogWarn(@"messageWasSentWithResult: should be implemeted for sms callback");
    }

    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end

//
//  ASSmsManager.m
//  GpsPing
//
//  Created by Pavel Ivanov on 21/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASSmsManager.h"
#import <CocoaLumberjack.h>
#import <Objection/Objection.h>

static DDLogLevel ddLogLevel = DDLogLevelVerbose;

@implementation UIViewController(ASSmsManager)

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
   
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MessageComposeResultSent || result == MessageComposeResultCancelled) {
            [self.smsSendSignal sendNext:@(result)];
            [self.smsSendSignal sendCompleted];
        } else if (result == MessageComposeResultFailed) {
            NSError *error = [[NSError alloc]initWithDomain:@"ASSmsManagerDomain" code:0 userInfo:nil];
            [self.smsSendSignal sendError:error];
        }

    }];
}

-(RACSignal *)as_sendSMS:(NSString *)text ToRecipient:(NSString*)recipient
{
    DDLogVerbose(@"%s text: %@ recipient: %@", __PRETTY_FUNCTION__, text, recipient);
#if TARGET_OS_SIMULATOR
    [[[UIAlertView alloc] initWithTitle:@"SMS is not supported on simulator"
                                message:[NSString stringWithFormat:@"Attempt to send SMS with params: text = %@, recipient = %@", text, recipient]
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles: nil] show];
    return [RACSignal return:@(MessageComposeResultSent)];
#else
    self.smsSendSignal = [RACSubject subject];
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = text;
        controller.recipients = @[recipient];
        controller.messageComposeDelegate = (id)self;
        controller.navigationBarHidden=YES;
        [self presentViewController:controller animated:YES completion:nil];
    }
    
    return self.smsSendSignal;
#endif
}

- (void)setSmsSendSignal:(id)object {
    objc_setAssociatedObject(self, @selector(smsSendSignal), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)smsSendSignal {
    return objc_getAssociatedObject(self, @selector(smsSendSignal));
}

@end

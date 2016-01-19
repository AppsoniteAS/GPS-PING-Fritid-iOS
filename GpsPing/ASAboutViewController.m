//
//  ASAboutViewController.m
//  GpsPing
//
//  Created by Maks Niagolov on 1/19/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "ASAboutViewController.h"
#import <MessageUI/MessageUI.h>

#import <CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface ASAboutViewController () <MFMailComposeViewControllerDelegate>
- (IBAction)showWebsite:(id)sender;
- (IBAction)contactUs:(id)sender;
- (IBAction)showAboutUs:(id)sender;

@end

@implementation ASAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (IBAction)showWebsite:(id)sender {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.google.com/"]];
}

- (IBAction)contactUs:(id)sender {
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"GPSPing"];
    [mc setMessageBody:@"" isHTML:YES];
    [mc setToRecipients:[NSArray arrayWithObject:@""]];
    [self presentViewController:mc animated:YES completion:nil];
}

- (IBAction)showAboutUs:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.google.com/"]];
}

# pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            DDLogDebug(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            DDLogDebug(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            DDLogDebug(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            DDLogDebug(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end

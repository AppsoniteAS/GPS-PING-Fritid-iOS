//
//  ASInAppPurchaseManager.h
//  GpsPing
//
//  Created by Maks Niagolov on 2/25/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ASInAppPurchaseDelegate <NSObject>
@required
-(void)openConnect;
@end

@interface ASInAppPurchaseManager : NSObject
@property (assign, nonatomic) BOOL areSubscribed;

@property (nonatomic, weak)  id <ASInAppPurchaseDelegate> delegate;
-(void)getSubscriptionPeriod;
- (void)subscribe;
- (void)restore;
@end

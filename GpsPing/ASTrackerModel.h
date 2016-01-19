//
//  ASTrackerModel.h
//  GpsPing
//
//  Created by Pavel Ivanov on 19/01/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef NS_ENUM(NSUInteger, trackerType) {
//    <#MyEnumValueA#>,
//    <#MyEnumValueB#>,
//    <#MyEnumValueC#>,
//};

@interface ASTrackerModel : NSObject

@property (nonatomic) NSString *trackerName;
@property (nonatomic) NSString *trackerNumber;
@property (nonatomic) NSString *imeiNumber;
@property (nonatomic) NSString *trackerType;
@property (nonatomic, assign) BOOL isChoosed;

@end

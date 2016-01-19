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

static NSString * const kASTrackerTypeTkStar      = @"trackerTkStar";
static NSString * const kASTrackerTypeTkStarPet   = @"trackerTkStarPet";
static NSString * const kASTrackerTypeAnywhere    = @"trackerAnywhere";


@interface ASTrackerModel : NSObject

@property (nonatomic) NSString *trackerName;
@property (nonatomic) NSString *trackerNumber;
@property (nonatomic) NSString *imeiNumber;
@property (nonatomic) NSString *trackerType;
@property (nonatomic, assign) BOOL isChoosed;

+(instancetype)initTrackerWithName:(NSString *)name
                            number:(NSString *)number
                              imei:(NSString *)imei
                              type:(NSString *)type
                         isChoosed:(BOOL)isChoosed;

@end

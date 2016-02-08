//
//  AGGeoValueTransformer.m
//  Taxi-Rhytm
//
//  Created by Pavel Ivanov on 06/07/15.
//  Copyright (c) 2015 Appgranula. All rights reserved.
//

#import "AGGeoValueTransformer.h"
#import <CoreLocation/CoreLocation.h>

@implementation AGGeoValueTransformer
+ (BOOL)allowsReverseTransformation {
    return NO;
}

+(Class)transformedValueClass {
    return [NSNumber class];
}

- (id)reverseTransformedValue:(id)value {
    return [self reverseTransformedValue:value success:nil error:nil];
}

- (id)reverseTransformedValue:(NSNumber *)value success:(BOOL *)success error:(NSError **)error {
    NSString *result = [NSString stringWithFormat:@"%@", value];
    return result;
}

-(id)transformedValue:(id)value {
    return [self transformedValue:value success:nil error:nil];
}

-(id)transformedValue:(id)value success:(BOOL *)success error:(NSError *__autoreleasing *)error {
    if (!value) return @(0);
    if ([value isKindOfClass:[NSString class]]) {
        return @(((NSString*)value).floatValue);
    } else if ([value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    
    return @(0);
}
@end

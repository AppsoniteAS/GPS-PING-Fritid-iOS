//
//  NSString+ASNameComponents.m
//  GpsPing
//
//  Created by Pavel Ivanov on 18/07/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import "NSString+ASNameComponents.h"

@implementation NSString (ASNameComponents)

-(NSString*)extractFirstName {
    NSArray *nameComponents = [self getNameComponents];
    if (nameComponents && nameComponents.count > 0) {
        return nameComponents[0];
    }
    
    return nil;
}

-(NSString*)extractLastName {
    NSArray *nameComponents = [self getNameComponents];
    if (nameComponents && nameComponents.count > 1) {
        return nameComponents[1];
    }
    
    return nil;
}

-(NSArray*)getNameComponents {
    NSString *trimmedFullName = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *subStrings = [trimmedFullName componentsSeparatedByString:@" "];
    return subStrings;
}

@end

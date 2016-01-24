//
//  RACSignal+BackendHelpers.m
//  Taxi Masani
//
//  Created by Андрей Лазарев on 07.09.15.
//  Copyright (c) 2015 APPGRANULA. All rights reserved.
//

#import <CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelDebug;

#import "RACSignal+BackendHelpers.h"

#import <Mantle.h>
#import <MTLJSONAdapter.h>
#import <ReactiveCocoa.h>
#import "Underscore.h"


@implementation RACSignal (BackendHelpers)
-(RACSignal*) unpackArrayOfClassInstances: (Class) class {
    return [self flattenMap:^RACStream *(NSArray* rawObjects) {
        NSError *error;
        NSArray *allCars = [MTLJSONAdapter modelsOfClass: class
                                           fromJSONArray: rawObjects
                                                   error: &error];
        
        if (error) {
            DDLogError(@"%@", error);
            return [RACSignal error:error];
        }
        
        return [RACSignal return:allCars];
    }];
}
-(RACSignal*) unpackObjectOfClass: (Class) class {
    return [self flattenMap:^RACStream *(NSDictionary* rawObject) {
        NSError *error;
        
        NSDictionary* filtered =
        Underscore.dict(rawObject).filterValues(Underscore.negate(Underscore.isNull)).unwrap;
        
        id object = [MTLJSONAdapter modelOfClass: class
                              fromJSONDictionary: filtered
                                           error: &error];
        
        if (error) {
            DDLogError(@"%@", error);
            return [RACSignal error:error];
        }
        
        return [RACSignal return:object];
    }];
}

-(RACSignal*) updateObject: (MTLModel*) object {
    return [[self unpackObjectOfClass:object.class] map:^id(MTLModel* incoming) {
        [object mergeValuesForKeysFromModel:incoming];
        return object;
    }];
}
@end

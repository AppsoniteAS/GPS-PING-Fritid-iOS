//
//  RACSignal+BackendHelpers.h
//  Taxi Masani
//
//  Created by Андрей Лазарев on 07.09.15.
//  Copyright (c) 2015 APPGRANULA. All rights reserved.
//

#import "RACSignal.h"

@class MTLModel;
@interface RACSignal (BackendHelpers)
-(RACSignal*) unpackArrayOfClassInstances: (Class) class;
-(RACSignal*) unpackObjectOfClass: (Class) class;
-(RACSignal*) updateObject: (MTLModel*) object;
@end

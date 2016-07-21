//
//  NSString+ASNameComponents.h
//  GpsPing
//
//  Created by Pavel Ivanov on 18/07/16.
//  Copyright © 2016 Robin Grønvold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ASNameComponents)
-(NSString*)extractFirstName;
-(NSString*)extractLastName;
-(NSArray*)getNameComponents;
@end

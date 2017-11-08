//
//  ASCashedTileOverlay.m
//  GpsPing
//
//  Created by Юджин Топсекретович on 11/8/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import "ASCashedTileOverlay.h"
#import "ESCache.h"

@interface ASCashedTileOverlay()

//@property NSCache *cache;
@end


@implementation ASCashedTileOverlay

- (void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData * _Nullable, NSError * _Nullable))result{

    
    if (!result)
    {
        return;
    }
    
    NSData *cachedData = [[ESCache sharedCache] objectForKey: [[self URLForTilePath:path] absoluteString]];
    if (cachedData)
    {
        NSLog(@"use cached");
        result(cachedData, nil);
    }
    else
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[self URLForTilePath:path]];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            [[ESCache sharedCache] setObject:data forKey:[[self URLForTilePath:path] absoluteString]];

            result(data, connectionError);
        }];
    }
    

}


@end

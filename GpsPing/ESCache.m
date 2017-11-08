// ESCache.m
//
// Copyright (c) 2013 Eugene Solodovnykov (http://idevblog.info/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ESCache.h"

NSString * ESCacheErrorDomain = @"ESCache";
static NSString * const kDefaultCacheName = @"0043-a8f9-c97d-6280-4348-5cb1-2e83-6b00";
static const char * kCacheQueueName = "info.idevblog.cache";

static inline NSString *URLEncodeString(NSString *string);

@implementation ESCache {
    NSCache *_cache;
    NSFileManager *_fileManager;
    NSString *_cachesPath;
    dispatch_queue_t _queue;
}
@synthesize inMemoryCache = _cache;

- (void)dealloc {
    dispatch_barrier_sync(_queue, ^{}); //wait till the queue will finish all tasks
#if !__has_feature(objc_arc)
    [_cache release];
    [_fileManager release];
    [_cachesPath release];

    dispatch_release(_queue);
    [super dealloc];
#endif
}

+ (instancetype)sharedCache {
    __strong static id sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithName:kDefaultCacheName error:NULL];
    });
    return sharedInstance;
}

- (instancetype)initWithName:(NSString *)name error:(NSError *__autoreleasing *)e {
    self = [super init];

    __autoreleasing NSError *error = nil;
    if (self) {
        _queue = dispatch_queue_create(kCacheQueueName, DISPATCH_QUEUE_CONCURRENT);
        _fileManager = [[NSFileManager alloc] init];
        _cache = [[NSCache alloc] init];

        [_cache setName:name];

        NSString *userCaches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        _cachesPath = [userCaches stringByAppendingPathComponent:URLEncodeString(name)];
#if !__has_feature(objc_arc)
        [_cachesPath retain];
#endif
        BOOL isDirectory = NO;
        if (![_fileManager fileExistsAtPath:_cachesPath isDirectory:&isDirectory]) {
            [_fileManager createDirectoryAtPath:_cachesPath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        else if (!isDirectory) {
            error = [NSError errorWithDomain:ESCacheErrorDomain code:ESCacheErrorDirectoryIsFile userInfo:@{}];
        }

        if (error) {
            if (e) {
                *e = error;
            }
#if !__has_feature(objc_arc)
            [self release];
#endif
            self = nil;
        }
    }

    return self;
}

- (NSString *)name {
    return [_cache name];
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
    if (key != nil) {
        if (!object && [self objectExistsForKey:key]) {
            [self removeObjectForKey:key];
        }
        else {
            if ([(id)object conformsToProtocol:@protocol(NSCoding)]) {
                dispatch_barrier_async(_queue, ^{
                    [_cache setObject:object forKey:key];
                    [NSKeyedArchiver archiveRootObject:object toFile:[self desiredPathForObjectForKey:key]];
                });
            }
        }
    }
}

- (BOOL)objectExistsForKey:(NSString *)key {
    __block BOOL objectExists = NO;
    if (key != nil) {
        dispatch_sync(_queue, ^{
            objectExists = [_cache objectForKey:key] != nil;
            if (!objectExists) {
                objectExists = [_fileManager fileExistsAtPath:[self desiredPathForObjectForKey:key]];
            }
        });
    }
    return objectExists;
}

- (id)objectForKey:(NSString *)key {
    __block id object = nil;
    if (key != nil) {
        dispatch_sync(_queue, ^{
            object = [_cache objectForKey:key];
#if !__has_feature(objc_arc)
            [object retain];
#endif
            if (!object) {
                object = [NSKeyedUnarchiver unarchiveObjectWithFile:[self desiredPathForObjectForKey:key]];
                if (object != nil) {
#if !__has_feature(objc_arc)
                    [object retain]; //this one is for autorelease before return
                    [object retain]; //this one is for autorelease in barrier's block
#endif
                    dispatch_barrier_async(_queue, ^{
                        [_cache setObject:object forKey:key];
#if !__has_feature(objc_arc)
                        [object release];
#endif
                    });
                }
            }
        });
    }
#if !__has_feature(objc_arc)
    [object autorelease];
#endif
    return object;
}

- (void)objectForKey:(NSString *)key withBlock:(void (^)(id object, BOOL fromMemory))block onQueue:(dispatch_queue_t)queue {
    if (key != nil) {
        dispatch_async(_queue, ^{
            BOOL fromMemory = YES;
            id object = [_cache objectForKey:key];
            if (!object) {
                fromMemory = NO;
                object = [NSKeyedUnarchiver unarchiveObjectWithFile:[self desiredPathForObjectForKey:key]];
                if (object != nil) {
                    dispatch_barrier_async(_queue, ^{
                        [_cache setObject:object forKey:key];
                    });
                }
            }
            dispatch_async(queue, ^{ block(object, fromMemory); });
        });
    }
}

- (void)removeObjectForKey:(NSString *)key {
    if (key != nil) {
        dispatch_barrier_async(_queue, ^{
            [_cache removeObjectForKey:key];
            [_fileManager removeItemAtPath:[self desiredPathForObjectForKey:key] error:NULL];
        });
    }
}

- (void)removeAllObjects {
    dispatch_barrier_async(_queue, ^{
        [_cache removeAllObjects];
        NSArray *files = [_fileManager contentsOfDirectoryAtPath:_cachesPath error:NULL];
        for (NSString *file in files) {
            [_fileManager removeItemAtPath:[_cachesPath stringByAppendingPathComponent:file] error:NULL];
        }
    });
}

- (void)clearMemory {
    dispatch_barrier_async(_queue, ^{
        [_cache removeAllObjects];
    });
}

- (NSString *)pathForObjectForKey:(NSString *)key {
    return [self objectExistsForKey:key] ? [self desiredPathForObjectForKey:key] : nil;
}

- (NSString *)desiredPathForObjectForKey:(NSString *)key {
    return [_cachesPath stringByAppendingPathComponent:URLEncodeString(key)];
}

@end

static inline NSString *URLEncodeString(NSString *string) {
#if __has_feature(objc_arc)
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)string,
                                                                                 NULL,
                                                                                 (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 kCFStringEncodingUTF8
                                                                                 );
#else
    return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                (CFStringRef)string,
                                                                NULL,
                                                                (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                kCFStringEncodingUTF8
                                                                ) autorelease];
#endif
}

// ESSecureCache.m
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

#import <CommonCrypto/CommonCrypto.h>
#import "ESSecureCache.h"

NSString * ESSecureCacheErrorDomain = @"ESSecureCache";
static NSString * const kDefaultCacheName = @"f2e9-2863-3332-854c-f981-e7aa-e59c-12ef";
static const char * kCacheQueueName = "info.idevblog.secure-cache";

#pragma mark -

static inline NSString *URLEncodeString(NSString *string);
static inline CCCryptorStatus AES128Run(CCOperation operation, NSData *inData, NSData *key, NSData *__autoreleasing *outData);

#pragma mark -

@interface ESSecureCache ()

@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) ESSecureCacheType type;

@end

@implementation ESSecureCache {
    NSMutableDictionary *_cache;
    NSData *_encryptionKey;
    NSString *_cachePath;
    dispatch_queue_t _queue;
}

- (void)dealloc {
    dispatch_barrier_sync(_queue, ^{}); //wait till the queue will finish all tasks
#if !__has_feature(objc_arc)
    [_name release];
    [_cache release];
    [_encryptionKey release];
    [_cachePath release];
    dispatch_release(_queue);

    [super dealloc];
#endif
}

+ (instancetype)sharedCache {
    __strong static id sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithName:kDefaultCacheName type:ESSecureCacheTypeFile error:NULL];
    });
    return sharedInstance;
}

- (void)setEncryptionKey:(NSData *)key {
    dispatch_barrier_sync(_queue, ^{
#if !__has_feature(objc_arc)
        [_encryptionKey release];
#endif
        _encryptionKey = [key copy];
    });
}

- (instancetype)initWithName:(NSString *)name type:(ESSecureCacheType)type error:(NSError *__autoreleasing *)error {
    self = [super init];

    if (self) {
        _queue = dispatch_queue_create(kCacheQueueName, DISPATCH_QUEUE_CONCURRENT);
        _cache = [[NSMutableDictionary alloc] init];
        self.name = name;
        self.type = type;

        switch (type) {
            case ESSecureCacheTypeFile: {
                NSString *userCaches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                _cachePath = [userCaches stringByAppendingPathComponent:URLEncodeString([self name])];
#if !__has_feature(objc_arc)
                [_cachePath retain];
#endif

                BOOL isDirectory = NO;
                if ([[NSFileManager defaultManager] fileExistsAtPath:_cachePath isDirectory:&isDirectory] && isDirectory) {
                    if (error != NULL) {
                        *error = [NSError errorWithDomain:ESSecureCacheErrorDomain code:ESSecureCacheErrorFileIsDirectory userInfo:@{}];
                    }
#if !__has_feature(objc_arc)
                    [self release];
#endif
                    self = nil;
                }
                break;
            }
            case ESSecureCacheTypeUserDefaults: {
#if !__has_feature(objc_arc)
                [_cachePath release];
#endif
                _cachePath = nil;
                break;
            }
        }
    }

    return self;
}

- (void)setObject:(id<NSCoding>)object forKey:(id<NSCopying, NSCoding>)key {
    if (key != nil && _encryptionKey != nil) {
        if (!object && [self objectExistsForKey:key]) {
            [self removeObjectForKey:key];
        }
        else {
            dispatch_barrier_async(_queue, ^{
                _cache[key] = object;
                [self saveCacheToPersistentStore:_cache];
            });
        }
    }
}

- (BOOL)objectExistsForKey:(id<NSCopying, NSCoding>)key {
    __block BOOL objectExists = NO;
    if (key != nil && _encryptionKey != nil) {
        dispatch_sync(_queue, ^{
            objectExists = _cache[key] != nil;
            if (!objectExists) {
                NSMutableDictionary *cache = [self cacheFromPersistentStore];
                objectExists = cache[key] != nil;
                dispatch_barrier_async(_queue, ^{
                    _cache = cache;
#if !__has_feature(objc_arc)
                    [_cache retain];
#endif
                });
            }
        });
    }
    return objectExists;
}

- (id)objectForKey:(id<NSCopying, NSCoding>)key {
    __block id object = nil;
    if (key != nil && _encryptionKey != nil) {
        dispatch_sync(_queue, ^{
            object = _cache[key];
#if !__has_feature(objc_arc)
            [object retain];
#endif
            if (!object) {
                NSMutableDictionary *cache = [self cacheFromPersistentStore];
                object = cache[key];
#if !__has_feature(objc_arc)
                [object retain];
#endif
                dispatch_barrier_async(_queue, ^{
                    _cache = cache;
#if !__has_feature(objc_arc)
                    [_cache retain];
#endif
                });
            }
        });
#if !__has_feature(objc_arc)
        [object autorelease];
#endif
    }
    return object;
}

- (void)removeObjectForKey:(id<NSCopying, NSCoding>)key {
    if (key != nil && _encryptionKey != nil) {
        dispatch_barrier_async(_queue, ^{
            NSMutableDictionary *cache = [self cacheFromPersistentStore];
            _cache = cache;
#if !__has_feature(objc_arc)
            [_cache retain];
#endif
            [_cache removeObjectForKey:key];
            [self saveCacheToPersistentStore:_cache];
        });
    }
}

- (void)removeAllObjects {
    if (_encryptionKey != nil) {
        dispatch_barrier_async(_queue, ^{
            [_cache removeAllObjects];
            [self saveCacheToPersistentStore:_cache];
        });
    }
}

- (void)clearMemory {
    dispatch_barrier_async(_queue, ^{
        [_cache removeAllObjects];
    });
}

- (NSMutableDictionary *)cacheFromPersistentStore {
    NSData *encryptedCacheData = nil;
    switch (self.type) {
        case ESSecureCacheTypeFile:
            if ([[NSFileManager defaultManager] fileExistsAtPath:_cachePath]) {
                encryptedCacheData = [NSData dataWithContentsOfFile:_cachePath];
            }
            break;
        case ESSecureCacheTypeUserDefaults:
            encryptedCacheData = [[NSUserDefaults standardUserDefaults] dataForKey:self.name];
            break;
    }

    NSData *cacheData = nil;
    AES128Run(kCCDecrypt, encryptedCacheData, _encryptionKey, &cacheData);

    NSMutableDictionary *cache = nil;
    if (cacheData != nil) {
        @try {
            cache = [NSKeyedUnarchiver unarchiveObjectWithData:cacheData];
            if (![cache isKindOfClass:[NSMutableDictionary class]]) {
                cache = nil;
            }
        }
        @catch (NSException *exception) {
            cache = nil;
        }
    }

    return cache != nil ? cache : [NSMutableDictionary dictionary];
}

- (void)saveCacheToPersistentStore:(NSMutableDictionary *)cache {
    NSData *cacheData = nil;
    AES128Run(kCCEncrypt, [NSKeyedArchiver archivedDataWithRootObject:cache], _encryptionKey, &cacheData);

    switch (self.type) {
        case ESSecureCacheTypeFile:
            [cacheData writeToFile:_cachePath atomically:YES];
            break;
        case ESSecureCacheTypeUserDefaults:
            [[NSUserDefaults standardUserDefaults] setObject:cacheData forKey:self.name];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
    }
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

static __attribute__((always_inline)) CCCryptorStatus AES128Run(CCOperation operation, NSData *inData, NSData *key, NSData *__autoreleasing *outData) {
    CCCryptorStatus status = kCCParamError;

    if (outData != NULL) {
        CCCryptorRef cryptor = NULL;

        //correct key length
        NSMutableData *correctedKey = [key mutableCopy];
        if ([key length] <= kCCKeySizeAES128) {
            [correctedKey setLength:kCCKeySizeAES128];
        }
        else if ([key length] <= kCCKeySizeAES192) {
            [correctedKey setLength:kCCKeySizeAES192];
        }
        else {
            [correctedKey setLength:kCCKeySizeAES256];
        }
#if !__has_feature(objc_arc)
        [correctedKey autorelease];
#endif
        
        status = CCCryptorCreate(operation, kCCAlgorithmAES128, kCCOptionPKCS7Padding, [correctedKey bytes], [correctedKey length], NULL, &cryptor);

        if (status == kCCSuccess) {
            size_t length = CCCryptorGetOutputLength(cryptor, [inData length], true);
            NSMutableData *result = [NSMutableData dataWithLength:length];
            size_t updateLength;
            status = CCCryptorUpdate(cryptor, [inData bytes], [inData length], [result mutableBytes], [result length], &updateLength);
            if (status == kCCSuccess) {
                char *finalDataPointer = (char *)[result mutableBytes] + updateLength;
                size_t remainingLength = [result length] - updateLength;
                size_t finalLength;
                status = CCCryptorFinal(cryptor, finalDataPointer, remainingLength, &finalLength);
                [result setLength:updateLength + finalLength];
            }
            *outData = status == kCCSuccess ? [NSData dataWithData:result] : nil;
        }

        CCCryptorRelease(cryptor);
    }

    return status;
}

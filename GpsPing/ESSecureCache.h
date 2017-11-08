// ESSecureCache.h
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

#import <Foundation/Foundation.h>

/*
 @header ESSecureCache.h

 @abstract An `NSMutableDictionary` wrapper backed by syphered on-disk persistentce. All read/write functions are designed using 'concurrent read, exclusive write' principle and (should be) thread-safe.
 */

/*
 @enum ESSecureCacheType
 
 @constant ESSecureCacheTypeFile Specifies file-backed cache
 @constant ESSecureCacheTypeUserDefaults Specifies NSUserDefaults-backed cache
 */

typedef enum {
    ESSecureCacheTypeFile,
    ESSecureCacheTypeUserDefaults,
} ESSecureCacheType;

/*
 @enum ESSecureCacheError Possible error codes.

 @constant ESSecureCacheErrorFileIsDirectory    Returned by `initWithName:type:error:` if the cache file already exists and it's a directory.
                                                This file is placed in /Library/Caches for your application and has a name which is taken from `initWithName:type:error:`.
 */
typedef enum {
    ESSecureCacheErrorFileIsDirectory = 1001
} ESSecureCacheError;

/*
 @constant ESSecureCacheErrorDomain Error domain
 */
extern NSString * ESSecureCacheErrorDomain;

@interface ESSecureCache : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) ESSecureCacheType type;

/*
 @abstract Shared instance. It uses 'default' name and file-backed persistence.

 @return Shared instance of ESSecureCache.
 */
+ (instancetype)sharedCache;
/*
 @abstract Designated initializer. This method should be used instead of [ESSecureCache init]

 @param name Used to name a file which is used to store cached values persistently or as a corresponding key in NSUserDefaults.
 @param type Specifies whether we need to persist cached data in a file or in NSUserDefaults.
 @param error WIll be assigned if something went wrong during initializing.

 @return An instance of ESSecureCache
 */
- (instancetype)initWithName:(NSString *)name type:(ESSecureCacheType)type error:(NSError *__autoreleasing *)error;

/*
 @abstract Sets encryption key which is used to encrypt/decrypt persistent data
 
 @param key
 */
- (void)setEncryptionKey:(NSData *)key;

/*
 @abstract Caches the object.

 @param object Object which is to be cached. It should conform to NSCoding protocol. Passing nil will delete corresponding object.
 @param key the key which should be used for the object above. Should conform to NSCopying and NSCoding protocols.
 */
- (void)setObject:(id<NSCoding>)object forKey:(id<NSCopying, NSCoding>)key;
/*
 @abstract Indicates whether object exists for the key or not.

 @param key The key of the object.

 @return Boolean indicating if an object is stored in the cache. Returns NO if persistent cache can not be decrypted.
 */
- (BOOL)objectExistsForKey:(id<NSCopying, NSCoding>)key;
/*
 @abstract Returns an object for the corresponding key.

 @param key The key of the object.

 @return An object or nil if the object is not in the cache or if persistent cache can not be decrypted.
 */
- (id)objectForKey:(id<NSCopying, NSCoding>)key;
/*
 @abstract Removes an object from the cache.

 @param key Object's key
 */
- (void)removeObjectForKey:(id<NSCopying, NSCoding>)key;
/*
 @abstract Removes all objects from the cache and persistent store.
 */
- (void)removeAllObjects;
/*
 @abstract Removes all objects from in-memory cache.
 */
- (void)clearMemory;

/*
 @discussion NSObject's init is not available.
 */
- (id)init __unavailable;

@end

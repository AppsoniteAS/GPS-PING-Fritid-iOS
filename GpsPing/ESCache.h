// ESCache.h
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
 @header ESCache.h
 
 @abstract Simple `NSCache` wrapper backed by on-disk persistentce. All read/write functions are designed using 'concurrent read, exclusive write' principle and (should be) thread-safe.
 */

/*
 @enum ESCacheError Possible error codes.
 
 @constant ESCacheErrorDirectoryIsFile Returned by `initWithName:error:` if the folder which we plan to use for persistence already exists and it's a file.
                                       This folder is placed in /Library/Caches for your application and has a name which is taken from `initWithName:error:`.
 */
typedef enum {
    ESCacheErrorDirectoryIsFile = 1001
} ESCacheError;

/*
 @constant ESCacheErrorDomain Error domain
 */
extern NSString * ESCacheErrorDomain;

@interface ESCache : NSObject
@property (nonatomic, readonly) NSCache *inMemoryCache;

/*
 @abstract Shared instance. It uses 'default' name.
 
 @return Shared instance of ESCache.
 */
+ (instancetype)sharedCache;
/*
 @abstract Designated initializer. This method should be used instead of [ESCache init]

 @param name Used to name internal NSCache instance and to name a folder which is used to store cached values persistently.
 @param error WIll be assigned if something went wrong during initializing.
 
 @return An instance of ESCache
 */
- (instancetype)initWithName:(NSString *)name error:(NSError *__autoreleasing *)error;

/*
 @abstract Instance's name.
 */
- (NSString *)name;

/*
 @abstract Caches the object.
 
 @param object Object which is to be cached. It should conform to NSCoding protocol. Passing nil will delete corresponding object.
 @param key the key which should be used for the object above.
 */
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key;
/*
 @abstract Indicates whether object exists for the key or not.
 
 @param key The key of the object.

 @return Boolean indicating if an object is stored in the cache.
 */
- (BOOL)objectExistsForKey:(NSString *)key;
/*
 @abstract Returns an object for the corresponding key.
 
 @param key The key of the object.

 @return An object or nil if the object is not in the cache
 */
- (id)objectForKey:(NSString *)key;

/*
 @abstract Returns an object for the corresponding key using an async block.
 
 @param key The key of the object.
 @param block Block to execute with the accessed object.
 @param queue the operation queue for the block.
 */
- (void)objectForKey:(NSString *)key withBlock:(void (^)(id object, BOOL fromMemory))block onQueue:(dispatch_queue_t)queue;
/*
 @abstract Removes an object from the cache.
 
 @param key Object's key
 */
- (void)removeObjectForKey:(NSString *)key;
/*
 @abstract Removes all objects from the cache and persistent store.
 */
- (void)removeAllObjects;
/*
 @abstract Removes all objects from in-memory cache.
 */
- (void)clearMemory;

/*
 @abstract Returnes object's file path.
 
 @return Path if object exists, nil otherwise.

 @exception ESCacheKeyIsNilException will be raised if the key provided is nil.
 */
- (NSString *)pathForObjectForKey:(NSString *)key;

/*
 @discussion NSObject's init is not available.
 */
- (id)init __unavailable;

@end

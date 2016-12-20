//
//  XZAPIHelper.h
//  XZURLCacheDemo
//
//  Created by codeLocker on 2016/12/19.
//  Copyright © 2016年 codeLocker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZAPIHelper : NSObject


/**
 默认缓存(内存4M 硬盘20M)
 */
+ (void)setDefaultCapacity;

/**
 设置内存缓存与硬盘缓存大小

 @param memoryCapacity 内存缓存
 @param diskCapacity 硬盘缓存
 */
+ (void)setMaxMemoryCapacity:(NSUInteger)memoryCapacity maxDiskCapacity:(NSUInteger)diskCapacity;


/**
 获取缓存大小

 @return 缓存大小
 */
+ (NSUInteger)getCacheCapacity;


/**
 清除指定请求的缓存

 @param request 请求
 */
+ (void)removeCacheForRequest:(NSURLRequest *)request;


/**
 清除所有缓存
 */
+ (void)removeAllCache;


/**
 清除指定时间之前的缓存

 @param date 截止时间
 */
+ (void)removeCacheSinceDate:(NSDate *)date;


/**
 get 请求

 @param url 请求URL
 @param params 请求参数
 @param timeoutInterval 超时时间
 @param cachePolicy 缓存策略
 @param completion 请求完成回调
 @param errorHandle 请求错误回调
 */
+ (void)getUrl:(NSString *)url params:(NSDictionary *)params timeoutInterval:(NSTimeInterval)timeoutInterval cachePolicy:(NSURLRequestCachePolicy)cachePolicy completion:(void (^)(NSData *data, NSURLResponse *response))completion error:(void (^)(NSError *error))errorHandle;

/**
 post 请求
 
 @param url 请求URL
 @param params 请求参数
 @param timeoutInterval 超时时间
 @param cachePolicy 缓存策略
 @param completion 请求完成回调
 @param error 请求错误回调
 */
+ (void)postUrl:(NSString *)url params:(NSDictionary *)params timeoutInterval:(NSTimeInterval)timeoutInterval cachePolicy:(NSURLRequestCachePolicy)cachePolicy completion:(void (^)(NSData *data, NSURLResponse *response))completion error:(void (^)(NSError *error))errorHandle;
@end

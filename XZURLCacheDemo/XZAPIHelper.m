//
//  XZAPIHelper.m
//  XZURLCacheDemo
//
//  Created by codeLocker on 2016/12/19.
//  Copyright © 2016年 codeLocker. All rights reserved.
//

#import "XZAPIHelper.h"
#import "XZAPITool.h"

@implementation XZAPIHelper

+ (void)setDefaultCapacity{

    [self setMaxMemoryCapacity:4 maxDiskCapacity:20];
}

+ (void)setMaxMemoryCapacity:(NSUInteger)memoryCapacity maxDiskCapacity:(NSUInteger)diskCapacity{

    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:memoryCapacity*1024*1024 diskCapacity:20*1024*1024 diskPath:nil];
    [NSURLCache setSharedURLCache:cache];
}

+ (NSUInteger)getCacheCapacity{
    
    return [NSURLCache sharedURLCache].currentDiskUsage;
}

+ (void)removeAllCache{

    @synchronized ([NSURLCache sharedURLCache]) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }
}

+ (void)removeCacheSinceDate:(NSDate *)date{

    @synchronized ([NSURLCache sharedURLCache]) {
        [[NSURLCache sharedURLCache] removeCachedResponsesSinceDate:date];
    }
}

+ (void)removeCacheForRequest:(NSURLRequest *)request{

    @synchronized ([NSURLCache sharedURLCache]) {
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    }
}

+ (void)getUrl:(NSString *)url params:(NSDictionary *)params timeoutInterval:(NSTimeInterval)timeoutInterval cachePolicy:(NSURLRequestCachePolicy)cachePolicy completion:(void (^)(NSData *, NSURLResponse *))completion error:(void (^)(NSError *))errorHandle{

    NSMutableURLRequest *request = requestWithURL(url, nil, params, timeoutInterval, YES, cachePolicy);
    
    if (!request || [request isEqual:[NSNull null]]) {
        
        errorHandle(nil);
        return;
    }

    NSCachedURLResponse *response = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    if (response) {
        
        NSLog(@"存在缓存");
    }else{
    
        NSLog(@"没有缓存");
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
                                            if (error) {
                                                errorHandle(error);
                                                return ;
                                            }
                                            
                                            completion(data,response);
    }];
    
    [task resume];
}

+ (void)postUrl:(NSString *)url params:(NSDictionary *)params timeoutInterval:(NSTimeInterval)timeoutInterval cachePolicy:(NSURLRequestCachePolicy)cachePolicy completion:(void (^)(NSData *, NSURLResponse *))completion error:(void (^)(NSError *))errorHandle{

    NSMutableURLRequest *request = requestWithURL(url, @"POST", params, timeoutInterval, YES, cachePolicy);
    
    if (!request || [request isEqual:[NSNull null]]) {
        
        errorHandle(nil);
        return;
    }
    
    //POST请求不能使用缓存
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                            
                                            if (error) {
                                                errorHandle(error);
                                                return ;
                                            }
                                            
                                            completion(data,response);
                                        }];
    
    [task resume];
}

@end

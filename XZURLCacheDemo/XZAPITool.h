//
//  XZAPITool.h
//  XZURLCacheDemo
//
//  Created by codeLocker on 2016/12/19.
//  Copyright © 2016年 codeLocker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZAPITool : NSObject

@end

/**
 获取request
 
 @param urlStr 请求URL
 @param method 请求方法
 @param params 请求参数
 @param timeout 超时时间
 @param encoding 是否编码
 @param cachePolicy 缓存方式
 @return request
 */
NSMutableURLRequest *requestWithURL(NSString *urlStr, NSString *method, id params, NSTimeInterval timeout, BOOL encoding, NSURLRequestCachePolicy cachePolicy);


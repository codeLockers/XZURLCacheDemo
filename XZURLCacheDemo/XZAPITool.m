//
//  XZAPITool.m
//  XZURLCacheDemo
//
//  Created by codeLocker on 2016/12/19.
//  Copyright © 2016年 codeLocker. All rights reserved.
//

#import "XZAPITool.h"
#pragma mark - XZQueryStringComponent

NSString * urlEncodedStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding){

    return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

@interface XZQueryStringComponent : NSObject
@property (nonatomic, strong) id key;
@property (nonatomic, strong) id value;

- (id)initWithKey:(id)key value:(id)value;
- (NSString *)urlEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;
@end

@implementation XZQueryStringComponent

- (id)initWithKey:(id)key value:(id)value{

    self = [super init];
    if (self) {
        
        self.key = key;
        self.value = key;
    }
    return self;
}


- (NSString *)urlEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding{

    return [NSString stringWithFormat:@"%@=%@",self.key, urlEncodedStringFromStringWithEncoding([self.value description],stringEncoding)];
}
@end

#pragma mark - XZAPITool
@implementation XZAPITool

@end

NSArray * XZQueryStringComponentFromKeyAndValue(NSString *key, id value);
NSArray * XZQueryStringComponentFromKeyAndDictionaryValue(NSString *key, NSDictionary* value);
NSArray * XZQueryStringComponentFromKeyAndArrayValue(NSString *key, NSArray* value);
NSString * XZQueryStringFromParamsWithEncoding(NSDictionary *params, NSStringEncoding stringEncoding);


/**
 将接口请求的字典参数转换成编码后的字符串

 @param params 需要转变的字典
 @param stringEncoding 编码方式
 @return 编码后侧参数字符串
 */
NSString * XZQueryStringFromParamsWithEncoding(NSDictionary *params, NSStringEncoding stringEncoding){

    NSMutableArray *array = [NSMutableArray array];
    
    for (XZQueryStringComponent *component in XZQueryStringComponentFromKeyAndValue(nil, params)) {
        
        [array addObject:[component urlEncodedStringValueWithEncoding:stringEncoding]];
    }
    
    return [array componentsJoinedByString:@"&"];
}


/**
 将接口请求的参数(原始类型是字典或者数组)中的每一元素拆成XZQueryStringComponent对象

 @param key 键
 @param value 值
 @return XZQueryStringComponent对象数组
 */
NSArray * XZQueryStringComponentFromKeyAndValue(NSString *key, id value){

    NSMutableArray *array = [NSMutableArray array];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        
        [array addObjectsFromArray:XZQueryStringComponentFromKeyAndDictionaryValue(key,value)];
        
    }else if ([value isKindOfClass:[NSArray class]]){
        
        [array addObjectsFromArray:XZQueryStringComponentFromKeyAndArrayValue(key,value)];
    }else{
    
        [array addObject:[[XZQueryStringComponent alloc] initWithKey:key value:value]];
    }
    return array;
}


/**
 如果原始参数是字典类型

 @param key 键
 @param value 值
 @return XZQueryStringComponent对象数组
 */
NSArray * XZQueryStringComponentFromKeyAndDictionaryValue(NSString *key, NSDictionary* value){

    NSMutableArray *array = [NSMutableArray array];
    
    [value enumerateKeysAndObjectsUsingBlock:^(NSString *nestedKey, id nestedValue, BOOL * stop) {
        
        NSString *tmpKey = key ? [NSString stringWithFormat:@"%@[%@]",key,nestedKey] : nestedKey;
        
        [array addObjectsFromArray:XZQueryStringComponentFromKeyAndValue(tmpKey,nestedValue)];
    }];
    
    return array;
}

/**
 如果原始参数是数组类型
 
 @param key 键
 @param value 值
 @return XZQueryStringComponent对象数组
 */
NSArray * XZQueryStringComponentFromKeyAndArrayValue(NSString *key, NSArray* value){
    
    NSMutableArray *array = [NSMutableArray array];
    
    [value enumerateObjectsUsingBlock:^(id nestedValue, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [array addObjectsFromArray:XZQueryStringComponentFromKeyAndValue([NSString stringWithFormat:@"%@[]",key],nestedValue)];
    }];
    return array;
}



NSMutableURLRequest *requestWithURL(NSString *urlStr, NSString *method, id params, NSTimeInterval timeout, BOOL encoding, NSURLRequestCachePolicy cachePolicy){

    
    if (urlStr == nil || [urlStr isEqual:[NSNull null]] || [urlStr rangeOfString:@"http"].location == NSNotFound) {
        return nil;
    }
    
    method = !method ? @"GET" : [method uppercaseString];
    
    if (encoding) {
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (!url) {
        return nil;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:cachePolicy timeoutInterval:timeout];
    [request setHTTPMethod:method];
    //用户代理 告诉服务器客户端的平台系统等信息
    [request setValue:@"XZ App" forHTTPHeaderField:@"User-Agent"];
    
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        
        if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"] || [method isEqualToString:@"DELETE"]) {
            
            if ([urlStr rangeOfString:@"?"].location == NSNotFound) {
                
                urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"?%@",XZQueryStringFromParamsWithEncoding(params, NSUTF8StringEncoding)]];

            }else{
                
                urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"%@",XZQueryStringFromParamsWithEncoding(params, NSUTF8StringEncoding)]];
            }
            url = [NSURL URLWithString:urlStr];
            [request setURL:url];
        }
        else{
        
            NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            if(![request valueForHTTPHeaderField:@"Content-Type"]){
                [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
            }
            
            [request setHTTPBody:[XZQueryStringFromParamsWithEncoding(params, NSUTF8StringEncoding) dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
    }
    return request;
}


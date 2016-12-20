//
//  XZURLCache.m
//  XZURLCacheDemo
//
//  Created by codeLocker on 2016/12/20.
//  Copyright © 2016年 codeLocker. All rights reserved.
//

#import "XZURLCache.h"
#import <CommonCrypto/CommonDigest.h>

static NSString *const UrlCacheFolder = @"URLCache";


@interface XZURLCache()
/** 磁盘路径*/
@property (nonatomic, strong) NSString *diskPath;
/** 文件管理*/
@property (nonatomic, strong) NSFileManager *fileManager;
/** response的其他信息如时、MIMETYPE*/
@property (nonatomic, strong) NSMutableDictionary *responseInfoDic;


@end

@implementation XZURLCache

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path{

    self = [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path];
    if (self) {
        
        self.diskPath =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        self.responseInfoDic = [[NSMutableDictionary alloc] init];
        
        NSLog(@"%@",self.diskPath);
    }
    return self;
}



//只有GET请求能够缓存
- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request{

    NSLog(@" ==== %@",request.HTTPMethod);
    
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        
        return [super cachedResponseForRequest:request];
    }else{
    
        return [self xzcacheResponseDataFromRequest:request];
        
    }
}

//生成路径
- (NSString *)cacheFilePath:(NSString *)fileName{

    NSString *path = [NSString stringWithFormat:@"%@/%@",self.diskPath,UrlCacheFolder];
    
    BOOL isDir;
    if ([self.fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        
        
    }else{
    
        [self.fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [path stringByAppendingPathComponent:fileName];
}

- (NSCachedURLResponse *)xzcacheResponseDataFromRequest:(NSURLRequest *)request{

    NSString *url = request.URL.absoluteString;
//    NSLog(@"URL = %@",url);
    
    NSString *fileName = [self md5Hash:url];
    NSString *otherInfoFileName = [self md5Hash:[NSString stringWithFormat:@"%@-otherInfo",url]];
    //缓存文件
    NSString *filePath = [self cacheFilePath:fileName];
    //缓存文件信息
    NSString *otherInfoPath = [self cacheFilePath:otherInfoFileName];
    
//    NSLog(@"%@",filePath);
//    NSLog(@"%@",otherInfoPath);
    
    //如果请求的URL的缓存文件存在并且未过期就返回缓存
    if ([self.fileManager fileExistsAtPath:filePath]) {
        
//        NSLog(@"============= 有缓存 =============");
        
        NSDictionary *otherInfo = [[NSDictionary alloc] initWithContentsOfFile:otherInfoPath];
        NSData *cacheData = [NSData dataWithContentsOfFile:filePath];
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:[otherInfo objectForKey:@"MIMEType"] expectedContentLength:cacheData.length textEncodingName:[otherInfo objectForKey:@"textEncodingName"]];
        
        NSCachedURLResponse *cacheURLResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:cacheData];
        
        return cacheURLResponse;
    }
    
//    NSLog(@"============= 没有缓存 =============");
    __block NSCachedURLResponse *cacheResponse = nil;
    
    
    if (![self.responseInfoDic objectForKey:fileName]) {
        
        [self.responseInfoDic setValue:[NSNumber numberWithBool:YES] forKey:fileName];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                
                                                if (error) {
                                                    cacheResponse = nil;
                                                }
                                                
                                                if (response && data) {
                                                    
                                                    [self.responseInfoDic removeObjectForKey:fileName];
                                                    
                                                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]], @"time",response.MIMEType,@"MIMEType",response.textEncodingName,@"textEncodingName" ,nil];
                                                    
                                                    [dict writeToFile:otherInfoPath atomically:YES];
                                                    
                                                    [data writeToFile:filePath atomically:YES];
                                                    cacheResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
                                                }
                                            }];
        
        [task resume];
        
        return cacheResponse;
    }
    
    return nil;
    
}

#pragma mark -
- (NSString *)md5Hash:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (int)strlen(cStr), result );
    NSString *md5Result = [NSString stringWithFormat:
                           @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return md5Result;
}

#pragma mark - Setter && Getter
- (NSFileManager *)fileManager{

    if (!_fileManager) {
        
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}
@end

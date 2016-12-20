//
//  ViewController.m
//  XZURLCacheDemo
//
//  Created by codeLocker on 2016/12/19.
//  Copyright © 2016年 codeLocker. All rights reserved.
//

#import "ViewController.h"
#import "XZAPIHelper.h"

#define URL @"http://gc.ditu.aliyun.com/geocoding"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *locationLab;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
     [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action_Methods
- (IBAction)getBtn_Pressed:(id)sender {
    
    [XZAPIHelper getUrl:URL params:@{@"a":@"北京市"} timeoutInterval:5 cachePolicy:NSURLRequestReturnCacheDataElseLoad completion:^(NSData *data, NSURLResponse *response) {
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSLog(@"请求结果 dic %@",dic);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.locationLab.text = [NSString stringWithFormat:@"%@",dic[@"lat"]];
        });
        
        
        
    } error:^(NSError *error) {
        
    }];
}

- (IBAction)postBtn_Pressed:(id)sender {
    
    [XZAPIHelper postUrl:URL params:@{@"a":@"北京市"} timeoutInterval:5 cachePolicy:NSURLRequestReturnCacheDataElseLoad completion:^(NSData *data, NSURLResponse *response) {
        
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSLog(@"请求结果 dic %@",dic);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.locationLab.text = [NSString stringWithFormat:@"%@",dic[@"lat"]];
        });

    } error:^(NSError *error) {
        
    }];
}

- (IBAction)clearBtn_Pressed:(id)sender {
}

@end

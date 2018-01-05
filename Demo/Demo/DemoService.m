//
//  DemoService.m
//  Demo
//
//  Created by deguang.mo on 2018/1/5.
//  Copyright © 2018年 deguang.mo. All rights reserved.
//

#import "DemoService.h"
@import TYNetworking;
@implementation DemoService
/**
 测试方法
 */
+ (void)testConnect {
    NSString *url = @"http://localhost:3000/users/downloads/";
    NSDictionary *parameters = @{
                                 @"para1key":@"para1value",
                                 @"para2key":@[@"1",@(2),@(YES),@(NO),@(3.1415926)],
                                 @"numberKey":@(2),
                                 @"boolKeyYES":@(YES),
                                 @"boolKeyNO":@(NO),
                                 @"boolKeyFloat":@(3.1415926)
                                 };
    /*以文件数据创建上传对象*/
    NSData *fileData = [@"I AM A FILE." dataUsingEncoding:NSUTF8StringEncoding];
    TYUploadFile *uploadFile1 = [[TYUploadFile alloc] initWithFileData:fileData name:@"NAME" fileName:@"FILENAME" mimeType:nil];
    
    /*以文件路径创建上传对象*/
    NSURL *fileUrl;
    {
        //在沙盒上生成一个文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"uploadTest.txt"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) {
            NSMutableString *fileText = [NSMutableString string];
            for (int i=0; i < 1024*1024; i++) {
                [fileText appendString:@"1"];
            }
            [[fileText dataUsingEncoding:NSUTF8StringEncoding] writeToFile:filePath atomically:YES];
        }
        fileUrl = [NSURL fileURLWithPath:filePath];
    }
    TYUploadFile *uploadFile2 = [[TYUploadFile alloc] initWithFileURL:fileUrl name:@"NAME2"];
    NSArray *files = nil;
    files = @[uploadFile1,uploadFile2];
    [[TFSessionTask defalutTask] request:url isPost:YES parameters:parameters files:files isDownload:YES uploadProgress:^(NSProgress * _Nonnull progress) {
        NSLog(@"%@,uploadProgress",url);
    } downloadProgress:^(NSProgress * _Nonnull progress) {
        NSLog(@"%@,downloadProgress",url);
    } completionHandler:^(id _Nullable object,NSError *_Nullable error) {
        NSLog(@"%@,completionHandler",url);
        NSLog(@"completionHandler");
    }];
    
    //    [[TFSessionTask defalutTask] Post:url parameters:nil completionHandler:^(id _Nullable object, NSError * _Nullable error) {
    //        NSLog(@"completionHandler");
    //    }];
    
}
@end

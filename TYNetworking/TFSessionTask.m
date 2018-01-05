//
//  TYNetworking.m
//  frame
//
//  Created by deguang.mo on 2018/1/5.
//  Copyright © 2018年 deguang.mo. All rights reserved.
//

#import "TFSessionTask.h"
@interface SessionDelegate:NSObject<NSURLSessionDelegate>

@property(nonatomic,retain) NSMutableArray<TFSessionTask *> *serviceList;

@end

@interface TFSessionTask()
@property (nonatomic, copy) void (^uploadProgressBlock)(NSProgress * _Nonnull);
@property (nonatomic, copy) void (^downloadProgressBlock)(NSProgress * _Nonnull);
@property (nonatomic, copy) void (^requestCompletionBlock) (id _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
@property (nonatomic, retain) NSProgress *uploadProgress;
@property (nonatomic, retain) NSProgress *downloadProgress;
@property (nonatomic, retain) NSURLSessionTask *dataTask;
@property (nonatomic, retain) NSMutableData *receiveData;

- (void)URLSession:(__unused NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error;

- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data;

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location;
@end

#pragma mark - NSURLSessionDelegate
@implementation SessionDelegate
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.serviceList = [NSMutableArray array];
    }
    return self;
}
- (TFSessionTask *)getServiceWithTask:(NSURLSessionTask *)task {
    for (TFSessionTask *service in self.serviceList) {
        NSURLSessionTask *dataTask = service.dataTask;
        if (dataTask.taskIdentifier ==  task.taskIdentifier) {
            return service;
        }
    }
    return nil;
}

//NSURLSessionDelegate
- (void)URLSession:(__unused NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    TFSessionTask *service = [self getServiceWithTask:task];
    [service URLSession:session task:task didCompleteWithError:error];
}

- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    TFSessionTask *service = [self getServiceWithTask:dataTask];
    [service URLSession:session dataTask:dataTask didReceiveData:data];
}
//NSURLSessionDownloadTaskDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    TFSessionTask *service = [self getServiceWithTask:downloadTask];
    [service URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
}
@end

@implementation TFSessionTask

#pragma mark - session init
static NSURLSession *__session;
static SessionDelegate *__sessionDelegate;

+ (NSURLSession *)getDefalutSession {
    if (__session == nil) {
        __sessionDelegate = [[SessionDelegate alloc] init];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        __session = [NSURLSession sessionWithConfiguration:configuration delegate:__sessionDelegate delegateQueue:nil];
    }
    return __session;
}

+ (TFSessionTask *)defalutTask {
    TFSessionTask *service = [[TFSessionTask alloc] init];
    return service;
}
#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timeout = 10.0;
        self.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        self.uploadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        self.uploadProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
        
        self.downloadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
        self.downloadProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@" dealloc");
}


#pragma mark - request progress&result handle
- (void)addProgressListenner {
    if (self.dataTask != nil) {
        //监听上传进度
        [self.dataTask addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(countOfBytesSent))
                           options:NSKeyValueObservingOptionNew
                           context:NULL];
        [self.dataTask addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToSend))
                           options:NSKeyValueObservingOptionNew
                           context:NULL];
        
        [self.dataTask addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))
                           options:NSKeyValueObservingOptionNew
                           context:NULL];
        [self.dataTask addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))
                           options:NSKeyValueObservingOptionNew
                           context:NULL];
        
    }
    if (self.uploadProgress != nil) {
        [self.uploadProgress addObserver:self
                              forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                                 options:NSKeyValueObservingOptionNew
                                 context:NULL];
    }
    if (self.downloadProgress != nil) {
        [self.downloadProgress addObserver:self
                                forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                                   options:NSKeyValueObservingOptionNew
                                   context:NULL];
    }
}
- (void)removeProgressListenner {
    if (self.dataTask != nil) {
        [self.dataTask removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(countOfBytesSent))];
        [self.dataTask removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToSend))];
        [self.dataTask removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))];
        [self.dataTask removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))];
        
    }
    if (self.uploadProgress != nil) {
        [self.uploadProgress removeObserver:self
                                 forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    }
    if (self.downloadProgress != nil) {
        [self.downloadProgress removeObserver:self
                                   forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([object isKindOfClass:[NSURLSessionTask class]] || [object isKindOfClass:[NSURLSessionDownloadTask class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesSent))]) {
            self.uploadProgress.completedUnitCount = [change[NSKeyValueChangeNewKey] longLongValue];
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesExpectedToSend))]) {
            self.uploadProgress.totalUnitCount = [change[NSKeyValueChangeNewKey] longLongValue];
        } if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesReceived))]) {
            self.downloadProgress.completedUnitCount = [change[NSKeyValueChangeNewKey] longLongValue];
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))]) {
            self.downloadProgress.totalUnitCount = [change[NSKeyValueChangeNewKey] longLongValue];
        }
    } else if ([object isEqual:self.downloadProgress]) {
        if (self.downloadProgressBlock) {
            self.downloadProgressBlock(object);
        }
    } else if ([object isEqual:self.uploadProgress]) {
        if (self.uploadProgressBlock) {
            self.uploadProgressBlock(object);
        }
    }
}

//NSURLSessionDelegate
- (void)URLSession:(__unused NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    self.requestCompletionBlock(self.receiveData, task.response, error);
}

- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [self.receiveData appendData:data];
}
//NSURLSessionDownloadTaskDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    self.requestCompletionBlock(location, downloadTask.response, nil);
}

#pragma mark - request parameters format
- (void)addParamter:(NSObject *)obj forKey:(NSString *)key toParameters:(NSMutableArray *)parameters formatString:(NSString *)formatStr {
    if ([obj isKindOfClass:NSArray.class]) {
        for (NSString *subObj in (NSArray *)obj) {
            if ([subObj isKindOfClass:NSArray.class]) {
                //exception
                @throw [NSException exceptionWithName:@"request parameter type error" reason:[NSString stringWithFormat:@"the value(%@) of key(%@) can not be defined NSArray",obj,key] userInfo:@{key:obj}];
            }
            [self addParamter:subObj forKey:key toParameters:parameters formatString:formatStr];
        }
    } else if ([obj isKindOfClass:NSNumber.class]) {
        [parameters addObject:[NSString stringWithFormat:formatStr,key,[(NSNumber *)obj stringValue]]];
    } else if ([obj isKindOfClass:NSString.class]) {
        [parameters addObject:[NSString stringWithFormat:formatStr,key,obj]];
    } else {
        //exception
        @throw [NSException exceptionWithName:@"request parameter type error" reason:[NSString stringWithFormat:@"the value(%@) of key(%@) can not be defined %@",obj,key,NSStringFromClass([obj class])] userInfo:@{key:obj}];
    }
}

#pragma mark - post/get parmameters analyze
/**
 拼接GET参数字符串 以urlencode方式拼接
 */
- (NSString *)getGetParametersString:(NSDictionary *)parameters {
    if (parameters == nil || [parameters count] == 0) {
        return @"";
    }
    NSMutableArray *urlParameters = [NSMutableArray array];
    for (NSString *key in [parameters allKeys]) {
        [self addParamter:[parameters objectForKey:key] forKey:key toParameters:urlParameters formatString:@"%@=%@"];
    }
    return [NSString stringWithFormat:@"?%@",[urlParameters componentsJoinedByString:@"&"]];
}
/**
 拼接Post http boday Data
 */
- (NSData *)getPostData:(NSDictionary *)parameters {
    if (parameters == nil || [parameters count] == 0) {
        return nil;
    }
    NSMutableArray *urlParameters = [NSMutableArray array];
    for (NSString *key in [parameters allKeys]) {
        [self addParamter:[parameters objectForKey:key] forKey:key toParameters:urlParameters formatString:@"%@=%@"];
    }
    return [[urlParameters componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
}
/**
 拼接Post http boday Data 以boundary方式拼接
 */
- (NSMutableData *)getPostData:(NSDictionary *)parameters files:(NSArray<TYUploadFile *> *)files boundary:(NSString *)boundary {
    if (parameters == nil || [parameters count] == 0) {
        return nil;
    }
    //--boundary\r\nContent-Disposition: form-data; name="name"\r\n\r\nvalue\r\n"
    
    NSString *enter = @"\r\n";
    NSMutableString *formatString = [NSMutableString string];
    [formatString appendString:@"--"];
    [formatString appendString:boundary];
    [formatString appendString:enter];
    [formatString appendString:@"Content-Disposition: form-data; name=\""];
    [formatString appendString:@"%@\""];
    [formatString appendString:enter];
    [formatString appendString:enter];
    [formatString appendString:@"%@"];
    [formatString appendString:enter];
    
    NSMutableArray *urlParameters = [NSMutableArray array];
    
    for (NSString *key in [parameters allKeys]) {
        [self addParamter:[parameters objectForKey:key] forKey:key toParameters:urlParameters formatString:formatString];
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    for (NSString *value in urlParameters) {
        [data appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (files != nil) {
        for (TYUploadFile *file in files) {
            /*上传一个测试文件 begin*/
            NSMutableString *fileInfoContent = [NSMutableString string];
            [fileInfoContent appendString:@"--"];
            [fileInfoContent appendString:boundary];
            [fileInfoContent appendString:enter];
            //octet-stream 未知类型
            [fileInfoContent appendString:@"Content-Type:"];
            [fileInfoContent appendString:file.mimeType];
            [fileInfoContent appendString:enter];
            [fileInfoContent appendString:@"Content-Disposition: form-data; filename=\""];
            [fileInfoContent appendString:file.fileName];
            [fileInfoContent appendString:@"\"; name=\""];
            [fileInfoContent appendString:file.name];
            [fileInfoContent appendString:@"\""];
            [fileInfoContent appendString:enter];
            [fileInfoContent appendString:enter];
            [data appendData:[fileInfoContent dataUsingEncoding:NSUTF8StringEncoding]];
            if (file.fileData != nil) {
                [data appendData:file.fileData];
            } else {
                NSData *fileData = [NSData dataWithContentsOfURL:file.fileURL];
                [data appendData:fileData];
            }
            [data appendData:[enter dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    /*上传一个测试文件 end*/
    [data appendData:[[NSString stringWithFormat:@"--%@--",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return data;
}
#pragma mark - task main
- (void)request:(NSString *)URLString
         isPost:(BOOL)postFlag
     parameters:(id)parameters
          files:(NSArray<TYUploadFile *> *)files
     isDownload:(BOOL)downloadFlag
 uploadProgress:(void (^)(NSProgress * _Nonnull))uploadProgress
downloadProgress:(void (^)(NSProgress * _Nonnull))downloadProgress
completionHandler:(void (^)(id _Nullable,NSError *_Nullable))completionHandler {
    void (^progressCallback)(NSProgress * _Nonnull progress) = ^(NSProgress * _Nonnull progress) {
        NSLog(@"progress:%@",progress.debugDescription);
        if (uploadProgress) {
            uploadProgress(progress);
        }
    };
    void (^downloadProgressCallback)(NSProgress * _Nonnull progress) = ^(NSProgress * _Nonnull progress) {
        NSLog(@"downloadProgressCallback:%@",progress.debugDescription);
        if (downloadProgress) {
            downloadProgress(progress);
        }
    };
    __weak TFSessionTask *weakSelf = self;
    void (^completionCallback)(id  _Nullable responseObject,NSError *_Nullable error) = ^(id  _Nullable responseObject,NSError *_Nullable error) {
        NSLog(@"successCallback response:%@ error:%@",responseObject,error);
        completionHandler(responseObject,error);
        [__sessionDelegate.serviceList removeObject:weakSelf];
        [weakSelf removeProgressListenner];
    };
    
    NSURLSession *session = [TFSessionTask getDefalutSession];
    NSURL *url;
    if (files != nil) {
        postFlag = YES;
    }
    if (postFlag == YES) {
        //post url 不变
        url = [[NSURL alloc] initWithString:URLString];
    } else {
        //get 将parameters 拼接载url后面
        NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:URLString];
        @try {
            NSString *parameterString = [self getGetParametersString:parameters];
            [mutableUrl appendString:parameterString];
            
        } @catch (NSException *exception) {
            NSLog(@"request (%@) parameters type error (parameters:%@)",URLString,parameters);
            @throw exception;
        }
        url = [[NSURL alloc] initWithString:mutableUrl];
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:self.cachePolicy timeoutInterval:self.timeout];
    request.HTTPMethod = postFlag?@"POST":@"GET";
    if (postFlag == YES) {
        if (files != nil) {
            //以boundary 方式请求
            NSString *boundary = @"^";
            NSData *data = [self getPostData:parameters files:files boundary:boundary];
            if (data != nil) {
                [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:data];
            }
        } else {//以urlencod 方式请求
            NSData *data = [self getPostData:parameters];
            if (data != nil) {
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [request setHTTPBody:data];
                [request setValue:[NSString stringWithFormat:@"%lu", [data length]] forHTTPHeaderField:@"Content-Length"];
            }
        }
    }
    void (^requestCompletionHandler) (id _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) = ^(id _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            //error
            completionCallback(nil,error);
            return;
        }
        //success
        if (downloadFlag == YES) {
            //for download
            if ([data isKindOfClass:NSURL.class]) {
                completionCallback(data,error);
                return;
            }
            //会调用两遍
            return;
        }
        
        if ([response isKindOfClass:NSHTTPURLResponse.class]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary *header = [httpResponse allHeaderFields];
            NSLog(@"header:%@",header);
            NSString *mimeType = [httpResponse MIMEType];
            if ([@"text/json" isEqualToString:[mimeType lowercaseString]]) {
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&err];
                if (err != nil) {
                    NSLog(@"json解析失败：%@",err);
                    completionCallback(data,nil);
                    return;
                }
                NSLog(@"data:%@",dic);
                completionCallback(dic,nil);
                return;
            }
            if ([@"text/html" isEqualToString:[mimeType lowercaseString]]) {
                NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
            NSLog(@"mimeType-未知类型:%@",mimeType);
            completionCallback(data,nil);
            return;
        }
        NSLog(@"response-未知类型:%@",response);
        completionCallback(data,nil);
    };
    NSURLSessionTask *dataTask;
    if (downloadFlag == YES) {
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
        dataTask = downloadTask;
        self.requestCompletionBlock = requestCompletionHandler;
        self.downloadProgressBlock = downloadProgressCallback;
    } else if (files != nil) {
        //upload file request
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithStreamedRequest:request];
        self.requestCompletionBlock = requestCompletionHandler;
        self.receiveData = [NSMutableData data];
        dataTask = uploadTask;
    } else {
        //no files (get or post request)
        dataTask = [session dataTaskWithRequest:request completionHandler:requestCompletionHandler];
    }
    self.uploadProgressBlock = progressCallback;
    self.dataTask = dataTask;
    [self addProgressListenner];
    [__sessionDelegate.serviceList addObject:self];
    [dataTask resume];
}
#pragma mark override
//post
- (void)Post:(NSString *)URLString
  parameters:(id)parameters
completionHandler:(void (^)(id _Nullable,NSError *_Nullable))completionHandler {
    [self request:URLString isPost:YES parameters:parameters files:nil isDownload:NO uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
}
//get
- (void)Get:(NSString *)URLString
 parameters:(id)parameters
completionHandler:(void (^)(id _Nullable,NSError *_Nullable))completionHandler {
    [self request:URLString isPost:NO parameters:parameters files:nil isDownload:NO uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
}

//download
- (void)download:(NSString *)URLString
completionHandler:(void (^)(id _Nullable,NSError *_Nullable))completionHandler {
    [self request:URLString isPost:NO parameters:nil files:nil isDownload:YES uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
}
- (void)download:(NSString *)URLString
downloadProgress:(void (^)(NSProgress * _Nonnull))downloadProgress
completionHandler:(void (^)(id _Nullable,NSError *_Nullable))completionHandler {
    [self request:URLString isPost:NO parameters:nil files:nil isDownload:YES uploadProgress:nil downloadProgress:downloadProgress completionHandler:completionHandler];
}
- (void)download:(NSString *)URLString
      parameters:(id)parameters
downloadProgress:(void (^)(NSProgress * _Nonnull))downloadProgress
completionHandler:(void (^)(id _Nullable,NSError *_Nullable))completionHandler {
    //default use get
    [self request:URLString isPost:NO parameters:parameters files:nil isDownload:YES uploadProgress:nil downloadProgress:downloadProgress completionHandler:completionHandler];
}
//upload
- (void)upload:(NSString *)URLString
    parameters:(id)parameters
         files:(NSArray<TYUploadFile *> *)files
uploadProgress:(void (^)(NSProgress * _Nonnull))uploadProgress
completionHandler:(void (^)(id _Nullable,NSError *_Nullable))completionHandler {
    [self request:URLString isPost:YES parameters:parameters files:files isDownload:NO uploadProgress:nil downloadProgress:uploadProgress completionHandler:completionHandler];
}
@end

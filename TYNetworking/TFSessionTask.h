//
//  TYNetworking.h
//  frame
//
//  Created by deguang.mo on 2018/1/5.
//  Copyright © 2018年 deguang.mo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYUploadFile.h"
NS_ASSUME_NONNULL_BEGIN
@interface TFSessionTask : NSObject

/**
 if use defalutTask,timeout will be set 10s
 */
@property (nonatomic,assign) float timeout;
/**
 if use defalutTask,cachePolicy will be set NSURLRequestReloadIgnoringLocalCacheData
 */
@property (nonatomic,assign) NSURLRequestCachePolicy cachePolicy;


/**
 defalutTask

 @return TFSessionTask
 */
+ (TFSessionTask *)defalutTask;


/**
 request
 @param URLString the url of request
 @param postFlag if YES HTTPMethod will be set POST,or GET
 @param parameters the parameters of request
 @param files the files will be upload to server
 @param downloadFlag if YES means this is a download request
 @param uploadProgress if postFlag is YES or files not null,uploadProgress will be call
 @param downloadProgress if downloadFlag is YES,downloadProgress will be call
 @param completionHandler completionHandler
 */
- (void)request:(NSString *)URLString
         isPost:(BOOL)postFlag
     parameters:(NSDictionary * _Nullable)parameters
          files:(NSArray<TYUploadFile *> * _Nullable)files
     isDownload:(BOOL)downloadFlag
 uploadProgress:(nullable void (^)(NSProgress * _Nonnull progress))uploadProgress
downloadProgress:(nullable void (^)(NSProgress * _Nonnull progress))downloadProgress
completionHandler:(void (^)(id _Nullable data,NSError *_Nullable error))completionHandler;


/**
 post request
 @param URLString the url of request
 @param parameters the parameters of request
 @param completionHandler completionHandler
 */
- (void)Post:(NSString *)URLString
  parameters:(NSDictionary *_Nullable)parameters
completionHandler:(void (^)(id _Nullable data,NSError *_Nullable error))completionHandler;


/**
 get request
 @param URLString the url of request
 @param parameters the parameters of request
 @param completionHandler completionHandler
 */
- (void)Get:(NSString *)URLString
 parameters:(NSDictionary *_Nullable)parameters
completionHandler:(void (^)(id _Nullable data,NSError *_Nullable error))completionHandler;


/**
 download request
 */
- (void)download:(NSString *)URLString
completionHandler:(void (^)(id _Nullable filePath,NSError *_Nullable error))completionHandler;

/**
 download request
 @param URLString the url of request
 */
- (void)download:(NSString *)URLString
downloadProgress:(nullable void (^)(NSProgress * _Nonnull progress))downloadProgress
completionHandler:(void (^)(id _Nullable filePath,NSError *_Nullable error))completionHandler;

/**
 download request HTTPMethod defalut Get
 @param URLString the url of request
 @param parameters the parameters of request
 */
- (void)download:(NSString *)URLString
      parameters:(NSDictionary *_Nullable)parameters
downloadProgress:(void (^)(NSProgress * _Nonnull progress))downloadProgress
completionHandler:(void (^)(id _Nullable filePath,NSError *_Nullable error))completionHandler;

/**
 upload request
 @param URLString the url of request
 @param parameters the parameters of request
 */
- (void)upload:(NSString *)URLString
    parameters:(NSDictionary *_Nullable)parameters
         files:(NSArray<TYUploadFile *> *)files
uploadProgress:(void (^)(NSProgress * _Nonnull progress))uploadProgress
completionHandler:(void (^)(id _Nullable data,NSError *_Nullable error))completionHandler;

@end
NS_ASSUME_NONNULL_END

//
//  UploadFile.h
//  Clover
//
//  Created by deguang.mo on 2018/1/3.
//  Copyright © 2018年 WMAuto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYUploadFile : NSObject

/**
 服务器接收参数名称
 */
@property(nonnull,copy) NSString *name;

/**
 文件数据 与 fileURL 二选一
 */
@property(nonnull,retain) NSData *fileData;

/**
 文件URL 与 fileData 二选一
 */
@property(nonnull,retain) NSURL *fileURL;

/**
 本地文件名称
 */
@property(nonnull,copy) NSString *fileName;

/**
 文件type eg:image/jpeg
 */
@property(nonnull,copy) NSString *mimeType;


/**
 以文件URL初始化

 @param fileURL 文件URL
 @param name 服务器接收参数名称
 @return UploadFile
 */
- (TYUploadFile *_Nonnull)initWithFileURL:(NSURL *_Nonnull)fileURL name:(NSString *_Nonnull)name;


/**
 以文件数据初始化

 @param fileData 文件数据
 @param name 服务器接收参数名称
 @param fileName 本地文件名称 选填
 @param mimeType 文件type 选填
 @return UploadFile
 */
- (TYUploadFile *_Nonnull)initWithFileData:(NSData *_Nonnull)fileData name:(NSString *_Nonnull)name fileName:(NSString *_Nullable)fileName mimeType:(NSString *_Nullable)mimeType;
@end

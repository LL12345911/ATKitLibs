//
//  ATJsonDicTrans.h
//  EngineeringCool
//
//  Created by Mars on 2023/3/15.
//  Copyright © 2023 Mars. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JsonTransForm : NSObject


/**
 * NSDictionary（字典）转JSON（NSString） 字符串
 *
 * @param dict 需要转换的参数（字典）
 *
 * @return JSON字符串
 */
+ (NSString *)dictToJsonString:(NSDictionary *)dict;


/**
 * NSArray（数组）转JSON（NSString） 字符串
 *
 * @param array 需要转换的参数（数组）
 *
 * @return JSON字符串
 */
+ (NSString *)toJsonStrWithArray:(NSArray *)array;


/**
 * JSON（NSString） 字符串   转   NSDictionary（字典）
 *
 * @param jsonString   JSON字符串
 *
 * @return NSDictionary（字典）
 */
+ (NSDictionary *)jsonStringToDict:(NSString *)jsonString;


/**
 * JSON（NSString） 字符串   转   NSArray（数组）
 *
 * @param jsonString   JSON字符串
 *
 * @return NSArray（数组）
 */
+ (NSArray *)jsonStringToArray:(NSString *)jsonString;



/**
 * 对象序列成字典
 *
 * @param obj 需要序列化的对象
 *
 * @return 字典
 */
+ (NSDictionary *)objectToDict:(id)obj;


/**
 * 将对象序列换成JSON字符串
 *
 * @param obj 需要序列换的参数
 * @param error 失败时，失败信息
 *
 * @return 修改的json 字符串的数据
 */
+ (NSString *)objectToJsonString:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error;


/**
 * 将对象序列换成JSON字符串
 *
 * @param obj 需要序列换的参数
 *
 * @return 修改的json 字符串的数据
 */
+ (NSString *)objectToJsonString:(id)obj options:(NSJSONWritingOptions)options;


@end

NS_ASSUME_NONNULL_END

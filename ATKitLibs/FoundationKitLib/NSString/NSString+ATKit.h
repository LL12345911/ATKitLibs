//
//  NSString+ATKit.h
//  HighwayDoctor
//
//  Created by Mars on 2019/6/12.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 获取汉字转成拼音字符串 通讯录模糊搜索 支持拼音检索 首字母 全拼 汉字 搜索

///  获取汉字转成拼音字符串 通讯录模糊搜索 支持拼音检索 首字母 全拼 汉字 搜索
///  三林四标浦林城建项目部  #sanlinsibiaopulinchengjianxiangmubu,#slsbplcjxmb,#三林四标浦林城建项目部
/// @param aString 待转换字符串（汉字）
CG_INLINE NSString* TransformToPinyin(NSString *aString){
    if (aString.length == 0) {
        return @"";
    }
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    NSArray *pinyinArray = [str componentsSeparatedByString:@" "];
    NSMutableString *allString = [[NSMutableString alloc] init];
    NSString *ss = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    [allString appendFormat:@"#%@,",ss];
    
    NSMutableString *initialStr = [[NSMutableString alloc] init];
    //拼音首字母
    for (NSString *s in pinyinArray){
        if (s.length > 0){
            [initialStr appendString:[s substringToIndex:1]];
        }
    }
    [allString appendFormat:@"#%@",initialStr];
    [allString appendFormat:@",#%@",aString];
    return allString;
}

///  获取汉字转成拼音字符串 通讯录模糊搜索 支持拼音检索 首字母 全拼 汉字 搜索
///  三林四标浦林城建项目部  #sanlinsibiaopulinchengjianxiangmubu,san#linsibiaopulinchengjianxiangmubu,sanlin#sibiaopulinchengjianxiangmubu,sanlinsi#biaopulinchengjianxiangmubu,sanlinsibiao#pulinchengjianxiangmubu,sanlinsibiaopu#linchengjianxiangmubu,sanlinsibiaopulin#chengjianxiangmubu,sanlinsibiaopulincheng#jianxiangmubu,sanlinsibiaopulinchengjian#xiangmubu,sanlinsibiaopulinchengjianxiang#mubu,sanlinsibiaopulinchengjianxiangmu#bu,#slsbplcjxmb,#三林四标浦林城建项目部
/// @param aString 待转换字符串（汉字）
CG_INLINE NSString* TransformToPinyin33(NSString *aString){
    if (aString.length == 0) {
        return @"";
    }
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    NSArray *pinyinArray = [str componentsSeparatedByString:@" "];
    NSMutableString *allString = [[NSMutableString alloc] init];
    
    int count = 0;
    
    for (int  i = 0; i < pinyinArray.count; i++){
        for(int i = 0; i < pinyinArray.count;i++){
            if (i == count) {
                [allString appendString:@"#"];
                //区分第几个字母
            }
            [allString appendFormat:@"%@",pinyinArray[i]];
        }
        [allString appendString:@","];
        count ++;
    }
    
    NSMutableString *initialStr = [[NSMutableString alloc] init];
    //拼音首字母
    for (NSString *s in pinyinArray){
        if (s.length > 0){
            [initialStr appendString:[s substringToIndex:1]];
        }
    }
    [allString appendFormat:@"#%@",initialStr];
    [allString appendFormat:@",#%@",aString];
    return allString;
}

@interface NSString (ATKit)


//判断一个字符串中是否都是数字
+ (BOOL)isAllNum:(NSString *)string;

#pragma mark - 判断是否是真机
+ (BOOL)ifNotPhone;

/// Simple convenience methods for string searching. containsString: returns YES if the target string is contained within the receiver. Same as calling rangeOfString:options: with no options, thus doing a case-sensitive, locale-unaware search. localizedCaseInsensitiveContainsString: is the case-insensitive variant which also takes the current locale into effect. Starting in 10.11 and iOS9, the new localizedStandardRangeOfString: or localizedStandardContainsString: APIs are even better convenience methods for user level searching.   More sophisticated needs can be achieved by calling rangeOfString:options:range:locale: directly.
/// \n是否 包含某字符串 适应本地搜索🔍，拼音，首字母，汉语 搜索
/// @param str 需要转化成拼音的字符串
- (BOOL)makeSureContainsString:(NSString *)str;
- (NSString *)transformToPinyin:(NSString *)aString;


/// 将汉语转化成拼音
/// @param aString 需要转化成拼音的字符串
+ (NSString *)transformhChineseToPinyin:(NSString *)aString;

/// 获取字符串首字母 firstLetterChineseToPinyin：
/// @param aString 字符串
+ (NSString *)firstLetterChineseToPinyin:(NSString *)aString;


/**
 去掉浮点数后面多余的0
 
 @param string 要去除多余0的字符串
 @return 去掉浮点数后面多余的0字符串
 */
+ (NSString*)removeFloatAllZero:(NSString*)string;

/**
 给字符串小数点后面补零
 
 @param price 字符串
 @param position 小数点后面 的位数，不足补零
 @return 字符串
 */
+(NSString *)notRounding:(NSString*)price afterPoint:(NSInteger)position;



+ (NSString *)md5:(NSString *)str;
/**
 查找子字符串在父字符串中的所有位置
 @param content 父字符串
 @param tab 子字符串
 @return 返回位置数组
 */
- (NSMutableArray*)calculateSubStringCount:(NSString *)content str:(NSString *)tab;

+ (NSString *)getCurrentTime;

/**
 获取文本高度

 @param constraint size
 @param strText 计算文本
 @param font 字体
 @return 高度
 */
+ (float)heightForTextView:(CGSize)constraint WithText:(NSString *)strText WithFont:(CGFloat)font;


#pragma mark -
#pragma mark - xml字符串转换成NSDictionary
/**
 @brief  xml字符串转换成NSDictionary
 *
 @return NSDictionary
 */
-(NSDictionary *)at_XMLDictionary;
#pragma mark -
#pragma mark - 计算文字的宽高
/**
 动态计算文字的宽高（单行）
 @param font 文字的字体
 @return 计算的宽高
 */
- (CGSize)at_sizeWithFont:(UIFont *)font;
/**
 动态计算文字的宽高（多行）
 @param font 文字的字体
 @param limitSize 限制的范围
 @return 计算的宽高
 */
- (CGSize)at_sizeWithFont:(UIFont *)font limitSize:(CGSize)limitSize;
/**
 动态计算文字的宽高（多行）
 @param font 文字的字体
 @param limitWidth 限制宽度 ，高度不限制
 @return 计算的宽高
 */
- (CGSize)at_sizeWithFont:(UIFont *)font limitWidth:(CGFloat)limitWidth;
/**
 @brief 计算文字的高度
 @param font  字体(默认为系统字体)
 @param width 约束宽度
 */
- (CGFloat)at_heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
/**
 @brief 计算文字的宽度
 @param font   字体(默认为系统字体)
 @param height 约束高度
 */
- (CGFloat)at_widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;
/**
 @brief 计算文字的大小
 *
 @param font  字体(默认为系统字体)
 @param width 约束宽度
 */
- (CGSize)at_sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
/**
 @brief 计算文字的大小
 @param font   字体(默认为系统字体)
 @param height 约束高度
 */
- (CGSize)at_sizeWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;
/**
 @brief  反转字符串
 @param strSrc 被反转字符串
 @return 反转后字符串
 */
+ (NSString *)at_reverseString:(NSString *)strSrc;
///根据字号及尺寸限制返回文本尺寸
-(CGSize)stringSizeWithFont:(UIFont *)font
                 widthLimit:(CGFloat)widthLimit
                heightLimit:(CGFloat)heightLimit;

#pragma mark - UrlEncode
/**
 @brief  urlEncode
 @return urlEncode 后的字符串
 */
- (NSString *)urlEncode;
/**
 @brief  urlEncode
 @param encoding encoding模式
 @return urlEncode 后的字符串
 */
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
/**
 @brief  urlDecode
 @return urlDecode 后的字符串
 */
- (NSString *)urlDecode;
/**
 @brief  urlDecode
 @param encoding encoding模式
 @return urlDecode 后的字符串
 */
- (NSString *)urlDecodeUsingEncoding:(NSStringEncoding)encoding;

/**
 @brief  url query转成NSDictionary
 @return NSDictionary
 */
- (NSDictionary *)dictionaryFromURLParameters;


#pragma mark -
#pragma mark - 清除 ATTrims
///**
// @brief  清除html标签
// @return 清除后的结果
// */
//- (NSString *)at_stringByStrippingHTML;
///**
// @brief  清除js脚本
// @return 清楚js后的结果
// */
//- (NSString *)at_stringByRemovingScriptsAndStrippingHTML;
///**
// @brief  去除空格
// @return 去除空格后的字符串
// */
//- (NSString *)at_trimmingWhitespace;
///**
// @brief  去除字符串与空行
// @return 去除字符串与空行的字符串
// */
//- (NSString *)at_trimmingWhitespaceAndNewlines;



#pragma mark -
#pragma mark - Hash HMAC
//// ********  Hash   ******** //
///// 返回结果：32长度(128位，16字节，16进制字符输出则为32字节长度)   终端命令：md5 -s "123"
//@property (readonly) NSString *at_md5String;
///// 返回结果：40长度   终端命令：echo -n "123" | openssl sha -sha1
//@property (readonly) NSString *at_sha1String;
///// 返回结果：56长度   终端命令：echo -n "123" | openssl sha -sha224
//@property (readonly) NSString *at_sha224String;
///// 返回结果：64长度   终端命令：echo -n "123" | openssl sha -sha256
//@property (readonly) NSString *at_sha256String;
///// 返回结果：96长度   终端命令：echo -n "123" | openssl sha -sha384
//@property (readonly) NSString *at_sha384String;
///// 返回结果：128长度   终端命令：echo -n "123" | openssl sha -sha512
//@property (readonly) NSString *at_sha512String;
//
//// ********  HMAC   ******** //
///// 返回结果：32长度  终端命令：echo -n "123" | openssl dgst -md5 -hmac "123"
//- (NSString *)at_hmacMD5StringWithKey:(NSString *)key;
///// 返回结果：40长度   echo -n "123" | openssl sha -sha1 -hmac "123"
//- (NSString *)at_hmacSHA1StringWithKey:(NSString *)key;
//- (NSString *)at_hmacSHA224StringWithKey:(NSString *)key;
//- (NSString *)at_hmacSHA256StringWithKey:(NSString *)key;
//- (NSString *)at_hmacSHA384StringWithKey:(NSString *)key;
//- (NSString *)at_hmacSHA512StringWithKey:(NSString *)key;

//// 字符串转base64（加密）
//+ (NSString *)base64StringFromText:(NSString *)text;
//
//// base64转字符串（解密）
//+ (NSString *)textFromBase64String:(NSString *)base64;


#pragma mark -
#pragma mark - 汉字转拼音
///转拼音后的字符串
@property (nonatomic ,copy) NSString * pinyinString;
///生成由N个元字符串组成的字符串
/**
 metaString     元字符串，组成字符串的元素
 count          元字符串的个数
 */
+(NSString *)stringWithMetaString:(NSString *)metaString count:(NSUInteger)count;
///以长度生成随机字符串，字符串有大小写字母及数字组成
+(NSString *)stringWithRandomCharacterWithLength:(NSUInteger)length;
///给文件名添加序数（文件名重复时使用）
-(NSString *)at_FixFileNameStringWithIndex:(NSUInteger)idx;
/**
 汉字转拼音
 @param neeAThiteSpace 是否需要空格间隔
 @param tone           是否需要音调
 @return 转换后用拼音
 */
-(NSString *)at_TransferChineseToPinYinWithWhiteSpace:(BOOL)neeAThiteSpace tone:(BOOL)tone;
///返回整串字符串中符合正则的结果集
-(NSArray <NSTextCheckingResult *> *)at_RangesConfirmToPattern:(NSString *)pattern;
///符合正则的子串集
-(NSArray <NSString *> *)at_SubStringConfirmToPattern:(NSString *)pattern;
///将字符串分割成词（中文汉字为最小单位，英文单词为最小单位）
-(NSArray *)at_TrimStringToWord;
///判断字符串是否是中文
-(BOOL)at_StringIsChinese;
/**
 将字符串中的包含在数组中的子串替换为另一字符串
 @param characters 要被替换的子串数组
 @param temp 替换的目标串
 @return 替换后的字符串
 */
-(NSString *)at_StringByReplacingCharactersInArray:(NSArray *)characters withString:(NSString *)temp;
/**
 去除首尾空格并压缩串中空格至1个
 @return 压缩后的字符串
 */
-(NSString *)at_StringByTrimmingWhitespace;

///将数组内字符串以拼音排序
+(NSMutableArray *)at_SortedStringsInPinyin:(NSArray <NSString *>*)strings;
/**
 返回以拼音比较的结果
 @param string 被比较的字符串
 @param tone   是否考虑音调
 @return 比较结果
 */
-(NSComparisonResult)at_ComparedInPinyinWithString:(NSString *)string considerTone:(BOOL)tone;
/**
 返回考虑音调的拼音比较结果
 @param string 被比较的字符串
 @return 比较结果
 */
-(NSComparisonResult)at_ComparedInPinyinWithString:(NSString *)string;



@end

NS_ASSUME_NONNULL_END

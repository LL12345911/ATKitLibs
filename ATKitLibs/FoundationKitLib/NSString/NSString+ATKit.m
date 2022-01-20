//
//  NSString+ATKit.m
//  HighwayDoctor
//
//  Created by Mars on 2019/6/12.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "NSString+ATKit.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <objc/runtime.h>

#define replaceIfContains(string,target,replacement,tone) \
do {\
if ([string containsString:target]) {\
string = [string stringByReplacingOccurrencesOfString:target withString:replacement];\
string = [NSString stringWithFormat:@"%@%d",string,tone];\
}\
} while(0)

//xml字符串转换成NSDictionary
#define AT_ASSOCIATIVE_CURRENT_DICTIONARY_KEY @"ASSOCIATIVE_CURRENT_DICTIONARY_KEY"
#define AT_ASSOCIATIVE_CURRENT_TEXT_KEY @"ASSOCIATIVE_CURRENT_TEXT_KEY"

//#define     LocalStr_None           @""
//static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


@interface NSString ()<NSXMLParserDelegate>
//xml字符串转换成NSDictionary
@property(nonatomic, retain)NSMutableArray *currentDictionaries;
@property(nonatomic, retain)NSMutableString *currentText;
//汉字转拼音
@property (nonatomic ,strong) NSArray *wordArray;
@property (nonatomic ,copy) NSString *wordPinyinWithTone;
@property (nonatomic ,copy) NSString *wordPinyinWithoutTone;

@end


@implementation NSString (ATKit)

+ (BOOL)isAllNum:(NSString *)string{
    unichar c;
    for (int i=0; i<string.length; i++) {
        c=[string characterAtIndex:i];
        if (!isdigit(c)) {
            return NO;
        }
    }
    return YES;
}
#pragma mark - 判断是否是真机
+ (BOOL)ifNotPhone {
    
    //#ifdef DEBUG //处于开发阶段
#if defined(DEBUG) || defined(_DEBUG) //处于开发阶段
    
    return NO;
#else //处于上线阶段
    
    return TARGET_IPHONE_SIMULATOR ? YES : NO;
#endif
}


/// Simple convenience methods for string searching. containsString: returns YES if the target string is contained within the receiver. Same as calling rangeOfString:options: with no options, thus doing a case-sensitive, locale-unaware search. localizedCaseInsensitiveContainsString: is the case-insensitive variant which also takes the current locale into effect. Starting in 10.11 and iOS9, the new localizedStandardRangeOfString: or localizedStandardContainsString: APIs are even better convenience methods for user level searching.   More sophisticated needs can be achieved by calling rangeOfString:options:range:locale: directly.
/// 是否 包含某字符串 适应本地搜索🔍，拼音，首字母，汉语 搜索
/// @param str 需要转化成拼音的字符串
- (BOOL)makeSureContainsString:(NSString *)str{
    NSString *pinyin = [self transformToPinyin:str];
    if([pinyin rangeOfString:self options:NSCaseInsensitiveSearch].location != NSNotFound){
        //包含
        return YES;
    }else{
        //不包含
        return NO;
    }
}
#pragma mark - 获取汉字转成拼音字符串 通讯录模糊搜索 支持拼音检索 首字母 全拼 汉字 搜索
- (NSString *)transformToPinyin:(NSString *)aString{
    if (aString.length == 0) {
        return @"";
    }
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    NSArray *pinyinArray = [str componentsSeparatedByString:@" "];
    NSMutableString *allString = [NSMutableString new];
    
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
    NSMutableString *initialStr = [NSMutableString new];
    //拼音首字母
    for (NSString *s in pinyinArray){
        if (s.length > 0){
            [initialStr appendString:  [s substringToIndex:1]];
        }
    }
    [allString appendFormat:@"#%@",initialStr];
    [allString appendFormat:@",#%@",aString];
    return allString;
}


#pragma mark - 获取汉字转成拼音字符串 通讯录模糊搜索 支持拼音检索 首字母 全拼 汉字 搜索
+ (NSString *)transformhChineseToPinyin:(NSString *)aString{
    if (aString.length == 0) {
        return @"";
    }
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    NSArray *pinyinArray = [str componentsSeparatedByString:@" "];
    NSMutableString *allString = [NSMutableString new];
    
    
        for(int i = 0; i < pinyinArray.count;i++){
            [allString appendFormat:@"%@",pinyinArray[i]];
        }
       
   
    return allString;
}

/// 获取字符串首字母大写 firstLetterChineseToPinyin：
/// @param aString 字符串
+ (NSString *)firstLetterChineseToPinyin:(NSString *)aString{
    if (aString.length == 0) {
        return @"";
    }
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    NSArray *pinyinArray = [str componentsSeparatedByString:@" "];
    
    if (pinyinArray.count > 0) {
        //转化为大写拼音
        NSString *pPinYin = [pinyinArray[0] capitalizedString];
        return pPinYin;
    }else{
        return @"#";
    }
//    if (pinyinArray.count > 0) {
//        return pinyinArray[0];
//    }else{
//        return @"#";
//    }
}

/**
 去掉浮点数后面多余的0
 
 @param string 要去除多余0的字符串
 @return 去掉浮点数后面多余的0字符串
 */
+ (NSString*)removeFloatAllZero:(NSString*)string{
    //    NSNumber * nsNumber = @(string.floatValue);
    //    NSString * outNumber = [NSString stringWithFormat:@"%@",nsNumber];
    /*---------第一种方法-----------*/
    
    long len = string.length;
    for (int i = 0; i < len; i++){
        if (![string  hasSuffix:@"0"]){
            break;
        }else{
            if (![string containsString:@"."]) {
                break;
            }else{
                string = [string substringToIndex:[string length]-1];
            }
        }
    }
    if ([string hasSuffix:@"."])//避免像2.0000这样的被解析成2.
        {
        //s.substring(0, len - i - 1);
        return [string substringToIndex:[string length]-1];
        }else{
            return string;
        }
}

/**
 给字符串小数点后面补零
 
 @param price 字符串
 @param position 小数点后面 的位数，不足补零
 @return 字符串
 */
+(NSString *)notRounding:(NSString*)price afterPoint:(NSInteger)position{
    
    NSRange range = [price rangeOfString:@"."];
    if (range.length != 0 && (price.length-range.location-1>=position)) {
        position = price.length-range.location-1;
    }
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc]initWithString:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    //    return roundedOunces;// 整数的不带小数点
    NSString* string = [NSString stringWithFormat:@"%@",roundedOunces];
    
    if ([string rangeOfString:@"."].length==0) {
        NSString *str = @".";
        for (int i = 0;  i < position; i++) {
            str = [str stringByAppendingString:@"0"];
        }
        //string=  [string stringByAppendingString:@".00000"];
        string=  [string stringByAppendingString:str];
    }else{
        
        NSRange range = [string rangeOfString:@"."];
        for (NSInteger i = ((string.length-range.location-1) > 0 ?(string.length-range.location-1):position);  i < position; i++) {
            string=   [string stringByAppendingString:@"0"];
        }
    }
    return string;//整数.00格式
}




+ (NSString *)md5:(NSString *)str {
    if (!str) return nil;
    
    const char *cStr = str.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *md5Str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    return md5Str;
}

+ (NSString *)getCurrentTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];//AZ  [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss.SSS"];//
    NSDate *datenow = [NSDate date];
    NSTimeInterval a = [datenow timeIntervalSince1970]*1000; // *1000 是精确到毫秒，不乘就是精确到秒
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    currentTimeString = [NSString stringWithFormat:@"%@.%ld",currentTimeString,((long)a)%1000000];
    return currentTimeString;
}

//获取文本高度
+ (float)heightForTextView:(CGSize)constraint WithText: (NSString *) strText WithFont:(CGFloat)font{
    if (!strText||strText.length==0) {
        return 0;
    }
    CGRect size = [strText boundingRectWithSize:constraint
                                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:font]}
                                        context:nil];
    float textHeight = size.size.height;
    return textHeight;
}

/**
 查找子字符串在父字符串中的所有位置
 @param content 父字符串
 @param tab 子字符串
 @return 返回位置数组
 */
- (NSMutableArray*)calculateSubStringCount:(NSString *)content str:(NSString *)tab {
    int location = 0;
    NSMutableArray *locationArr = [NSMutableArray new];
    NSRange range = [content rangeOfString:tab];
    if (range.location == NSNotFound){
        return locationArr;
    }
    //声明一个临时字符串,记录截取之后的字符串
    NSString * subStr = content;
    while (range.location != NSNotFound) {
        if (location == 0) {
            location += range.location;
        } else {
            location += range.location + tab.length;
        }
        //记录位置
        NSNumber *number = [NSNumber numberWithUnsignedInteger:location];
        [locationArr addObject:number];
        //每次记录之后,把找到的字串截取掉
        subStr = [subStr substringFromIndex:range.location + range.length];
        NSLog(@"subStr %@",subStr);
        range = [subStr rangeOfString:tab];
        NSLog(@"rang %@",NSStringFromRange(range));
    }
    return locationArr;
    
}


///**
// 改变UILabel部分字符颜色
// */
//- (void)setContentLabelColor {
//    NSString *content = @"2018-08-27\n写博客\n2018-08-27\n写博客\n2018-08-27\n写博客\n2018-08-27\n写博客\n2018-08-27\n写博客\n2018-08-27\n写博客\n2018-08-27\n写博客\n2018-08-27\n写博客";
//    NSMutableArray *locationArr = [self calculateSubStringCount:content str:@"\n"];
//    NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc] initWithString:content];
//    for (int i=0; i<locationArr.count; i++) {
//        if (i%2==0) {
//            NSNumber *location = locationArr[i];
//            [attstr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255.0f/255.0f green:45.0f/255.0f blue:81.0f/255.0f alpha:1.0f] range:NSMakeRange(location.integerValue-10, 10)];//改变\n前边的10位字符颜色，
//        }
//    }
//    self.contentLabel.attributedText = attstr;
//}



    
#pragma mark -
#pragma mark - xml字符串转换成NSDictionary
/**
 *  @brief  xml字符串转换成NSDictionary
 *
 *  @return NSDictionary
 */
-(NSDictionary *)at_XMLDictionary{
    //TURN THE STRING INTO DATA
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    //INTIALIZE NECESSARY HELPER VARIABLES
    self.currentDictionaries = [[NSMutableArray alloc] init] ;
    self.currentText = [[NSMutableString alloc] init];
    
    //INITIALIZE WITH A DICTIONARY TO START WITH
    [self.currentDictionaries addObject:[NSMutableDictionary dictionary]];
    
    //DO PARSING
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    BOOL success = [parser parse];
    
    //RETURNS
    if(success)
        return [self.currentDictionaries objectAtIndex:0];
    else
        return nil;
}

#pragma mark -
#pragma mark ASSOCIATIVE OVERRIDES
- (void)setCurrentDictionaries:(NSMutableArray *)currentDictionaries{
    objc_setAssociatedObject(self, AT_ASSOCIATIVE_CURRENT_DICTIONARY_KEY, currentDictionaries, OBJC_ASSOCIATION_RETAIN);
}
- (NSMutableArray *)currentDictionaries{
    return objc_getAssociatedObject(self, AT_ASSOCIATIVE_CURRENT_DICTIONARY_KEY);
}
- (void)setCurrentText:(NSMutableString *)currentText{
    objc_setAssociatedObject(self, AT_ASSOCIATIVE_CURRENT_TEXT_KEY, currentText, OBJC_ASSOCIATION_RETAIN);
}
- (NSMutableString *)currentText{
    return objc_getAssociatedObject(self, AT_ASSOCIATIVE_CURRENT_TEXT_KEY);
}

#pragma mark -
#pragma mark NSXMLPARSER DELEGATE
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    //GET THE LAST DICTIONARY
    NSMutableDictionary *parent = [self.currentDictionaries lastObject];
    
    //CREATE A NEW DICTIONARY AND SET ALL THE ATTRIBUTES
    NSMutableDictionary *child = [NSMutableDictionary dictionary];
    [child addEntriesFromDictionary:attributeDict];
    
    id currentValue = [parent objectForKey:elementName];
    
    //SHOULD BE AN ARRAY IF WE ALREADY HAVE ONE FOR THIS KEY, OTHERWISE JUST ADD IT IN
    if (currentValue){
        NSMutableArray *array = nil;
        //IF CURRENTVALUE IS ALREADY AN ARRAY USE IT, OTHERWISE, MAKE ONE
        if ([currentValue isKindOfClass:[NSMutableArray class]]){
            array = (NSMutableArray *) currentValue;
        }else{
            array = [NSMutableArray array];
            [array addObject:currentValue];
            
            //REPLACE DICTIONARY WITH ARRAY IN PARENT
            [parent setObject:array forKey:elementName];
        }
        [array addObject:child];
    }else{
        [parent setObject:child forKey:elementName];
    }
    //ADD NEW OBJECT
    [self.currentDictionaries addObject:child];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    //UPDATE PARENT INFO
    NSMutableDictionary *dictInProgress = [self.currentDictionaries lastObject];
    
    if ([self.currentText length] > 0){
        //REMOVE WHITE SPACE
        [dictInProgress setObject:self.currentText forKey:@"text"];
        
        self.currentText = nil;
        self.currentText = [[NSMutableString alloc] init];
    }
    //NO LONGER NEED THIS DICTIONARY, AS WE'RE DONE WITH IT
    [self.currentDictionaries removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [self.currentText appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    //WILL RETURN NIL FOR ERROR
}
#pragma mark -
#pragma mark - 计算文字的宽高
/**
 *  动态计算文字的宽高（单行）
 *  @param font 文字的字体
 *  @return 计算的宽高
 */
- (CGSize)at_sizeWithFont:(UIFont *)font{
    CGSize theSize;
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    theSize = [self sizeWithAttributes:attributes];
    // 向上取整
    theSize.width = ceil(theSize.width);
    theSize.height = ceil(theSize.height);
    return theSize;
}

/**
 *  动态计算文字的宽高（多行）
 *
 *  @param font 文字的字体
 *  @param limitSize 限制的范围
 *
 *  @return 计算的宽高
 */
- (CGSize)at_sizeWithFont:(UIFont *)font limitSize:(CGSize)limitSize{
    CGSize theSize;
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    CGRect rect = [self boundingRectWithSize:limitSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil];
    theSize.width = ceil(rect.size.width);
    theSize.height = ceil(rect.size.height);
    return theSize;
}

/**
 *  动态计算文字的宽高（多行）
 *
 *  @param font 文字的字体
 *  @param limitWidth 限制宽度 ，高度不限制
 *
 *  @return 计算的宽高
 */
- (CGSize)at_sizeWithFont:(UIFont *)font limitWidth:(CGFloat)limitWidth{
    return [self at_sizeWithFont:font limitSize:CGSizeMake(limitWidth, MAXFLOAT)];
}

/**
 *  @brief 计算文字的高度
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGFloat)at_heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        textSize = [self backCGRectByFont:textFont size:CGSizeMake(width, CGFLOAT_MAX)].size;
    } else {
        textSize = [self sizeWithFont:textFont constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    textSize = [self backCGRectByFont:textFont size:CGSizeMake(width, CGFLOAT_MAX)].size;
#endif
    
    return ceil(textSize.height);
}

/**
 *  @brief 计算文字的宽度
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGFloat)at_widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        
        textSize = [self backCGRectByFont:textFont size:CGSizeMake(CGFLOAT_MAX, height)].size;
        
    } else {
        textSize = [self sizeWithFont:textFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, height) lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    textSize = [self backCGRectByFont:textFont size:CGSizeMake(CGFLOAT_MAX, height)].size;
    
#endif
    
    return ceil(textSize.width);
}

/**
 *  @brief 计算文字的大小
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGSize)at_sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {

        textSize = [self backCGRectByFont:textFont size:CGSizeMake(width, CGFLOAT_MAX)].size;
    } else {
        textSize = [self sizeWithFont:textFont constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    textSize = [self backCGRectByFont:textFont size:CGSizeMake(width, CGFLOAT_MAX)].size;
    
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

/**
 *  @brief 计算文字的大小
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGSize)at_sizeWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {

        textSize = [self backCGRectByFont:textFont size:CGSizeMake(CGFLOAT_MAX, height)].size;
        
    } else {
        textSize = [self sizeWithFont:textFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, height) lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    textSize = [self backCGRectByFont:textFont size:CGSizeMake(CGFLOAT_MAX, height)].size;
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

/**
 返回文字的CGRect

 @param textFont 字体
 @param size 文字宽高
 @return CGRect
 */
- (CGRect)backCGRectByFont:(UIFont *)textFont size:(CGSize)size{
    @autoreleasepool {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        CGRect textRect = [self boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine) attributes:attributes context:nil];
        return textRect;
    }
}

/**
 *  @brief  反转字符串
 *
 *  @param strSrc 被反转字符串
 *
 *  @return 反转后字符串
 */
+ (NSString *)at_reverseString:(NSString *)strSrc{
    NSMutableString* reverseString = [[NSMutableString alloc] init];
    NSInteger charIndex = [strSrc length];
    while (charIndex > 0) {
        charIndex --;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reverseString appendString:[strSrc substringWithRange:subStrRange]];
    }
    return reverseString;
}

-(CGSize)stringSizeWithFont:(UIFont *)font widthLimit:(CGFloat)widthLimit heightLimit:(CGFloat)heightLimit{
    return  [self boundingRectWithSize:CGSizeMake(widthLimit, heightLimit) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
}




#pragma mark -
#pragma mark - UrlEncode
/**
 *  @brief  urlEncode
 *
 *  @return urlEncode 后的字符串
 */
- (NSString *)urlEncode {
    return [self urlEncodeUsingEncoding:NSUTF8StringEncoding];
}
/**
 *  @brief  urlEncode
 *
 *  @param encoding encoding模式
 *
 *  @return urlEncode 后的字符串
 */
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(__bridge CFStringRef)self,NULL,(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",CFStringConvertNSStringEncodingToEncoding(encoding));
#pragma clang diagnostic pop
}
/**
 *  @brief  urlDecode
 *
 *  @return urlDecode 后的字符串
 */
- (NSString *)urlDecode {
    return [self urlDecodeUsingEncoding:NSUTF8StringEncoding];
}
/**
 *  @brief  urlDecode
 *
 *  @param encoding encoding模式
 *
 *  @return urlDecode 后的字符串
 */
- (NSString *)urlDecodeUsingEncoding:(NSStringEncoding)encoding {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,(__bridge CFStringRef)self,CFSTR(""),CFStringConvertNSStringEncodingToEncoding(encoding));
    
#pragma clang diagnostic pop
}
/**
 *  @brief  url query转成NSDictionary
 *
 *  @return NSDictionary
 */
- (NSDictionary *)dictionaryFromURLParameters{
    NSArray *pairs = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1] stringByRemovingPercentEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}




#pragma mark -
#pragma mark - 清除 ATTrims
///**
// *  @brief  清除html标签
// *
// *  @return 清除后的结果
// */
//- (NSString *)at_stringByStrippingHTML {
//    return [self stringByReplacingOccurrencesOfString:@"<[^>]+>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
//}
///**
// *  @brief  清除js脚本
// *
// *  @return 清楚js后的结果
// */
//- (NSString *)at_stringByRemovingScriptsAndStrippingHTML {
//    NSMutableString *mString = [self mutableCopy];
//    NSError *error;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<script[^>]*>[\\w\\W]*</script>" options:NSRegularExpressionCaseInsensitive error:&error];
//    NSArray *matches = [regex matchesInString:mString options:NSMatchingReportProgress range:NSMakeRange(0, [mString length])];
//    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
//        [mString replaceCharactersInRange:match.range withString:@""];
//    }
//    return [mString at_stringByStrippingHTML];
//}
///**
// *  @brief  去除空格
// *
// *  @return 去除空格后的字符串
// */
//- (NSString *)at_trimmingWhitespace{
//    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//}
///**
// *  @brief  去除字符串与空行
// *
// *  @return 去除字符串与空行的字符串
// */
//- (NSString *)at_trimmingWhitespaceAndNewlines{
//    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//}



#pragma mark -
#pragma mark - Hash HMAC
//- (NSString *)at_md5String{
//    const char *string = self.UTF8String;
//    int length = (int)strlen(string);
//    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(string, length, bytes);
//    return [self at_stringFromBytes:bytes length:CC_MD5_DIGEST_LENGTH];
//}
//- (NSString *)at_sha1String{
//    const char *string = self.UTF8String;
//    int length = (int)strlen(string);
//    unsigned char bytes[CC_SHA1_DIGEST_LENGTH];
//    CC_SHA1(string, length, bytes);
//    return [self at_stringFromBytes:bytes length:CC_SHA1_DIGEST_LENGTH];
//}
//- (NSString *)at_sha224String {
//    const char *string = self.UTF8String;
//    int length = (int)strlen(string);
//    unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
//    CC_SHA224(string, length, bytes);
//    return [self at_stringFromBytes:bytes length:CC_SHA256_DIGEST_LENGTH];
//}
//- (NSString *)at_sha256String{
//    const char *string = self.UTF8String;
//    int length = (int)strlen(string);
//    unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
//    CC_SHA256(string, length, bytes);
//    return [self at_stringFromBytes:bytes length:CC_SHA256_DIGEST_LENGTH];
//}
//- (NSString *)at_sha384String{
//    const char *string = self.UTF8String;
//    int length = (int)strlen(string);
//    unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
//    CC_SHA384(string, length, bytes);
//    return [self at_stringFromBytes:bytes length:CC_SHA256_DIGEST_LENGTH];
//}
//- (NSString *)at_sha512String{
//    const char *string = self.UTF8String;
//    int length = (int)strlen(string);
//    unsigned char bytes[CC_SHA512_DIGEST_LENGTH];
//    CC_SHA512(string, length, bytes);
//    return [self at_stringFromBytes:bytes length:CC_SHA512_DIGEST_LENGTH];
//}
//
//- (NSString *)at_hmacMD5StringWithKey:(NSString *)key {
//    return [self at_hmacStringUsingAlg:kCCHmacAlgMD5 withKey:key];
//}
//- (NSString *)at_hmacSHA1StringWithKey:(NSString *)key{
//    return [self at_hmacStringUsingAlg:kCCHmacAlgSHA1 withKey:key];
//    
//}
//- (NSString *)at_hmacSHA224StringWithKey:(NSString *)key{
//    return [self at_hmacStringUsingAlg:kCCHmacAlgSHA224 withKey:key];
//}
//- (NSString *)at_hmacSHA256StringWithKey:(NSString *)key{
//    return [self at_hmacStringUsingAlg:kCCHmacAlgSHA256 withKey:key];
//    
//}
//- (NSString *)at_hmacSHA384StringWithKey:(NSString *)key{
//    return [self at_hmacStringUsingAlg:kCCHmacAlgSHA384 withKey:key];
//}
//- (NSString *)at_hmacSHA512StringWithKey:(NSString *)key{
//    return [self at_hmacStringUsingAlg:kCCHmacAlgSHA512 withKey:key];
//    
//}
//#pragma mark - Helpers
//- (NSString *)at_hmacStringUsingAlg:(CCHmacAlgorithm)alg withKey:(NSString *)key {
//    size_t size;
//    switch (alg) {
//        case kCCHmacAlgMD5: size = CC_MD5_DIGEST_LENGTH; break;
//        case kCCHmacAlgSHA1: size = CC_SHA1_DIGEST_LENGTH; break;
//        case kCCHmacAlgSHA224: size = CC_SHA224_DIGEST_LENGTH; break;
//        case kCCHmacAlgSHA256: size = CC_SHA256_DIGEST_LENGTH; break;
//        case kCCHmacAlgSHA384: size = CC_SHA384_DIGEST_LENGTH; break;
//        case kCCHmacAlgSHA512: size = CC_SHA512_DIGEST_LENGTH; break;
//        default: return nil;
//    }
//    
//    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *messageData = [self dataUsingEncoding:NSUTF8StringEncoding];
//    NSMutableData *mutableData = [NSMutableData dataWithLength:size];
//    CCHmac(alg, keyData.bytes, keyData.length, messageData.bytes, messageData.length, mutableData.mutableBytes);
//    return [self at_stringFromBytes:(unsigned char *)mutableData.bytes length:(int)mutableData.length];
//}
//- (NSString *)at_stringFromBytes:(unsigned char *)bytes length:(int)length{
//    NSMutableString *mutableString = @"".mutableCopy;
//    for (int i = 0; i < length; i++)
//        [mutableString appendFormat:@"%02x", bytes[i]];
//    return [NSString stringWithString:mutableString];
//}

//// 字符串转base64（加密）
//+ (NSString *)base64StringFromText:(NSString *)text
//{
//    if (text && ![text isEqualToString:LocalStr_None]) {
//        //取项目的bundleIdentifier作为KEY  改动了此处
//        //NSString *key = [[NSBundle mainBundle] bundleIdentifier];
//        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
//        //IOS 自带DES加密 Begin  改动了此处
//        //data = [self DESEncrypt:data WithKey:key];
//        //IOS 自带DES加密 End
//        return [self base64EncodedStringFrom:data];
//    }
//    else {
//        return LocalStr_None;
//    }
//}
//
//// base64转字符串（解密）
//+ (NSString *)textFromBase64String:(NSString *)base64
//{
//    if (base64 && ![base64 isEqualToString:LocalStr_None]) {
//        //取项目的bundleIdentifier作为KEY   改动了此处
//        //NSString *key = [[NSBundle mainBundle] bundleIdentifier];
//        NSData *data = [self dataWithBase64EncodedString:base64];
//        //IOS 自带DES解密 Begin    改动了此处
//        //data = [self DESDecrypt:data WithKey:key];
//        //IOS 自带DES加密 End
//        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    }
//    else {
//        return LocalStr_None;
//    }
//}
//
///******************************************************************************
// 函数名称 : + (NSData *)dataWithBase64EncodedString:(NSString *)string
// 函数描述 : base64格式字符串转换为文本数据
// 输入参数 : (NSString *)string
// 输出参数 : N/A
// 返回参数 : (NSData *)
// 备注信息 :
// ******************************************************************************/
//+ (NSData *)dataWithBase64EncodedString:(NSString *)string
//{
//    if (string == nil)
//        [NSException raise:NSInvalidArgumentException format:nil];
//    if ([string length] == 0)
//        return [NSData data];
//    
//    static char *decodingTable = NULL;
//    if (decodingTable == NULL)
//        {
//        decodingTable = malloc(256);
//        if (decodingTable == NULL)
//            return nil;
//        memset(decodingTable, CHAR_MAX, 256);
//        NSUInteger i;
//        for (i = 0; i < 64; i++)
//            decodingTable[(short)encodingTable[i]] = i;
//        }
//    
//    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
//    if (characters == NULL)     //  Not an ASCII string!
//        return nil;
//    char *bytes = malloc((([string length] + 3) / 4) * 3);
//    if (bytes == NULL)
//        return nil;
//    NSUInteger length = 0;
//    
//    NSUInteger i = 0;
//    while (YES)
//        {
//        char buffer[4];
//        short bufferLength;
//        for (bufferLength = 0; bufferLength < 4; i++)
//            {
//            if (characters[i] == '\0')
//                break;
//            if (isspace(characters[i]) || characters[i] == '=')
//                continue;
//            buffer[bufferLength] = decodingTable[(short)characters[i]];
//            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
//                {
//                free(bytes);
//                return nil;
//                }
//            }
//        
//        if (bufferLength == 0)
//            break;
//        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
//            {
//            free(bytes);
//            return nil;
//            }
//        
//        //  Decode the characters in the buffer to bytes.
//        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
//        if (bufferLength > 2)
//            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
//        if (bufferLength > 3)
//            bytes[length++] = (buffer[2] << 6) | buffer[3];
//        }
//    
//    bytes = realloc(bytes, length);
//    return [NSData dataWithBytesNoCopy:bytes length:length];
//}
//
///******************************************************************************
// 函数名称 : + (NSString *)base64EncodedStringFrom:(NSData *)data
// 函数描述 : 文本数据转换为base64格式字符串
// 输入参数 : (NSData *)data
// 输出参数 : N/A
// 返回参数 : (NSString *)
// 备注信息 :
// ******************************************************************************/
//+ (NSString *)base64EncodedStringFrom:(NSData *)data
//{
//    if ([data length] == 0)
//        return @"";
//    
//    char *characters = malloc((([data length] + 2) / 3) * 4);
//    if (characters == NULL)
//        return nil;
//    NSUInteger length = 0;
//    
//    NSUInteger i = 0;
//    while (i < [data length])
//        {
//        char buffer[3] = {0,0,0};
//        short bufferLength = 0;
//        while (bufferLength < 3 && i < [data length])
//            buffer[bufferLength++] = ((char *)[data bytes])[i++];
//        
//        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
//        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
//        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
//        if (bufferLength > 1)
//            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
//        else characters[length++] = '=';
//        if (bufferLength > 2)
//            characters[length++] = encodingTable[buffer[2] & 0x3F];
//        else characters[length++] = '=';
//        }
//    
//    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
//}



#pragma mark -
#pragma mark - 汉字转拼音
+(NSString *)stringWithMetaString:(NSString *)metaString count:(NSUInteger)count{
    return [@"" stringByPaddingToLength:(metaString.length * count) withString:metaString startingAtIndex:0];
}

+(NSString *)stringWithRandomCharacterWithLength:(NSUInteger)length {
    char data[length];
    for (int i = 0; i < length; i ++) {
        int ran = arc4random() % 62;
        if (ran < 10) {
            ran += 48;
        } else if (ran < 36) {
            ran += 55;
        } else {
            ran += 61;
        }
        data[i] = (char)ran;
    }
    return [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
}

-(NSString *)at_FixFileNameStringWithIndex:(NSUInteger)idx {
    NSString * extention = [self pathExtension];
    NSString * pureStr = [self stringByDeletingPathExtension];
    pureStr = [pureStr stringByAppendingString:[NSString stringWithFormat:@"_%02lu",(unsigned long)idx]];
    return [pureStr stringByAppendingPathExtension:extention];
}

-(NSString *)at_TransferChineseToPinYinWithWhiteSpace:(BOOL)neeAThiteSpace tone:(BOOL)tone {
    if (!self.wordArray.count) {
        return nil;
    }
    __block NSString * string = @"";
    NSString * whiteSpace = neeAThiteSpace ? @" " : @"";
    [self.wordArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * pinyin = [obj transferWordToPinYinWithTone:tone];
        if (!string.length) {
            string = [string stringByAppendingString:[NSString stringWithString:pinyin]];
        } else {
            string = [string stringByAppendingString:[NSString stringWithFormat:@"%@%@",whiteSpace,pinyin]];
        }
    }];
    return string;
}

-(NSArray<NSTextCheckingResult *> *)at_RangesConfirmToPattern:(NSString *)pattern {
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    return [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
}

-(NSArray<NSString *> *)at_SubStringConfirmToPattern:(NSString *)pattern {
    NSArray * ranges = [self at_RangesConfirmToPattern:pattern];
    NSMutableArray * strings = [NSMutableArray array];
    for (NSTextCheckingResult * result in ranges) {
        [strings addObject:[self substringWithRange:result.range]];
    }
    return strings;
}

-(NSArray *)at_TrimStringToWord {
    if (self.length) {
        NSMutableArray * temp = [NSMutableArray array];
        [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByWords usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            if (substring.length > 1 && temp.count == 0 && ![substring at_StringIsChinese] && [substring at_SubStringConfirmToPattern:@"[\\u4E00-\\u9FA5]+"].count > 0) {///为防止第一个字与英文连在一起
                [temp addObject:[substring substringToIndex:1]];
                [temp addObject:[substring substringFromIndex:1]];
            } else {
                if (substring.length > 1 && [substring at_StringIsChinese]) {
                    [substring enumerateSubstringsInRange:NSMakeRange(0, substring.length) options:(NSStringEnumerationByComposedCharacterSequences) usingBlock:^(NSString * _Nullable substring2, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                        [temp addObject:substring2];
                    }];
                } else {
                    if (substring.length) {
                        [temp addObject:substring];
                    }
                }
            }
        }];
        return [temp copy];
    }
    return nil;
}

-(BOOL)at_StringIsChinese {
    if (self.length == 0) {
        return NO;
    }
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[\\u4E00-\\u9FA5]+"];
    return [predicate evaluateWithObject:self];
}

-(NSString *)at_StringByReplacingCharactersInArray:(NSArray *)characters withString:(NSString *)temp {
    if (characters.count == 0) {
        return nil;
    }
    NSString * pattern = [characters componentsJoinedByString:@","];
    pattern = [@"[" stringByAppendingString:pattern];
    pattern = [pattern stringByAppendingString:@"]"];
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionCaseInsensitive) error:nil];
    return [regex stringByReplacingMatchesInString:self options:(NSMatchingReportProgress) range:NSMakeRange(0, self.length) withTemplate:temp];
}

-(NSString *)at_StringByTrimmingWhitespace {
    NSString * temp = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *components = [temp componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
    return [components componentsJoinedByString:@" "];
}

#pragma mark --- setter/getter ---
-(void)setPinyinString:(NSString *)pinyinString {
    objc_setAssociatedObject(self, @selector(pinyinString), pinyinString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)pinyinString {
    NSString * pinyin = objc_getAssociatedObject(self, _cmd);
    if (!pinyin) {
        pinyin = [self at_TransferChineseToPinYinWithWhiteSpace:YES tone:YES];
        objc_setAssociatedObject(self, @selector(pinyinString), pinyin, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return pinyin;
}

#pragma mark --- tool method ---
-(NSString *)transferWordToPinYinWithTone:(BOOL)tone {
    if (tone && self.wordPinyinWithTone) {
        return self.wordPinyinWithTone;
    } else if (!tone && self.wordPinyinWithoutTone) {
        return self.wordPinyinWithoutTone;
    }
    NSMutableString * mutableString = [[NSMutableString alloc] initWithString:self];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    NSStringCompareOptions toneOption = tone ?NSCaseInsensitiveSearch:NSDiacriticInsensitiveSearch;
    NSString * pinyin = [mutableString stringByFoldingWithOptions:toneOption locale:[NSLocale currentLocale]];
    if (tone) {
        self.wordPinyinWithTone = pinyin;
    } else {
        self.wordPinyinWithoutTone = pinyin;
    }
    return pinyin;
}

+(NSMutableArray *)at_SortedStringsInPinyin:(NSArray<NSString *> *)strings {
    NSMutableArray * newStrings = [NSMutableArray arrayWithArray:strings];
    ///按拼音/汉字排序指定范围联系人
    [newStrings sortUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        return [obj1 at_ComparedInPinyinWithString:obj2 considerTone:YES];
    }];
    return newStrings;
}

-(NSComparisonResult)at_ComparedInPinyinWithString:(NSString *)string considerTone:(BOOL)tone {
    if ([self isEqualToString:string]) {
        return NSOrderedSame;
    }
    NSArray <NSString *>* arr1 = self.wordArray;
    NSArray <NSString *>* arr2 = string.wordArray;
    NSUInteger minL = MIN(arr1.count, arr2.count);
    for (int i = 0; i < minL; i ++) {
        if ([arr1[i] isEqualToString:arr2[i]]) {
            continue;
        }
        NSString * pinyin1 = [arr1[i] transferWordToPinYinWithTone:tone];
        NSString * pinyin2 = [arr2[i] transferWordToPinYinWithTone:tone];
        if (tone) {
            pinyin1 = transformPinyinTone(pinyin1);
            pinyin2 = transformPinyinTone(pinyin2);
        }
        NSComparisonResult result = [pinyin1 caseInsensitiveCompare:pinyin2];
        if (result != NSOrderedSame) {
            return result;
        } else {
            result = [arr1[i] localizedCompare:arr2[i]];
            if (result != NSOrderedSame) {
                return result;
            }
        }
    }
    if (arr1.count < arr2.count) {
        return NSOrderedAscending;
    } else if (arr1.count > arr2.count) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

-(NSComparisonResult)at_ComparedInPinyinWithString:(NSString *)string {
    return [self at_ComparedInPinyinWithString:string considerTone:YES];
}

-(void)setWordPinyinWithTone:(NSString *)wordPinyinWithTone {
    objc_setAssociatedObject(self, @selector(wordPinyinWithTone), wordPinyinWithTone, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)wordPinyinWithTone {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setWordPinyinWithoutTone:(NSString *)wordPinyinWithoutTone {
    objc_setAssociatedObject(self, @selector(wordPinyinWithoutTone), wordPinyinWithoutTone, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)wordPinyinWithoutTone {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setWordArray:(NSArray *)wordArray {
    objc_setAssociatedObject(self, @selector(wordArray), wordArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSArray *)wordArray {
    NSArray * array = objc_getAssociatedObject(self, _cmd);
    if (!array) {
        array = [self at_TrimStringToWord];
        objc_setAssociatedObject(self, @selector(wordArray), array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

#pragma mark --- inline method ---
static NSString * transformPinyinTone(NSString * pinyin) {
    replaceIfContains(pinyin, @"ā", @"a",1);
    replaceIfContains(pinyin, @"á", @"a",2);
    replaceIfContains(pinyin, @"ǎ", @"a",3);
    replaceIfContains(pinyin, @"à", @"a",4);
    replaceIfContains(pinyin, @"ō", @"o",1);
    replaceIfContains(pinyin, @"ó", @"o",2);
    replaceIfContains(pinyin, @"ǒ", @"o",3);
    replaceIfContains(pinyin, @"ò", @"o",4);
    replaceIfContains(pinyin, @"ē", @"e",1);
    replaceIfContains(pinyin, @"é", @"e",2);
    replaceIfContains(pinyin, @"ě", @"e",3);
    replaceIfContains(pinyin, @"è", @"e",4);
    replaceIfContains(pinyin, @"ī", @"i",1);
    replaceIfContains(pinyin, @"í", @"i",2);
    replaceIfContains(pinyin, @"ǐ", @"i",3);
    replaceIfContains(pinyin, @"ì", @"i",4);
    replaceIfContains(pinyin, @"ū", @"u",1);
    replaceIfContains(pinyin, @"ú", @"u",2);
    replaceIfContains(pinyin, @"ǔ", @"u",3);
    replaceIfContains(pinyin, @"ù", @"u",4);
    return pinyin;
}


@end

//
//  AttributeStringBuilder.h
//  SCRAttributedStringBuilderDemo
//
//  Created by Mars on 2023/3/24.
//  Copyright © 2023 Chuanren Shang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 富文本构建器，提供链式调用接口
@interface AttributeStringBuilder : NSObject

/// 计算文本高度
/// @param attributedString 富文本
/// @param width 宽度
+ (CGSize)calculateForAttributedString:(NSAttributedString *)attributedString withWidth:(CGFloat)width;

/// 提交并返回最终富文本
- (NSAttributedString *)commit;

/// 获取当前 NSRange
- (NSRange)currentRange;

#pragma mark - Content

/// 创建一个 Attributed String
+ (AttributeStringBuilder *(^)(NSString *))build;

/// 尾部追加一个新的 Attributed String
- (AttributeStringBuilder *(^)(NSString *))append;

/// 尾部追加 NSAttributedString
- (AttributeStringBuilder *(^)(NSAttributedString *))attributedAppend;

/// 插入一个新的 Attributed String
- (AttributeStringBuilder *(^)(NSString *, NSUInteger index))insert;

/// 增加间隔，spacing 的单位是 point
- (AttributeStringBuilder *(^)(CGFloat))appendSpacing;

/// 尾部追加一个附件
- (AttributeStringBuilder *(^)(NSTextAttachment *))appendAttachment;

/// 在尾部追加图片附件，默认使用图片尺寸，图片垂直居中
- (AttributeStringBuilder *(^)(UIImage *))appendImage;

/// 在尾部追加图片附件，可以自定义尺寸
- (AttributeStringBuilder *(^)(UIImage *, CGSize))appendSizeImage;

/// 在尾部追加图片附件，可以自定义想对齐的字体
- (AttributeStringBuilder *(^)(UIImage *, UIFont *))appendFontImage;

/// 在尾部追加图片附件，可以自定义尺寸和想对齐的字体
- (AttributeStringBuilder *(^)(UIImage *, CGSize, UIFont *))appendCustomImage;

/// 在 index 位置插入图片附件
- (AttributeStringBuilder *(^)(UIImage *, CGSize, NSUInteger, UIFont *))insertImage;

/// 在当前 Range 的头部插入图片附件
- (AttributeStringBuilder *(^)(UIImage *, CGSize, UIFont *))headInsertImage;

#pragma mark - Range

/// 根据 start 和 length 设置范围
- (AttributeStringBuilder *(^)(NSInteger, NSInteger))range;

/// 从结尾倒数location 、 length 设置范围
- (AttributeStringBuilder *(^)(NSInteger, NSInteger))lastRange;

/// 将范围设置为当前字符串全部
- (AttributeStringBuilder *)all;

/// 匹配所有符合的字符串
- (AttributeStringBuilder *(^)(NSString *))match;

/// 从头开始匹配第一个符合的字符串
- (AttributeStringBuilder *(^)(NSString *))matchFirst;

/// 从尾开始匹配第一个符合的字符串
- (AttributeStringBuilder *(^)(NSString *))matchLast;

/// 正则表达式匹配
- (AttributeStringBuilder *(^)(NSString *regularExpression, BOOL all))regular;

#pragma mark - Basic

/// 字体
- (AttributeStringBuilder *(^)(UIFont *))font;

/// 字号，默认字体
- (AttributeStringBuilder *(^)(CGFloat))fontSize;

/// 字号，粗体
- (AttributeStringBuilder *(^)(CGFloat boldFontSize))boldFontSize;

/// 字体颜色
- (AttributeStringBuilder *(^)(UIColor *))color;

/// 字体颜色，16 进制
- (AttributeStringBuilder *(^)(NSInteger))hexColor;

/// 背景颜色
- (AttributeStringBuilder *(^)(UIColor *))backgroundColor;

#pragma mark - Background Image Methods

/// 绘制带圆角边框和居中文本的自定义图片
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, CGFloat offsetY))appendBackgroundColor;

/// 绘制带圆角边框和居中文本的自定义图片（文本内边距）
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor * _Nullable textColor, UIColor * _Nullable fillColor, CGFloat radius, UIEdgeInsets insets, CGFloat offsetY))appendBackgroundInsetsColor;

/// 绘制带圆角边框和居中文本的自定义图片（文本边距、边框以外的边距）
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor * _Nullable textColor, UIColor * _Nullable fillColor, CGFloat radius, UIEdgeInsets insets, UIEdgeInsets margins, CGFloat offsetY))appendBackgroundMarginsColor;

/// 绘制带圆角边框和居中文本的自定义图片（固定大小）
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, CGSize imgSize, CGFloat offsetY))appendBackgroundSize;

/// 绘制带圆角边框和居中文本的自定义图片（自定义圆角方向）
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIRectCorner corners, CGFloat offsetY))appendBackgroundCornerColor;

/// 绘制带圆角边框和居中文本的自定义图片（自定义圆角方向和大小）
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIRectCorner corners, CGSize imgSize, CGFloat offsetY))appendBackgroundCornerSize;

/// 绘制带圆角边框和居中文本的自定义图片（完整参数）
- (AttributeStringBuilder *(^)(NSString *text, UIFont *font, UIColor *textColor, UIColor *fillColor, CGFloat radius, UIRectCorner corners, CGSize imgSize, UIEdgeInsets insets, UIEdgeInsets margins, UIColor *strokeColor, CGFloat lineWidth, CGFloat offsetY))appendBackgroundRadiusColor;

#pragma mark - Glyph

/// 删除线风格
- (AttributeStringBuilder *(^)(NSUnderlineStyle))strikethroughStyle;

/// 删除线颜色
- (AttributeStringBuilder *(^)(UIColor *))strikethroughColor;

/// 下划线风格
- (AttributeStringBuilder *(^)(NSUnderlineStyle))underlineStyle;

/// 下划线颜色
- (AttributeStringBuilder *(^)(UIColor *))underlineColor;

/// 字形边框颜色
- (AttributeStringBuilder *(^)(UIColor *))strokeColor;

/// 字形边框宽度
- (AttributeStringBuilder *(^)(CGFloat))strokeWidth;

/// 设置文本特殊效果
- (AttributeStringBuilder *(^)(NSString *))textEffect;

/// 阴影
- (AttributeStringBuilder *(^)(NSShadow *))shadow;

/// 链接URL对象 NSURL
- (AttributeStringBuilder *(^)(NSURL *))link;

/// 链接URL 字符串
- (AttributeStringBuilder *(^)(NSString *))linkUrlStr;

#pragma mark - Paragraph

/// 行间距
- (AttributeStringBuilder *(^)(CGFloat))lineSpacing;

/// 段间距
- (AttributeStringBuilder *(^)(CGFloat))paragraphSpacing;

/// 对齐
- (AttributeStringBuilder *(^)(NSTextAlignment))alignment;

/// 换行
- (AttributeStringBuilder *(^)(NSLineBreakMode))lineBreakMode;

/// 段第一行头部缩进
- (AttributeStringBuilder *(^)(CGFloat))firstLineHeadIndent;

/// 段第一行头部缩进字符数
- (AttributeStringBuilder *(^)(NSInteger, UIFont *))firstLineHeadIndentCharacters;

/// 段头部缩进 后续行的左边距
- (AttributeStringBuilder *(^)(CGFloat))headIndent;

/// 段头部缩进字符数 后续行的左边距
- (AttributeStringBuilder *(^)(NSInteger, UIFont *))headIndentCharacters;

/// 段尾部缩进
- (AttributeStringBuilder *(^)(CGFloat))tailIndent;

/// 行高
- (AttributeStringBuilder *(^)(CGFloat))lineHeight;

#pragma mark - Special

/// 基线偏移
- (AttributeStringBuilder *(^)(CGFloat))baselineOffset;

/// 连字
- (AttributeStringBuilder *(^)(CGFloat))ligature;

/// 字间距
- (AttributeStringBuilder *(^)(CGFloat))kern;

/// 动态添加字间距
- (AttributeStringBuilder *(^)(NSString *baseText, NSString *dynamicText, UIFont *font))dynamicKern;

/// 添加文字并设置字间距
- (AttributeStringBuilder *(^)(NSString *baseText, NSString *dynamicText, UIFont *font))appendDynamicKern;

/// 倾斜
- (AttributeStringBuilder *(^)(CGFloat))obliqueness;

/// 扩张（压缩文字，正值为伸，负值为缩）
- (AttributeStringBuilder *(^)(CGFloat))expansion;

@end

NS_ASSUME_NONNULL_END

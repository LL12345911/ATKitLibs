//
//  UIImage+ATKit.h
//  HighwayDoctor
//
//  Created by Mars on 2019/5/22.
//  Copyright © 2019 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompletionBlock)( NSError *error);

typedef NS_ENUM(NSUInteger ,GradientType) {
    topToBottom = 0,//从上到小
    leftToRight = 1,//从左到右
    upleftTolowRight = 2,//左上到右下
    uprightTolowLeft = 3,//右上到左下
};

@interface UIColor(Additions)
- (BOOL)isBlackOrWhite;
@end

@interface UIImage (ATKit)


///** 根据颜色生成纯色图片 */
//+ (UIImage *)imageWithColor:(UIColor *)color;

/** 取图片某一像素的颜色 */
- (UIColor *)colorAtPixel:(CGPoint)point;

/** 获得灰度图 */
- (UIImage *)convertToGrayImage;

/** 改变图片的颜色 */
-(UIImage*)imageChangeColor:(UIColor*)color;

/**
 *   纯色图片
 */
+ (UIImage *) imageWithColor:(UIColor *)color;
+ (UIImage *) imageWithColor:(UIColor *)color size:(CGSize)size andRoundSize:(CGFloat)roundSize;

+ (UIImage *) imageWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;
+ (UIImage *) buttonImageWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius shadowColor:(UIColor *)shadowColor shadowInsets:(UIEdgeInsets)shadowInsets;
+ (UIImage *) circularImageWithColor:(UIColor *)color size:(CGSize)size;
- (UIImage *) imageWithMinimumSize:(CGSize)size;
+ (UIImage *) stepperPlusImageWithColor:(UIColor *)color;
+ (UIImage *) stepperMinusImageWithColor:(UIColor *)color;
+ (UIImage *) backButtonImageWithColor:(UIColor *)color barMetrics:(UIBarMetrics) metrics cornerRadius:(CGFloat)cornerRadius;

- (UIImage *) imageTintedWithColor:(UIColor *)color;
- (UIImage *) imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;
//渐变
+(UIImage*) imageWithFrame:(CGSize)size Colors:(NSArray*)colors GradientType:(GradientType)gradientType;

- (id)roundedSize:(CGSize)size radius:(NSInteger)r;
/**
 获取图片上某一点的颜色
 
 @param point  图片内的一个点。范围是 [0, image.width-1],[0, image.height-1]
 超出图片范围则返回nil
 */
- (UIColor *) getPixelColorAtLocation:(CGPoint)point;

- (instancetype)imageWithOverlayColor:(UIColor *)overlayColor;
/**
 *  根据颜色返回一张图片
 *  @param color 颜色
 *  @param rect  大小
 *  @return 背景图片
 */
+ (UIImage *)createImageWithColor:(UIColor *)color rect:(CGRect)rect;
/**
 *  保存图片到相册
 */
-(void)imageWriteToSavedPhotosAlbum:(UIImage *)image result:(CompletionBlock) completionBlock;

#pragma mark - Some Useful Method
/**
 *  Scale image with fixed width.
 *  @param width The fixed width you give.
 *  @return Scaled image.
 */
- (UIImage *)scaleWithFixedWidth:(CGFloat)width;

/**
 *  Scale image with fixed height.
 *  @param height The fixed height you give.
 *  @return Scaled image.
 */
- (UIImage *)scaleWithFixedHeight:(CGFloat)height;

/**
 *  Get the image average color.
 *  @return Average color from the image.
 */
- (UIColor *)averageColor;

/**
 *  Get cropped image at specified frame.
 *  @param frame The specified frame that you use to crop.
 *  @return Cropped image
 */
- (UIImage *)croppedImageAtFrame:(CGRect)frame;





#pragma mark - blur image

//- (UIImage *)at_lightImage;
//- (UIImage *)at_extraLightImage;
//- (UIImage *)at_darkImage;
//- (UIImage *)at_tintedImageWithColor:(UIColor *)tintColor;
//
//- (UIImage *)at_blurredImageWithRadius:(CGFloat)blurRadius;
//- (UIImage *)at_blurredImageWithSize:(CGSize)blurSize;
//- (UIImage *)at_blurredImageWithSize:(CGSize)blurSize
//                           tintColor:(UIColor *)tintColor
//               saturationDeltaFactor:(CGFloat)saturationDeltaFactor
//                           maskImage:(UIImage *)maskImage;
//
//#pragma mark - Blur
//- (UIImage *)at_blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;



#pragma mark - 修正图片的方向
///**
// *  @brief  修正图片的方向
// *  @param srcImg 图片
// *  @return 修正方向后的图片
// */
//+ (UIImage *)at_fixOrientation:(UIImage *)srcImg;
///**
// *  @brief  旋转图片
// *  @param degrees 角度
// *  @return 旋转后图片
// */
//- (UIImage *)at_imageRotatedByDegrees:(CGFloat)degrees;
///**
// *  @brief  旋转图片
// *  @param radians 弧度
// *  @return 旋转后图片
// */
//- (UIImage *)at_imageRotatedByRadians:(CGFloat)radians;
///**
// *  @brief  垂直翻转
// *  @return  翻转后的图片
// */
//- (UIImage *)at_flipVertical;
///**
// *  @brief  水平翻转
// *  @return 翻转后的图片
// */
//- (UIImage *)at_flipHorizontal;
///**
// *  @brief  角度转弧度
// *  @param degrees 角度
// *  @return 弧度
// */
//+(CGFloat)at_degreesToRadians:(CGFloat)degrees;
///**
// *  @brief  弧度转角度
// *  @param radians 弧度
// *  @return 角度
// */
//+(CGFloat)at_radiansToDegrees:(CGFloat)radians;

/**
 设置图片旋转角度
 @param Angle 旋转的角度（0~360）
 @return 旋转后的图片
 */
- (UIImage*)at_RotatingImages:(CGFloat)Angle;



#pragma mark -
#pragma mark - 图片裁剪
///**
// *  改变Image的任何的大小
// *  @param size 目的大小
// *  @return 修改后的Image
// */
//- (UIImage *)at_cropImageWithAnySize:(CGSize)size;
///**
// *  裁剪和拉升图片
// */
//- (UIImage*)at_imageByScalingAndCroppingForTargetSize:(CGSize)targetSize;
///**
// *  返回圆形图片 直接操作layer.masksToBounds = YES 会比较卡顿
// */
//- (UIImage *)at_circleImage;
///**
// *  根据图片名返回一张能够自由拉伸的图片 (从中间拉伸)
// */
//+ (UIImage *)at_resizableImage:(NSString *)imgName;
///**
// *  根据图片名返回一张能够自由拉伸的图片
// */
//+ (UIImage *)at_resizableImage:(NSString *)imgName xPos:(CGFloat)xPos yPos:(CGFloat)yPos;
///**
// *  获取视频第一帧图片
// */
//+ (UIImage *)at_getVideoFirstThumbnailImageWithVideoUrl:(NSURL *)videoUrl;
///**
// *  图片不被渲染
// */
//+ (UIImage *)at_imageAlwaysShowOriginalImageWithImageName:(NSString *)imageName;
///**
// *  根据图片和颜色返回一张加深颜色以后的图片
// *  图片着色
// */
//+ (UIImage *)at_colorizeImageWithSourceImage:(UIImage *)sourceImage color:(UIColor *)color;
///**
// *  根据指定的图片颜色和图片大小获取指定的Image
// *  @param color 颜色
// *  @param size  大小
// */
//+ (UIImage *)at_getImageWithColor:(UIColor *)color size:(CGSize)size;
///**
// *  通过传入一个图片对象获取一张缩略图
// */
//+ (UIImage *)at_getThumbnailImageWithImageObj:(id)imageObj;
///**
// *  通过传入一个图片对象获取一张原始图
// */
//+ (UIImage *)at_getOriginalImageWithImageObj:(id)imageObj;
///**
// *  将图片旋转到指定的方向
// *  @param sourceImage 要旋转的图片
// *  @param orientation 旋转方向
// *  @return 返回旋转后的图片
// */
//+ (UIImage *)at_fixImageOrientationWithSourceImage:(UIImage *)sourceImage orientation:(UIImageOrientation)orientation;
/**
 *  屏幕截图
 */
+ (instancetype)at_captureScreen:(UIView *)view;


#pragma mark -
#pragma mark - 添加水印文字
//// 给图片添加文字水印：
//+ (UIImage *)at_WaterImageWithImage:(UIImage *)image text:(NSString *)text textPoint:(CGPoint)point attributedString:(NSDictionary * )attributed;
//
//
//// 给图片添加图片水印
//+ (UIImage *)at_WaterImageWithImage:(UIImage *)image waterImage:(UIImage *)waterImage waterImageRect:(CGRect)rect;
//
///**
// *  打水印
// *
// *  @param backgroundImage   背景图片
// *  @param markName 右下角的水印图片
// */
//+ (instancetype)at_WaterMarkWithImageName:(NSString *)backgroundImage andMarkImageName:(NSString *)markName;

/** 根据图片二进制流获取图片格式 */
+ (NSString *)imageTypeWithData:(NSData *)data;


@end

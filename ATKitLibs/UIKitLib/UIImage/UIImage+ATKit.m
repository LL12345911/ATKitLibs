
    //
//  UIImage+ATKit.m
//  HighwayDoctor
//
//  Created by Mars on 2019/5/22.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "UIImage+ATKit.h"
#import <float.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <Photos/Photos.h>
#import <CoreImage/CoreImage.h>

//@import Accelerate;
#import <Accelerate/Accelerate.h>

// 图片裁剪
//static NSTimeInterval const MHThumbnailImageTime = 10.0f;


@implementation UIImage (ATKit)


/** 取图片某一像素的颜色 */
- (UIColor *)colorAtPixel:(CGPoint)point
{
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point))
    {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/** 获得灰度图 */
- (UIImage *)convertToGrayImage
{
    int width = self.size.width;
    int height = self.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil,width,height,8,0,colorSpace,kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL)
    {
        return nil;
    }
    
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), self.CGImage);
    CGImageRef contextRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:contextRef];
    CGContextRelease(context);
    CGImageRelease(contextRef);
    
    return grayImage;
}


/** 改变图片的颜色 */
-(UIImage*)imageChangeColor:(UIColor*)color {
    
    //获取画布
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    //画笔沾取颜色
    [color setFill];
    
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    //绘制一次
    [self drawInRect:bounds blendMode:kCGBlendModeOverlay alpha:1.0f];
    //再绘制一次
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    //获取图片
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size andRoundSize:(CGFloat)roundSize {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (roundSize > 0) {
        UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius: roundSize];
        [color setFill];
        [roundedRectanglePath fill];
    } else {
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

static CGFloat edgeSizeFromCornerRadius(CGFloat cornerRadius) {
    return cornerRadius * 2 + 1;
}

+ (UIImage *)imageWithColor:(UIColor *)color
               cornerRadius:(CGFloat)cornerRadius {
    CGFloat minEdgeSize = edgeSizeFromCornerRadius(cornerRadius);
    CGRect rect = CGRectMake(0, 0, minEdgeSize, minEdgeSize);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    roundedRect.lineWidth = 0;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    [color setFill];
    [roundedRect fill];
    [roundedRect stroke];
    [roundedRect addClip];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)];
}

+ (UIImage *) buttonImageWithColor:(UIColor *)color
                      cornerRadius:(CGFloat)cornerRadius
                       shadowColor:(UIColor *)shadowColor
                      shadowInsets:(UIEdgeInsets)shadowInsets {
    
    UIImage *topImage = [self imageWithColor:color cornerRadius:cornerRadius];
    UIImage *bottomImage = [self imageWithColor:shadowColor cornerRadius:cornerRadius];
    CGFloat totalHeight = edgeSizeFromCornerRadius(cornerRadius) + shadowInsets.top + shadowInsets.bottom;
    CGFloat totalWidth = edgeSizeFromCornerRadius(cornerRadius) + shadowInsets.left + shadowInsets.right;
    CGFloat topWidth = edgeSizeFromCornerRadius(cornerRadius);
    CGFloat topHeight = edgeSizeFromCornerRadius(cornerRadius);
    CGRect topRect = CGRectMake(shadowInsets.left, shadowInsets.top, topWidth, topHeight);
    CGRect bottomRect = CGRectMake(0, 0, totalWidth, totalHeight);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(totalWidth, totalHeight), NO, 0.0f);
    if (!CGRectEqualToRect(bottomRect, topRect)) {
        [bottomImage drawInRect:bottomRect];
    }
    [topImage drawInRect:topRect];
    UIImage *buttonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIEdgeInsets resizeableInsets = UIEdgeInsetsMake(cornerRadius + shadowInsets.top,
                                                     cornerRadius + shadowInsets.left,
                                                     cornerRadius + shadowInsets.bottom,
                                                     cornerRadius + shadowInsets.right);
    return [buttonImage resizableImageWithCapInsets:resizeableInsets];
    
}

+ (UIImage *) circularImageWithColor:(UIColor *)color
                                size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:rect];
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    [color setFill];
    [color setStroke];
    [circle addClip];
    [circle fill];
    [circle stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *) imageWithMinimumSize:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, 0.0f);
    [self drawInRect:rect];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    return [resized resizableImageWithCapInsets:UIEdgeInsetsMake(size.height/2, size.width/2, size.height/2, size.width/2)];
}

+ (UIImage *) stepperPlusImageWithColor:(UIColor *)color {
    CGFloat iconEdgeSize = 15;
    CGFloat iconInternalEdgeSize = 3;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(iconEdgeSize, iconEdgeSize), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGFloat padding = (iconEdgeSize - iconInternalEdgeSize) / 2;
    CGContextFillRect(context, CGRectMake(padding, 0, iconInternalEdgeSize, iconEdgeSize));
    CGContextFillRect(context, CGRectMake(0, padding, iconEdgeSize, iconInternalEdgeSize));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *) stepperMinusImageWithColor:(UIColor *)color {
    CGFloat iconEdgeSize = 15;
    CGFloat iconInternalEdgeSize = 3;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(iconEdgeSize, iconEdgeSize), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGFloat padding = (iconEdgeSize - iconInternalEdgeSize) / 2;
    CGContextFillRect(context, CGRectMake(0, padding, iconEdgeSize, iconInternalEdgeSize));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *) backButtonImageWithColor:(UIColor *)color
                            barMetrics:(UIBarMetrics) metrics
                          cornerRadius:(CGFloat)cornerRadius {
    
    CGSize size;
    if (metrics == UIBarMetricsDefault) {
        size = CGSizeMake(50, 30);
    }
    else {
        size = CGSizeMake(60, 23);
    }
    UIBezierPath *path = [self bezierPathForBackButtonInRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:cornerRadius];
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [color setFill];
    [path addClip];
    [path fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(cornerRadius, 15, cornerRadius, cornerRadius)];
    
}

+ (UIBezierPath *) bezierPathForBackButtonInRect:(CGRect)rect cornerRadius:(CGFloat)radius {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint mPoint = CGPointMake(CGRectGetMaxX(rect) - radius, rect.origin.y);
    CGPoint ctrlPoint = mPoint;
    [path moveToPoint:mPoint];
    
    ctrlPoint.y += radius;
    mPoint.x += radius;
    mPoint.y += radius;
    if (radius > 0) [path addArcWithCenter:ctrlPoint radius:radius startAngle:M_PI + M_PI_2 endAngle:0 clockwise:YES];
    
    mPoint.y = CGRectGetMaxY(rect) - radius;
    [path addLineToPoint:mPoint];
    
    ctrlPoint = mPoint;
    mPoint.y += radius;
    mPoint.x -= radius;
    ctrlPoint.x -= radius;
    if (radius > 0) [path addArcWithCenter:ctrlPoint radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    
    mPoint.x = rect.origin.x + (10.0f);
    [path addLineToPoint:mPoint];
    
    [path addLineToPoint:CGPointMake(rect.origin.x, CGRectGetMidY(rect))];
    
    mPoint.y = rect.origin.y;
    [path addLineToPoint:mPoint];
    
    [path closePath];
    return path;
}

- (UIImage *)imageTintedWithColor:(UIColor *)color
{
        // This method is designed for use with template images, i.e. solid-coloured mask-like images.
    return [self imageTintedWithColor:color fraction:0.0]; // default to a fully tinted mask of the image.
}


- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction
{
    if (color) {
            // Construct new image the same size as this one.
        UIImage *image;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
        if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
            UIGraphicsBeginImageContextWithOptions([self size], NO, 0.f); // 0.f for scale means "scale for device's main screen".
        } else {
            UIGraphicsBeginImageContext([self size]);
        }
#else
        UIGraphicsBeginImageContext([self size]);
#endif
        CGRect rect = CGRectZero;
        rect.size = [self size];
        
            // Composite tint color at its own opacity.
        [color set];
        UIRectFill(rect);
        
            // Mask tint color-swatch to this image's opaque mask.
            // We want behaviour like NSCompositeDestinationIn on Mac OS X.
        [self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
        
            // Finally, composite this image over the tinted mask at desired opacity.
        if (fraction > 0.0) {
                // We want behaviour like NSCompositeSourceOver on Mac OS X.
            [self drawInRect:rect blendMode:kCGBlendModeSourceAtop alpha:fraction];
        }
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    return self;
}

+(UIImage*)imageWithFrame:(CGSize)size Colors:(NSArray*)colors GradientType:(GradientType)gradientType
{
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case 0:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, size.height);
            break;
        case 1:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, 0.0);
            break;
        case 2:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, size.height);
            break;
        case 3:
            start = CGPointMake(size.width, 0.0);
            end = CGPointMake(0.0,size.height);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}


static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
                                 float ovalHeight)
{
    float fw, fh;
    
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

- (id)roundedSize:(CGSize)size radius:(NSInteger)r
{
        // the size of CGContextRef
    int w = size.width;
    int h = size.height;
    
    UIImage *img = self;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace,(CGBitmapInfo) kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, r, r);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    img = [UIImage imageWithCGImage:imageMasked];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    
    return img;
}

- (UIColor *) getPixelColorAtLocation:(CGPoint)point {
    
    UIColor* color = nil;
    
    CGImageRef inImage = self.CGImage;
    
        // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    
    if (cgctx == NULL) {
        
        return nil; /* error */
        
    }
    
    
    
    size_t w = CGImageGetWidth(inImage);
    
    size_t h = CGImageGetHeight(inImage);
    
    CGRect rect = {{0,0},{w,h}};
    
    
    
        // Draw the image to the bitmap context. Once we draw, the memory
    
        // allocated for the context for rendering will then contain the
    
        // raw image data in the specified color space.
    
    CGContextDrawImage(cgctx, rect, inImage);
    
    
    
        // Now we can get a pointer to the image data associated with the bitmap
    
        // context.
    
    unsigned char* data = CGBitmapContextGetData (cgctx);
    
    if (data != NULL) {
        
            //offset locates the pixel in the data from x,y.
        
            //4 for 4 bytes of data per pixel, w is width of one row of data.
        
        int offset = 4*((w*round(point.y))+round(point.x));
        
        int alpha =  data[offset];
        
        int red = data[offset+1];
        
        int green = data[offset+2];
        
        int blue = data[offset+3];
        
            //NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
        
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        
        
        
    }
    
    
    
        // When finished, release the context
    
    CGContextRelease(cgctx);
    
        // Free image data memory for the context
    
    if (data) { free(data); }
    
    return color;
    
}



- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    
    
    CGContextRef    context = NULL;
    
    CGColorSpaceRef colorSpace;
    
    void *          bitmapData;
    
    unsigned long             bitmapByteCount;
    
    unsigned long           bitmapBytesPerRow;
    
    
    
        // Get image width, height. We'll use the entire image.
    
    size_t pixelsWide = CGImageGetWidth(inImage);
    
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    
    
        // Declare the number of bytes per row. Each pixel in the bitmap in this
    
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    
        // alpha.
    
    bitmapBytesPerRow   = (pixelsWide * 4);
    
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    
    
        // Use the generic RGB color space.
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    
    if (colorSpace == NULL)
        
    {
        
        fprintf(stderr, "Error allocating color space\n");
        
        return NULL;
        
    }
    
    
    
        // Allocate memory for image data. This is the destination in memory
    
        // where any drawing to the bitmap context will be rendered.
    
    bitmapData = malloc( bitmapByteCount );
    
    if (bitmapData == NULL)
        
    {
        
        fprintf (stderr, "Memory not allocated!");
        
        CGColorSpaceRelease( colorSpace );
        
        return NULL;
        
    }
    
    
    
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    
        // per component. Regardless of what the source image format is
    
        // (CMYK, Grayscale, and so on) it will be converted over to the format
    
        // specified here by CGBitmapContextCreate.
    
    context = CGBitmapContextCreate (bitmapData,
                                     
                                     pixelsWide,
                                     
                                     pixelsHigh,
                                     
                                     8,      // bits per component
                                     
                                     bitmapBytesPerRow,
                                     
                                     colorSpace,
                                     
                                     (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    
    if (context == NULL)
        
    {
        
        free (bitmapData);
        
        fprintf (stderr, "Context not created!");
        
    }
    
    
    
        // Make sure and release colorspace before returning
    
    CGColorSpaceRelease( colorSpace );
    
    
    
    return context;
    
}

- (instancetype)imageWithOverlayColor:(UIColor *)overlayColor
{
    UIImage *image = self;
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [overlayColor CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    
    return flippedImage;
}

    //根据颜色创建一个图片
+ (UIImage *)createImageWithColor:(UIColor *)color rect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(void)imageWriteToSavedPhotosAlbum:(UIImage *)image result:(CompletionBlock)completionBlock{
    void *blockAsContext = (__bridge_retained void *)[completionBlock copy];
    
    UIImageWriteToSavedPhotosAlbum(image, UIImage.class, @selector(bk_image:didFinishSavingWithError:contextInfo:),blockAsContext);
    
}
- (void)bk_image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    CompletionBlock block = (__bridge_transfer id)contextInfo;
    if (!block) { return; }
    block(error);
}

//- (UIImage *)applyLightEffect{
//
//    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
//    return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
//}
//
//
//- (UIImage *)applyExtraLightEffect {
//
//    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
//    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
//}
//
//
//- (UIImage *)applyDarkEffect {
//
//    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
//    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
//}


//- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor {
//
//    const CGFloat EffectColorAlpha = 0.6;
//    UIColor      *effectColor      = tintColor;
//    int           componentCount   = (int)CGColorGetNumberOfComponents(tintColor.CGColor);
//
//    if (componentCount == 2) {
//
//        CGFloat b;
//        if ([tintColor getWhite:&b alpha:NULL]) {
//
//            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
//        }
//
//    } else {
//
//        CGFloat r, g, b;
//        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
//
//            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
//        }
//    }
//
//    return [self applyBlurWithRadius:20 tintColor:effectColor saturationDeltaFactor:1.4 maskImage:nil];
//}


- (UIImage *)scaleWithFixedWidth:(CGFloat)width {
    
    float newHeight = self.size.height * (width / self.size.width);
    CGSize size     = CGSizeMake(width, newHeight);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
    
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageOut;
}

- (UIImage *)scaleWithFixedHeight:(CGFloat)height {
    
    float newWidth = self.size.width * (height / self.size.height);
    CGSize size    = CGSizeMake(newWidth, height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
    
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageOut;
}

- (UIColor *)averageColor {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

- (UIImage *)croppedImageAtFrame:(CGRect)frame {
    
    frame = CGRectMake(frame.origin.x * self.scale,
                       frame.origin.y * self.scale,
                       frame.size.width * self.scale,
                       frame.size.height * self.scale);
    
    CGImageRef sourceImageRef = [self CGImage];
    CGImageRef newImageRef    = CGImageCreateWithImageInRect(sourceImageRef, frame);
    UIImage   *newImage       = [UIImage imageWithCGImage:newImageRef scale:[self scale] orientation:[self imageOrientation]];
    CGImageRelease(newImageRef);
    return newImage;
}

- (UIImage *)addImageToImage:(UIImage *)img atRect:(CGRect)cropRect {
    
    CGSize size = CGSizeMake(self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    
    CGPoint pointImg1 = CGPointMake(0,0);
    [self drawAtPoint:pointImg1];
    
    CGPoint pointImg2 = cropRect.origin;
    [img drawAtPoint: pointImg2];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

//- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius
//                       tintColor:(UIColor *)tintColor
//           saturationDeltaFactor:(CGFloat)saturationDeltaFactor
//                       maskImage:(UIImage *)maskImage
//                         atFrame:(CGRect)frame
//{
//    UIImage *blurredFrame = \
//    [[self croppedImageAtFrame:frame] applyBlurWithRadius:blurRadius
//                                                tintColor:tintColor
//                                    saturationDeltaFactor:saturationDeltaFactor
//                                                maskImage:maskImage];
//
//    return [self addImageToImage:blurredFrame atRect:frame];
//}



#pragma mark -
#pragma mark - blur image Effects

////| ----------------------------------------------------------------------------
//- (UIImage *)at_lightImage
//{
//    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
//    return [self at_blurredImageWithSize:CGSizeMake(60, 60) tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
//}
//
//
////| ----------------------------------------------------------------------------
//- (UIImage *)at_extraLightImage
//{
//    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
//    return [self at_blurredImageWithSize:CGSizeMake(40, 40) tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
//}
//
//
////| ----------------------------------------------------------------------------
//- (UIImage *)at_darkImage
//{
//    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
//    return [self at_blurredImageWithSize:CGSizeMake(40, 40) tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
//}
//
//
////| ----------------------------------------------------------------------------
//- (UIImage *)at_tintedImageWithColor:(UIColor *)tintColor
//{
//    const CGFloat EffectColorAlpha = 0.6;
//    UIColor *effectColor = tintColor;
//    size_t componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
//    if (componentCount == 2) {
//        CGFloat b;
//        if ([tintColor getWhite:&b alpha:NULL]) {
//            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
//        }
//    }
//    else {
//        CGFloat r, g, b;
//        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
//            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
//        }
//    }
//    return [self at_blurredImageWithSize:CGSizeMake(20, 20) tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
//}
//
//
////| ----------------------------------------------------------------------------
//- (UIImage *)at_blurredImageWithRadius:(CGFloat)blurRadius
//{
//    return [self at_blurredImageWithSize:CGSizeMake(blurRadius, blurRadius)];
//}
//
//
////| ----------------------------------------------------------------------------
//- (UIImage *)at_blurredImageWithSize:(CGSize)blurSize
//{
//    return [self at_blurredImageWithSize:blurSize tintColor:nil saturationDeltaFactor:1.0 maskImage:nil];
//}
//
//#pragma mark -
//#pragma mark - Implementation
//
////| ----------------------------------------------------------------------------
//- (UIImage *)at_blurredImageWithSize:(CGSize)blurSize tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
//{
//#define ENABLE_BLUR                     1
//#define ENABLE_SATURATION_ADJUSTMENT    1
//#define ENABLE_TINT                     1
//    
//    // Check pre-conditions.
//    if (self.size.width < 1 || self.size.height < 1)
//    {
//        NSLog(@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
//        return nil;
//    }
//    if (!self.CGImage)
//    {
//        NSLog(@"*** error: inputImage must be backed by a CGImage: %@", self);
//        return nil;
//    }
//    if (maskImage && !maskImage.CGImage)
//    {
//        NSLog(@"*** error: effectMaskImage must be backed by a CGImage: %@", maskImage);
//        return nil;
//    }
//    
//    BOOL hasBlur = blurSize.width > __FLT_EPSILON__ || blurSize.height > __FLT_EPSILON__;
//    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
//    
//    CGImageRef inputCGImage = self.CGImage;
//    CGFloat inputImageScale = self.scale;
//    CGBitmapInfo inputImageBitmapInfo = CGImageGetBitmapInfo(inputCGImage);
//    CGImageAlphaInfo inputImageAlphaInfo = (inputImageBitmapInfo & kCGBitmapAlphaInfoMask);
//    
//    CGSize outputImageSizeInPoints = self.size;
//    CGRect outputImageRectInPoints = { CGPointZero, outputImageSizeInPoints };
//    
//    // Set up output context.
//    BOOL useOpaqueContext;
//    if (inputImageAlphaInfo == kCGImageAlphaNone || inputImageAlphaInfo == kCGImageAlphaNoneSkipLast || inputImageAlphaInfo == kCGImageAlphaNoneSkipFirst)
//        useOpaqueContext = YES;
//    else
//        useOpaqueContext = NO;
//    UIGraphicsBeginImageContextWithOptions(outputImageRectInPoints.size, useOpaqueContext, inputImageScale);
//    CGContextRef outputContext = UIGraphicsGetCurrentContext();
//    CGContextScaleCTM(outputContext, 1.0, -1.0);
//    CGContextTranslateCTM(outputContext, 0, -outputImageRectInPoints.size.height);
//    
//    if (hasBlur || hasSaturationChange)
//    {
//        vImage_Buffer effectInBuffer;
//        vImage_Buffer scratchBuffer1;
//        
//        vImage_Buffer *inputBuffer;
//        vImage_Buffer *outputBuffer;
//        
//        vImage_CGImageFormat format = {
//            .bitsPerComponent = 8,
//            .bitsPerPixel = 32,
//            .colorSpace = NULL,
//            // (kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little)
//            // requests a BGRA buffer.
//            .bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little,
//            .version = 0,
//            .decode = NULL,
//            .renderingIntent = kCGRenderingIntentDefault
//        };
//        
//        vImage_Error e = vImageBuffer_InitWithCGImage(&effectInBuffer, &format, NULL, self.CGImage, kvImagePrintDiagnosticsToConsole);
//        if (e != kvImageNoError)
//        {
//            NSLog(@"*** error: vImageBuffer_InitWithCGImage returned error code %zi for inputImage: %@", e, self);
//            UIGraphicsEndImageContext();
//            return nil;
//        }
//        
//        vImageBuffer_Init(&scratchBuffer1, effectInBuffer.height, effectInBuffer.width, format.bitsPerPixel, kvImageNoFlags);
//        inputBuffer = &effectInBuffer;
//        outputBuffer = &scratchBuffer1;
//        
//#if ENABLE_BLUR
//        if (hasBlur)
//        {
//            CGFloat radiusX = [self at_gaussianBlurRadiusWithBlurRadius:blurSize.width * inputImageScale];
//            CGFloat radiusY = [self at_gaussianBlurRadiusWithBlurRadius:blurSize.height * inputImageScale];
//            
//            NSInteger tempBufferSize = vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, NULL, 0, 0, radiusY, radiusX, NULL, kvImageGetTempBufferSize | kvImageEdgeExtend);
//            void *tempBuffer = malloc(tempBufferSize);
//            
//            vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radiusY, radiusX, NULL, kvImageEdgeExtend);
//            vImageBoxConvolve_ARGB8888(outputBuffer, inputBuffer, tempBuffer, 0, 0, radiusY, radiusX, NULL, kvImageEdgeExtend);
//            vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radiusY, radiusX, NULL, kvImageEdgeExtend);
//            
//            free(tempBuffer);
//            
//            vImage_Buffer *temp = inputBuffer;
//            inputBuffer = outputBuffer;
//            outputBuffer = temp;
//        }
//#endif
//        
//#if ENABLE_SATURATION_ADJUSTMENT
//        if (hasSaturationChange)
//        {
//            CGFloat s = saturationDeltaFactor;
//            // These values appear in the W3C Filter Effects spec:
//            // https://dvcs.w3.org/hg/FXTF/raw-file/default/filters/index.html#grayscaleEquivalent
//            //
//            CGFloat floatingPointSaturationMatrix[] = {
//                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
//                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
//                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
//                0,                    0,                    0,                    1,
//            };
//            const int32_t divisor = 256;
//            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
//            int16_t saturationMatrix[matrixSize];
//            for (NSUInteger i = 0; i < matrixSize; ++i) {
//                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
//            }
//            vImageMatrixMultiply_ARGB8888(inputBuffer, outputBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
//            
//            vImage_Buffer *temp = inputBuffer;
//            inputBuffer = outputBuffer;
//            outputBuffer = temp;
//        }
//#endif
//        
//        CGImageRef effectCGImage;
//        if ( (effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, &at_cleanupBuffer, NULL, kvImageNoAllocate, NULL)) == NULL ) {
//            effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, NULL, NULL, kvImageNoFlags, NULL);
//            free(inputBuffer->data);
//        }
//        if (maskImage) {
//            // Only need to draw the base image if the effect image will be masked.
//            CGContextDrawImage(outputContext, outputImageRectInPoints, inputCGImage);
//        }
//        
//        // draw effect image
//        CGContextSaveGState(outputContext);
//        if (maskImage)
//            CGContextClipToMask(outputContext, outputImageRectInPoints, maskImage.CGImage);
//        CGContextDrawImage(outputContext, outputImageRectInPoints, effectCGImage);
//        CGContextRestoreGState(outputContext);
//        
//        // Cleanup
//        CGImageRelease(effectCGImage);
//        free(outputBuffer->data);
//    }
//    else
//    {
//        // draw base image
//        CGContextDrawImage(outputContext, outputImageRectInPoints, inputCGImage);
//    }
//    
//#if ENABLE_TINT
//    // Add in color tint.
//    if (tintColor)
//    {
//        CGContextSaveGState(outputContext);
//        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
//        CGContextFillRect(outputContext, outputImageRectInPoints);
//        CGContextRestoreGState(outputContext);
//    }
//#endif
//    
//    // Output image is ready.
//    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return outputImage;
//#undef ENABLE_BLUR
//#undef ENABLE_SATURATION_ADJUSTMENT
//#undef ENABLE_TINT
//}
//
//
//// A description of how to compute the box kernel width from the Gaussian
//// radius (aka standard deviation) appears in the SVG spec:
//// http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
////
//// For larger values of 's' (s >= 2.0), an approximation can be used: Three
//// successive box-blurs build a piece-wise quadratic convolution kernel, which
//// approximates the Gaussian kernel to within roughly 3%.
////
//// let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
////
//// ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
////
//- (CGFloat)at_gaussianBlurRadiusWithBlurRadius:(CGFloat)blurRadius
//{
//    if (blurRadius - 2. < __FLT_EPSILON__) {
//        blurRadius = 2.;
//    }
//    uint32_t radius = floor((blurRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5) / 2);
//    radius |= 1; // force radius to be odd so that the three box-blur methodology works.
//    return radius;
//}
//
//
////| ----------------------------------------------------------------------------
////  Helper function to handle deferred cleanup of a buffer.
////
//void at_cleanupBuffer(void *userData, void *buf_data)
//{ free(buf_data); }
//
//
//
//#pragma mark - Blur
//- (UIImage *)at_blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
//    if ((blur < 0.0f) || (blur > 1.0f)) {
//        blur = 0.5f;
//    }
//    
//    int boxSize = (int)(blur * 100);
//    boxSize -= (boxSize % 2) + 1;
//    
//    CGImageRef img = image.CGImage;
//    
//    vImage_Buffer inBuffer, outBuffer;
//    vImage_Error error;
//    void *pixelBuffer;
//    
//    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
//    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
//    
//    inBuffer.width = CGImageGetWidth(img);
//    inBuffer.height = CGImageGetHeight(img);
//    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
//    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
//    
//    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
//    
//    outBuffer.data = pixelBuffer;
//    outBuffer.width = CGImageGetWidth(img);
//    outBuffer.height = CGImageGetHeight(img);
//    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
//    
//    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
//                                       0, 0, boxSize, boxSize, NULL,
//                                       kvImageEdgeExtend);
//    
//    if (error) {
//        NSLog(@"error from convolution %ld", error);
//    }
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef ctx = CGBitmapContextCreate(
//                                             outBuffer.data,
//                                             outBuffer.width,
//                                             outBuffer.height,
//                                             8,
//                                             outBuffer.rowBytes,
//                                             colorSpace,
//                                             CGImageGetBitmapInfo(image.CGImage));
//    
//    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
//    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
//    
//    //clean up
//    CGContextRelease(ctx);
//    CGColorSpaceRelease(colorSpace);
//    
//    free(pixelBuffer);
//    CFRelease(inBitmapData);
//    
//    CGColorSpaceRelease(colorSpace);
//    CGImageRelease(imageRef);
//    
//    return returnImage;
//}


#pragma mark -
#pragma mark - 修正图片的方向
///**
// *  @brief  修正图片的方向
// *
// *  @param srcImg 图片
// *
// *  @return 修正方向后的图片
// */
//+ (UIImage *)at_fixOrientation:(UIImage *)srcImg {
//    if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
//    CGAffineTransform transform = CGAffineTransformIdentity;
//    switch (srcImg.imageOrientation) {
//        case UIImageOrientationDown:
//        case UIImageOrientationDownMirrored:
//            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
//            transform = CGAffineTransformRotate(transform, M_PI);
//            break;
//        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
//            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
//            transform = CGAffineTransformRotate(transform, M_PI_2);
//            break;
//        case UIImageOrientationRight:
//        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
//            transform = CGAffineTransformRotate(transform, -M_PI_2);
//            break;
//        case UIImageOrientationUp:
//        case UIImageOrientationUpMirrored:
//            break;
//    }
//    switch (srcImg.imageOrientation) {
//        case UIImageOrientationUpMirrored:
//        case UIImageOrientationDownMirrored:
//            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
//        case UIImageOrientationLeftMirrored:
//        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
//        case UIImageOrientationUp:
//        case UIImageOrientationDown:
//        case UIImageOrientationLeft:
//        case UIImageOrientationRight:
//            break;
//    }
//    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
//                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
//                                             CGImageGetColorSpace(srcImg.CGImage),
//                                             CGImageGetBitmapInfo(srcImg.CGImage));
//    CGContextConcatCTM(ctx, transform);
//    switch (srcImg.imageOrientation) {
//        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
//        case UIImageOrientationRight:
//        case UIImageOrientationRightMirrored:
//            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
//            break;
//        default:
//            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
//            break;
//    }
//    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
//    UIImage *img = [UIImage imageWithCGImage:cgimg];
//    CGContextRelease(ctx);
//    CGImageRelease(cgimg);
//    return img;
//}
//
//- (UIImage *)at_flip:(BOOL)isHorizontal {
//    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
//    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
//
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextClipToRect(ctx, rect);
//    if (isHorizontal) {
//        CGContextRotateCTM(ctx, M_PI);
//        CGContextTranslateCTM(ctx, -rect.size.width, -rect.size.height);
//    }
//    CGContextDrawImage(ctx, rect, self.CGImage);
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}
///**
// *  @brief  垂直翻转
// *
// *  @return  翻转后的图片
// */
//- (UIImage *)at_flipVertical {
//    return [self at_flip:NO];
//}
///**
// *  @brief  水平翻转
// *
// *  @return 翻转后的图片
// */
//- (UIImage *)at_flipHorizontal {
//    return [self at_flip:YES];
//}
///**
// *  @brief  旋转图片
// *
// *  @param radians 弧度
// *
// *  @return 旋转后图片
// */
//- (UIImage *)at_imageRotatedByRadians:(CGFloat)radians
//{
//    return [self at_imageRotatedByDegrees:[UIImage at_radiansToDegrees:radians]];
//}
///**
// *  @brief  旋转图片
// *
// *  @param degrees 度
// *
// *  @return 旋转后图片
// */
//- (UIImage *)at_imageRotatedByDegrees:(CGFloat)degrees
//{
//    // calculate the size of the rotated view's containing box for our drawing space
//    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
//    CGAffineTransform t = CGAffineTransformMakeRotation([UIImage at_degreesToRadians:degrees]);
//    rotatedViewBox.transform = t;
//    CGSize rotatedSize = rotatedViewBox.frame.size;
//
//    // Create the bitmap context
//    UIGraphicsBeginImageContext(rotatedSize);
//    CGContextRef bitmap = UIGraphicsGetCurrentContext();
//
//    // Move the origin to the middle of the image so we will rotate and scale around the center.
//    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
//
//    //   // Rotate the image context
//    CGContextRotateCTM(bitmap, [UIImage at_degreesToRadians:degrees]);
//
//    // Now, draw the rotated/scaled image into the context
//    CGContextScaleCTM(bitmap, 1.0, -1.0);
//    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
//
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//
//}
//
///**
// *  @brief  角度转弧度
// *
// *  @param degrees 角度
// *
// *  @return 弧度
// */
//+(CGFloat)at_degreesToRadians:(CGFloat)degrees
//{
//    return degrees * M_PI / 180;
//}
///**
// *  @brief  弧度转角度
// *
// *  @param radians 弧度
// *
// *  @return 角度
// */
//+(CGFloat)at_radiansToDegrees:(CGFloat)radians
//{
//    return radians * 180/M_PI;
//}
//
/**
 设置图片旋转角度

 @param image 要旋转的图片
 @param Angle 旋转的角度（0~360）
 @return 旋转后的图片
 */
- (UIImage*)at_RotatingImages:(CGFloat)Angle{
    @autoreleasepool {
        CGFloat width = CGImageGetWidth(self.CGImage);
        CGFloat height = CGImageGetHeight(self.CGImage);

        CGSize rotatedSize;
        rotatedSize.width = width;
        rotatedSize.height = height;

        UIGraphicsBeginImageContext(rotatedSize);
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
        CGContextRotateCTM(bitmap, Angle * M_PI / 180); //* M_PI / 180
        CGContextRotateCTM(bitmap, M_PI);
        CGContextScaleCTM(bitmap, -1.0, 1.0);
        CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
}



#pragma mark -
#pragma mark - 图片裁剪

///**
// *  改变Image的任何的大小
// *
// *  @param size 目的大小
// *
// *  @return 修改后的Image
// */
//- (UIImage *)at_cropImageWithAnySize:(CGSize)size{
//    float scale = self.size.width/self.size.height;
//    CGRect rect = CGRectMake(0, 0, 0, 0);
//
//    if (scale > size.width/size.height){
//        rect.origin.x = (self.size.width - self.size.height * size.width/size.height)/2;
//        rect.size.width  = self.size.height * size.width/size.height;
//        rect.size.height = self.size.height;
//    }else {
//        rect.origin.y = (self.size.height - self.size.width/size.width * size.height)/2;
//        rect.size.width  = self.size.width;
//        rect.size.height = self.size.width/size.width * size.height;
//
//    }
//    CGImageRef imageRef   = CGImageCreateWithImageInRect(self.CGImage, rect);
//    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
//
//    return croppedImage;
//}
///**
// *  裁剪和拉升图片
// */
//- (UIImage*)at_imageByScalingAndCroppingForTargetSize:(CGSize)targetSize{
//    UIImage *sourceImage = self;
//    UIImage *newImage = nil;
//    CGSize imageSize = sourceImage.size;
//    CGFloat width = imageSize.width;
//    CGFloat height = imageSize.height;
//    CGFloat targetWidth = targetSize.width;
//    CGFloat targetHeight = targetSize.height;
//    CGFloat scaleFactor = 0.0;
//    CGFloat scaledWidth = targetWidth;
//    CGFloat scaledHeight = targetHeight;
//    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
//
//    if (CGSizeEqualToSize(imageSize, targetSize) == NO){
//        CGFloat widthFactor = targetWidth / width;
//        CGFloat heightFactor = targetHeight / height;
//        if (widthFactor > heightFactor){
//            scaleFactor = widthFactor; // scale to fit height
//        }else{
//            scaleFactor = heightFactor; // scale to fit width
//        }
//        scaledWidth= width * scaleFactor;
//        scaledHeight = height * scaleFactor;
//        // center the image
//        if (widthFactor > heightFactor){
//            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
//        }else if (widthFactor < heightFactor){
//            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
//        }
//    }
//
//    UIGraphicsBeginImageContext(targetSize); // this will crop
//    CGRect thumbnailRect = CGRectZero;
//    thumbnailRect.origin = thumbnailPoint;
//    thumbnailRect.size.width= scaledWidth;
//    thumbnailRect.size.height = scaledHeight;
//    [sourceImage drawInRect:thumbnailRect];
//    newImage = UIGraphicsGetImageFromCurrentImageContext();
//
//    if(newImage == nil)  NSLog(@"=========could not scale image===========");
//
//    //pop the context to get back to the default
//    UIGraphicsEndImageContext();
//    return newImage;
//}
///**
// *  返回圆形图片 直接操作layer.masksToBounds = YES 会比较卡顿
// */
//- (UIImage *)at_circleImage{
//    // NO代表透明
//    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
//    // 获得上下文
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    // 添加一个圆
//    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
//    CGContextAddEllipseInRect(ctx, rect);
//    // 裁剪
//    CGContextClip(ctx);
//    // 将图片画上去
//    [self drawInRect:rect];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}
//
///**
// *  根据图片名返回一张能够自由拉伸的图片 (从中间拉伸)
// */
//+ (UIImage *)at_resizableImage:(NSString *)imgName{
//    return [self at_resizableImage:imgName xPos:0.5 yPos:0.5];;
//}
//
///**
// *  根据图片名返回一张能够自由拉伸的图片
// */
//+ (UIImage *)at_resizableImage:(NSString *)imgName xPos:(CGFloat)xPos yPos:(CGFloat)yPos{
//    UIImage *image = [UIImage imageNamed:imgName];
//    return [image stretchableImageWithLeftCapWidth:image.size.width * xPos topCapHeight:image.size.height * yPos];
//}
//
///**
// *  获取视频第一帧图片
// */
//+ (UIImage *)at_getVideoFirstThumbnailImageWithVideoUrl:(NSURL *)videoUrl{
//    AVURLAsset*asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
//    NSParameterAssert(asset);
//
//    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
//    assetImageGenerator.appliesPreferredTrackTransform = YES;
//    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
//
//    CGImageRef thumbnailImageRef = nil;
//    CFTimeInterval thumbnailImageTime = MHThumbnailImageTime;
//    NSError *thumbnailImageGenerationError = nil;
//
//    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 1.0f) actualTime:nil error:&thumbnailImageGenerationError];
//
//    if(!thumbnailImageRef){
//        NSLog(@"======thumbnailImageGenerationError======= %@",thumbnailImageGenerationError);
//    }
//
//    return thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
//}
//
///**
// *  图片不被渲染
// *
// */
//+ (UIImage *)at_imageAlwaysShowOriginalImageWithImageName:(NSString *)imageName{
//    UIImage *image = [UIImage imageNamed:imageName];
//    if ([image respondsToSelector:@selector(imageWithRenderingMode:)]){   //iOS 7.0+
//        return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    }else{
//        return image;
//    }
//}
//
///**
// *  根据图片和颜色返回一张加深颜色以后的图片
// *  图片着色
// */
//+ (UIImage *)at_colorizeImageWithSourceImage:(UIImage *)sourceImage color:(UIColor *)color{
//    @autoreleasepool {
//        UIGraphicsBeginImageContext(CGSizeMake(sourceImage.size.width*2, sourceImage.size.height*2));
//
//        CGContextRef ctx = UIGraphicsGetCurrentContext();
//        CGRect area = CGRectMake(0, 0, sourceImage.size.width * 2, sourceImage.size.height * 2);
//
//        CGContextScaleCTM(ctx, 1, -1);
//        CGContextTranslateCTM(ctx, 0, -area.size.height);
//
//        CGContextSaveGState(ctx);
//        CGContextClipToMask(ctx, area, sourceImage.CGImage);
//
//        [color set];
//
//        CGContextFillRect(ctx, area);
//
//        CGContextRestoreGState(ctx);
//
//        CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
//
//        CGContextDrawImage(ctx, area, sourceImage.CGImage);
//
//        UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
//
//        UIGraphicsEndImageContext();
//
//        return destImage;
//    }
//}
//
///**
// *  根据指定的图片颜色和图片大小获取指定的Image
// *
// *  @param color 颜色
// *  @param size  大小
// *
// */
//+ (UIImage *)at_getImageWithColor:(UIColor *)color size:(CGSize)size{
//    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
//    [color set];
//    UIRectFill(CGRectMake(0, 0, size.width, size.height));
//    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return destImage;
//}
//
///**
// *  通过传入一个图片对象获取一张缩略图
// */
//+ (UIImage *)at_getThumbnailImageWithImageObj:(id)imageObj{
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored"-Wdeprecated-declarations"
//    __block UIImage *image = nil;
//    if ([imageObj isKindOfClass:[UIImage class]]) {
//        return imageObj;
//    }else if ([imageObj isKindOfClass:[ALAsset class]]){
//        @autoreleasepool {
//            ALAsset *asset = (ALAsset *)imageObj;
//            return [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
//        }
//    }
//    return image;
//#pragma clang diagnostic pop
//}
//
///**
// *  通过传入一个图片对象获取一张原始图
// */
//+ (UIImage *)at_getOriginalImageWithImageObj:(id)imageObj{
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored"-Wdeprecated-declarations"
//    __block UIImage *image = nil;
//    if ([imageObj isKindOfClass:[UIImage class]]) {
//        return imageObj;
//    }else if ([imageObj isKindOfClass:[ALAsset class]]){
//        @autoreleasepool {
//            ALAsset *asset = (ALAsset *)imageObj;
//            return [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
//        }
//    }
//    return image;
//#pragma clang diagnostic pop
//}
//
///**
// *  将图片旋转到指定的方向
// *
// *  @param sourceImage 要旋转的图片
// *  @param orientation 旋转方向
// *
// *  @return 返回旋转后的图片
// */
//+ (UIImage *) at_fixImageOrientationWithSourceImage:(UIImage *)sourceImage orientation:(UIImageOrientation)orientation{
//    long double rotate = 0.0;
//    CGRect rect;
//    float translateX = 0;
//    float translateY = 0;
//    float scaleX = 1.0;
//    float scaleY = 1.0;
//
//    switch (orientation) {
//        case UIImageOrientationLeft:
//        {
//            rotate = M_PI_2;
//            rect = CGRectMake(0, 0, sourceImage.size.height, sourceImage.size.width);
//            translateX = 0;
//            translateY = -rect.size.width;
//            scaleY = rect.size.width/rect.size.height;
//            scaleX = rect.size.height/rect.size.width;
//        }
//            break;
//        case UIImageOrientationRight:
//        {
//            rotate = 3 * M_PI_2;
//            rect = CGRectMake(0, 0, sourceImage.size.height, sourceImage.size.width);
//            translateX = -rect.size.height;
//            translateY = 0;
//            scaleY = rect.size.width/rect.size.height;
//            scaleX = rect.size.height/rect.size.width;
//        }
//            break;
//        case UIImageOrientationDown:
//        {
//            rotate = M_PI;
//            rect = CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height);
//            translateX = -rect.size.width;
//            translateY = -rect.size.height;
//        }
//            break;
//        default:
//        {
//            rotate = 0.0;
//            rect = CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height);
//            translateX = 0;
//            translateY = 0;
//        }
//            break;
//    }
//
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    //做CTM变换
//    CGContextTranslateCTM(context, 0.0, rect.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    CGContextRotateCTM(context, rotate);
//    CGContextTranslateCTM(context, translateX, translateY);
//
//    CGContextScaleCTM(context, scaleX, scaleY);
//    //绘制图片
//    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), sourceImage.CGImage);
//
//    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
//
//    return destImage;
//}

/**
 *  屏幕截图
 */
+ (instancetype) at_captureScreen:(UIView *)view{
    // 手动开启图片上下文
    UIGraphicsBeginImageContext(view.bounds.size);
    // 获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 渲染上下文到图层
    [view.layer renderInContext:ctx];
    // 从当前上下文获取图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    return newImage;
}




#pragma mark -
#pragma mark - 添加水印文字
//// 给图片添加文字水印：
//+ (UIImage *)at_WaterImageWithImage:(UIImage *)image text:(NSString *)text textPoint:(CGPoint)point attributedString:(NSDictionary * )attributed{
//    //1.开启上下文
//    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
//    //2.绘制图片
//    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
//    //添加水印文字
//    [text drawAtPoint:point withAttributes:attributed];
//    //3.从上下文中获取新图片
//    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
//    //4.关闭图形上下文
//    UIGraphicsEndImageContext();
//    //返回图片
//    return newImage;
//}
//
//
//// 给图片添加图片水印
//+ (UIImage *)at_WaterImageWithImage:(UIImage *)image waterImage:(UIImage *)waterImage waterImageRect:(CGRect)rect{
//    
//    //1.获取图片
//    //2.开启上下文
//    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
//    //3.绘制背景图片
//    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
//    //绘制水印图片到当前上下文
//    [waterImage drawInRect:rect];
//    //4.从上下文中获取新图片
//    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
//    //5.关闭图形上下文
//    UIGraphicsEndImageContext();
//    //返回图片
//    return newImage;
//}
//
//
//+ (instancetype)at_WaterMarkWithImageName:(NSString *)backgroundImage andMarkImageName:(NSString *)markName{
//    
//    UIImage *bgImage = [UIImage imageNamed:backgroundImage];
//    
//    UIGraphicsBeginImageContextWithOptions(bgImage.size, NO, 0.0);
//    [bgImage drawInRect:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
//    
//    UIImage *waterImage = [UIImage imageNamed:markName];
//    CGFloat scale = 0.3;
//    CGFloat margin = 5;
//    CGFloat waterW = waterImage.size.width * scale;
//    CGFloat waterH = waterImage.size.height * scale;
//    CGFloat waterX = bgImage.size.width - waterW - margin;
//    CGFloat waterY = bgImage.size.height - waterH - margin;
//    
//    [waterImage drawInRect:CGRectMake(waterX, waterY, waterW, waterH)];
//    
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return newImage;
//}


/** 根据图片二进制流获取图片格式 */
+ (NSString *)imageTypeWithData:(NSData *)data {
    uint8_t type;
    [data getBytes:&type length:1];
    switch (type) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return nil;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            return nil;
    }
    return nil;
}
@end

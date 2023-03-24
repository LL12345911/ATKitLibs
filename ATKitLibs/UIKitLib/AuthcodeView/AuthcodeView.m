//
//  AuthcodeView.h
//  EngineeringCool
//
//  Created by Mars on 2022/4/1.
//  Copyright © 2022 Mars. All rights reserved.
//

#import "AuthcodeView.h"

#define kRandomColor  [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0]
#define kFontSize [UIFont systemFontOfSize:arc4random_uniform(5) + 20]

@implementation AuthcodeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //设置layer圆角半径
        self.layer.cornerRadius = 5.0;
        //影藏边境
        self.layer.masksToBounds = YES;
        self.backgroundColor = kRandomColor;
        self.charCount = 4;
        self.lineCount = 8;
        self.lineWidth = 1.0;
        
        //显示一个随机验证码
        [self randomCaptcha];
    }
    return self;
}
#pragma mark -- 更换验证码
- (void)randomCaptcha {
    //数组中存放的是全部可选的字符，可以是字母，也可以是中文
    self.characterArray = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z", nil];
    NSMutableString *getStr = [[NSMutableString alloc] initWithCapacity:_charCount];
    self.captchaString = [[NSMutableString alloc] initWithCapacity:_charCount];
    //随机从数组中选取需要个数的字符，然后拼接为一个字符串
    for (int i = 0 ; i < _charCount; i ++) {
        int index = arc4random() % (self.characterArray.count - 1);
        getStr = [self.characterArray objectAtIndex:index];
        self.captchaString = [[self.captchaString stringByAppendingString:getStr] copy];
    }
    // 从网络获取字符串，然后把得到的字符串在本地绘制出来（网络获取步骤在这省略）
}

/** 加载验证码 */
- (void)loadCaptcha {
    // 更换验证码
    [self randomCaptcha];
    // 重新绘制 setNeedsDisplay调用drawRect方法来实现view的绘制
    [self setNeedsDisplay];
}
#pragma mark 绘制界面
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // 设置随机背景颜色
    self.backgroundColor = kRandomColor;
    // 获取要显示的验证码字符串
    NSString *text = [NSString stringWithFormat:@"%@" , self.captchaString];
    // 根据要显示的验证码字符串，根据长度，计算每个字符串显示的位置
    CGSize cSize = [@"s" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    int width = rect.size.width / text.length - cSize.width;
    int height = rect.size.height - cSize.height;
    CGPoint point;
    // 依次绘制每一个字符,可以设置显示的每个字符的字体大小、颜色、样式等
    float pX , pY;
    for (int i = 0; i < text.length; i ++) {
        pX = arc4random() % width + rect.size.width / text.length * i;
        pY = arc4random() % height;
        point = CGPointMake(pX, pY);
        unichar c = [text characterAtIndex:i];
        NSString *textC = [NSString stringWithFormat:@"%c" , c];
        [textC drawAtPoint:point withAttributes:@{NSFontAttributeName:kFontSize}];
    }
    // 调用drawRect：之前，系统会向栈中压入一个CGContextRef，调用UIGraphicsGetCurrentContext()会取栈顶的CGContextRef
    // 获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 设置画线宽度
    CGContextSetLineWidth(context, _lineWidth);
    // 绘制干扰的彩色直线
    for (int i = 0; i < _lineCount; i ++) {
        //设置线的随机颜色
        UIColor *color = kRandomColor;
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        //设置线的起点
        pX = arc4random() % (int)rect.size.width;
        pY = arc4random() % (int)rect.size.height;
        CGContextMoveToPoint(context, pX, pY);
        //设置线的终点
        pX = arc4random() % (int)rect.size.width;
        pY = arc4random() % (int)rect.size.height;
        CGContextAddLineToPoint(context, pX, pY);
        //画线
        CGContextStrokePath(context);
    }
}

@end

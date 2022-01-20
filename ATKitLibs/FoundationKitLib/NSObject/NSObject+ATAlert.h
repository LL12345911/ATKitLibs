//
//  NSObject+ATAlert.h
//  HighwayDoctor
//
//  Created by Mars on 2019/5/9.
//  Copyright © 2019 Mars. All rights reserved.
//

//  提醒

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (ATAlert)
/**
 系统 不修改的 UIAlertController (UIAlertControllerStyleAlert)
 
 @param title 标题
 @param message 文本信息
 @param confirmTitle 确定按钮标题
 @param cancelTitle 取消按钮标题
 @param confirmAction 确定按钮Block
 @param cancelAction 取消按钮Block
 */
+ (UIAlertController *)at_showAlertViewStyleAlterWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle cancelTitle:(NSString *)cancelTitle confirmAction:(void(^)(void))confirmAction cancelAction:(void(^)(void))cancelAction;


/// 三个 aciton
/// @param title 标题
/// @param message 文本信息
/// @param confirmTitle 确定按钮标题
/// @param action2Title 取消按钮标题
/// @param cancleTitle 取消
/// @param confirmAction 确定按钮Block
/// @param action2 取消按钮Block
+ (void)at_showAlertViewWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle action2Title:(NSString *)action2Title cancleTitle:(NSString *)cancleTitle confirmAction:(void(^)(void))confirmAction action2:(void(^)(void))action2;

    
/**
 系统 不修改的 UIAlertController (UIAlertControllerStyleActionSheet)

 @param actionTitle 按钮标题
 @param action1 按钮1Block
 @param action2Title 按钮2标题
 @param action2 按钮2Block
 @param cancleActionTitle 按钮3标题
 @param cancleAction 按钮3Block
 */
+ (void)at_showAlertViewStyleActionSheetWithActionTitle:(NSString *)actionTitle action1:(void(^)(void))action1 action2Title:(NSString *)action2Title action2:(void(^)(void))action2  cancleActionTitle:(NSString *)cancleActionTitle cancleAction:(void(^)(void))cancleAction;

/**
 弹出alertController，并且只有一个action按钮，切记只是警示作用，无事件处理
 
 @param title title
 @param message message
 @param confirmTitle confirmTitle 按钮的title
 */
+ (void)at_showAlertViewWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle;


/**
 弹出alertController，并且只有一个action按钮，有处理事件
 
 @param title title
 @param message message
 @param confirmTitle confirmTitle 按钮title
 @param confirmAction 按钮的点击事件处理
 */
+ (void)at_showAlertViewWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle confirmAction:(void(^)(void))confirmAction;


/**
 弹出alertController，并且有两个个action按钮，分别有处理事件
 
 @param title title
 @param message Message
 @param confirmTitle 右边按钮的title
 @param cancelTitle 左边按钮的title
 @param confirmAction 右边按钮的点击事件
 @param cancelAction 左边按钮的点击事件
 */
+ (void)at_showAlertViewWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle cancelTitle:(NSString *)cancelTitle confirmAction:(void(^)(void))confirmAction cancelAction:(void(^)(void))cancelAction;


/// 关闭当前界面上的alertView.
+(void)closeAlert;

/**
 获取当前控制器

 @return 当前控制器
 */
+ (UIViewController *)currentController;


@end







@interface UIAlertController (ATColor)

/// 统一按钮样式 不写系统默认的蓝色
@property (nonatomic , readwrite, strong) UIColor *tintColor;
/// 标题的颜色
@property (nonatomic , readwrite, strong) UIColor *titleColor;
/// 信息的颜色
@property (nonatomic , readwrite, strong) UIColor *messageColor;
@end


@interface UIAlertAction (MHColor)

/**< 按钮title字体颜色 */
@property (nonatomic , readwrite, strong) UIColor *textColor;

@end

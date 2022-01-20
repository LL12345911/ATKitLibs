//
//  NSObject+ATAlert.m
//  HighwayDoctor
//
//  Created by Mars on 2019/5/9.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "NSObject+ATAlert.h"
#import <objc/runtime.h>
#import "ATMacro.h"
///**
// * 设置颜色
// */
//#define ATColorFromHexString(__hexString__) [UIColor colorFromHexString:__hexString__]

/// 全局青色 tintColor
//CG_INLINE UIColor* Cat_MAIN_TINTCOLOR(){
//    return [UIColor colorWithRed:(10 / 255.0) green:(193 / 255.0) blue:(42 / 255.0) alpha:1];
//}

@interface NSObject ()

@end


@implementation NSObject (ATAlert)

/**
 系统 不修改的 UIAlertController

 @param title 标题
 @param message 文本信息
 @param confirmTitle 确定按钮标题
 @param cancelTitle 取消按钮标题
 @param confirmAction 确定按钮Block
 @param cancelAction 取消按钮Block
 */
+ (UIAlertController *)at_showAlertViewStyleAlterWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle cancelTitle:(NSString *)cancelTitle confirmAction:(void(^)(void))confirmAction cancelAction:(void(^)(void))cancelAction{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    /// 左边按钮
    if(cancelTitle.length>0){
        UIAlertAction *cancel= [UIAlertAction actionWithTitle:cancelTitle?cancelTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { !cancelAction?:cancelAction(); }];
        [alertController addAction:cancel];
    }
    
    
    if (confirmTitle.length>0) {
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:confirmTitle?confirmTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { !confirmAction?:confirmAction();}];
        [alertController addAction:confirm];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSObject currentController] presentViewController:alertController animated:YES completion:NULL];
    });
    return alertController;
}
/**
 系统 不修改的 UIAlertController (UIAlertControllerStyleActionSheet)
 
 @param actionTitle 按钮标题
 @param action1 按钮1Block
 @param action2Title 按钮2标题
 @param action2 按钮2Block
 @param cancleActionTitle 按钮3标题
 @param cancleAction 按钮3Block
 */
+ (void)at_showAlertViewStyleActionSheetWithActionTitle:(NSString *)actionTitle action1:(void(^)(void))action1 action2Title:(NSString *)action2Title action2:(void(^)(void))action2  cancleActionTitle:(NSString *)cancleActionTitle cancleAction:(void(^)(void))cancleAction{
    
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //相册
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        !action1?:action1();
    }];
    //相机
    UIAlertAction *alert2 = [UIAlertAction actionWithTitle:action2Title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         !action2?:action2();
    }];
    //取消
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancleActionTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        !cancleAction?:cancleAction();
    }];
    [alertCtrl addAction:alert2];
#pragma 隐藏相册选择图片功能
    [alertCtrl addAction:alert1];
    [alertCtrl addAction:cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSObject currentController] presentViewController:alertCtrl animated:YES completion:NULL];
    });
}

+ (void)at_showAlertViewWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle {
    
    [self at_showAlertViewWithTitle:title message:message confirmTitle:confirmTitle confirmAction:nil];
}

+ (void)at_showAlertViewWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle confirmAction:(void(^)(void))confirmAction {
    
    [self at_showAlertViewWithTitle:title message:message confirmTitle:confirmTitle cancelTitle:nil confirmAction:confirmAction cancelAction:NULL];
}

+ (void)at_showAlertViewWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle cancelTitle:(NSString *)cancelTitle confirmAction:(void(^)(void))confirmAction cancelAction:(void(^)(void))cancelAction {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    /// 配置alertController
//    alertController.titleColor =  Color000000();
//    alertController.messageColor = Color333333();
    
    /// 左边按钮
    if(cancelTitle.length>0){
        UIAlertAction *cancel= [UIAlertAction actionWithTitle:cancelTitle?cancelTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { !cancelAction?:cancelAction(); }];
        cancel.textColor = RGBCOLOR(0x999999);//0x8E929D
        [alertController addAction:cancel];
    }
    
    
    if (confirmTitle.length>0) {
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:confirmTitle?confirmTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { !confirmAction?:confirmAction();}];
        //confirm.textColor =  RGBCOLOR(0x5fca8a);//Cat_MAIN_TINTCOLOR();
        [alertController addAction:confirm];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSObject currentController] presentViewController:alertController animated:YES completion:NULL];
    });
}

+ (void)at_showAlertViewWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle action2Title:(NSString *)action2Title cancleTitle:(NSString *)cancleTitle confirmAction:(void(^)(void))confirmAction action2:(void(^)(void))action2 {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    /// 配置alertController
    //    alertController.titleColor =  Color000000();
    //    alertController.messageColor = Color333333();
    
    /// 左边按钮
    if(action2Title.length>0){
        UIAlertAction *cancel= [UIAlertAction actionWithTitle:action2Title?action2Title:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { !action2?:action2(); }];
        //cancel.textColor = RGBCOLOR(0x333333);//0x8E929D
        [alertController addAction:cancel];
    }
    
    
    if (confirmTitle.length>0) {
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:confirmTitle?confirmTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { !confirmAction?:confirmAction();}];
        //confirm.textColor = RGBCOLOR(0x333333);
        [alertController addAction:confirm];
    }
    
    if (cancleTitle.length > 0) {
        UIAlertAction *cancle2 = [UIAlertAction actionWithTitle:cancleTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) { }];
        cancle2.textColor = RGBCOLOR(0x999999);
        [alertController addAction:cancle2];
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSObject currentController] presentViewController:alertController animated:YES completion:NULL];
    });
}
//+ (void)dissmiss{
//    UIViewController *currentView = [NSObject currentViewController];
//    currentView.
//}


/// 查找当前界面有没有一个AlertView.
+(BOOL)isAlert{
    if ([[UIApplication sharedApplication].keyWindow isMemberOfClass:[UIWindow class]])
    {
        return  NO;
    }
    return YES;
}

/// 关闭当前界面上的alertView.
+(void)closeAlert{
    UIViewController* c = [NSObject activityViewController];
    if([c isKindOfClass:[UIAlertController class]]){
        NSLog(@"success");
    }else if([c isKindOfClass:[UINavigationController class]]){
        UINavigationController* d =(UINavigationController*)c;
        
        if([d.visibleViewController isKindOfClass:[UIAlertController class]]){
            UIAlertController* control = (UIAlertController*)d;
            [control dismissViewControllerAnimated:YES completion:^{}];
            NSLog(@"success again");
        }
    }
}
/// 查找当前活动窗口.
+ (UIViewController *)activityViewController{
    UIViewController* activityViewController = nil;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if(window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *tmpWin in windows){
            if(tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    
    NSArray *viewsArray = [window subviews];
    if([viewsArray count] > 0){
        UIView *frontView = [viewsArray objectAtIndex:0];
        
        id nextResponder = [frontView nextResponder];
        
        if([nextResponder isKindOfClass:[UIViewController class]]){
            activityViewController = nextResponder;
        }else{
            activityViewController = window.rootViewController;
        }
    }
    
    return activityViewController;
}


/**
 获取当前控制器
 
 @return 当前控制器
 */
+ (UIViewController *)currentController {
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}


@end




@implementation UIAlertController (ATColor)

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    //按钮统一颜色
    if (self.tintColor) {
        for (UIAlertAction *action in self.actions) {
            if (!action.textColor || action.style != UIAlertActionStyleDestructive) {
                action.textColor = self.tintColor;
            }
        }
    }
}

-(UIColor *)tintColor{
    return objc_getAssociatedObject(self, @selector(tintColor));
}

-(void)setTintColor:(UIColor *)tintColor{
    objc_setAssociatedObject(self, @selector(tintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIColor *)titleColor{
    return objc_getAssociatedObject(self, @selector(titleColor));
}

-(void)setTitleColor:(UIColor *)titleColor{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([UIAlertController class], &count);
    for(int i = 0;i < count;i ++){
        
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        
        //标题颜色
        if ([ivarName isEqualToString:@"_attributedTitle"] && self.title && titleColor) {
             NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:self.title attributes:@{NSForegroundColorAttributeName:titleColor}];
           // NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:self.title attributes:@{NSForegroundColorAttributeName:titleColor,NSFontAttributeName:[UIFont systemFontOfSize:18.0]}];
            [self setValue:attr forKey:@"attributedTitle"];
        }
    }
    
    free(ivars);
    
    objc_setAssociatedObject(self, @selector(titleColor), titleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIColor *)messageColor{
    return objc_getAssociatedObject(self, @selector(messageColor));
}

-(void)setMessageColor:(UIColor *)messageColor{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([UIAlertController class], &count);
    for(int i = 0;i < count;i ++){
        
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        
        //描述颜色
        if ([ivarName isEqualToString:@"_attributedMessage"] && self.message && messageColor) {
            
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.message attributes:@{NSForegroundColorAttributeName:messageColor,NSFontAttributeName:[UIFont systemFontOfSize:16.0]}];
            [self setValue:attr forKey:@"attributedMessage"];
        }
    }
    
    free(ivars);
    
    objc_setAssociatedObject(self, @selector(messageColor), messageColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation UIAlertAction (MHColor)

-(UIColor *)textColor{
    return objc_getAssociatedObject(self, @selector(textColor));
}

//按钮标题的字体颜色
-(void)setTextColor:(UIColor *)textColor{
    if (self.style == UIAlertActionStyleDestructive) {
        return;
    }
    
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([UIAlertAction class], &count);
    for(int i =0; i<count; i++){
        
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        
        if ([ivarName isEqualToString:@"_titleTextColor"]) {
            
            [self setValue:textColor forKey:@"titleTextColor"];
        }
    }
    free(ivars);
    
    objc_setAssociatedObject(self, @selector(textColor), textColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



@end

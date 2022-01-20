//
//  Wolf_Macro.m
//  HighwayDoctor
//
//  Created by Mars on 2019/5/7.
//  Copyright © 2019 Mars. All rights reserved.
//

#import "ATMacro.h"

@implementation ATMacro : NSObject 

+ (BOOL)iPad{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}
// 判断iPhoneX iPhone 11 Pro、iPhone X、iPhone XS
+ (BOOL)iPhoneX{
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && ![ATMacro iPad] : NO);
}
// 判断iPHoneXr
+ (BOOL)iPhoneXR{
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && ![ATMacro iPad] : NO);
}
//// 判断iPhoneXs
//+ (BOOL)iPhoneXs{
//    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && ![ATMacro iPad] : NO);
//}

// 判断 iPhone 11 Pro Max、iPhone 11、iPhone XS Max、iPhone XR
+ (BOOL)iPhoneXMax{
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size)&& ![ATMacro iPad] : NO);
}


@end

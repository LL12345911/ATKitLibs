//
//  ViewController.m
//  Demo
//
//  Created by Mars on 2020/9/23.
//  Copyright © 2020 Mars. All rights reserved.
//

#import "ViewController.h"
#import "ATKitBaseLibs.h"

@interface ViewController ()

@property (nonatomic, strong) NSLock *lock;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    AlignmentLabel* _scopeLab = [[AlignmentLabel alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
    _scopeLab.font = AutoFont(13);
    _scopeLab.textColor = RGBCOLOR(0x999999);
    _scopeLab.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.view addSubview:_scopeLab];
    
    
    CGFloat offsetY = (AutoBlodFont(18).pointSize - AutoBlodFont(15).pointSize) / 2.0;
    AttributeStringBuilder *roadBuild = AttributeStringBuilder.build(@"")
        .appendBackgroundColor([NSString stringWithFormat:@" %@ ", kIfNull(@"2024")], AutoBlodFont(15), RGBCOLOR(0xffffff), RGBCOLOR(0xCE6F17), 5, offsetY)
        .appendSpacing(5)
        .append(kIfNull(@"杀杀杀杀杀杀欢呼声生食和熟食")).font(AutoBlodFont(15));
    
    
    //.append(@" - ").color(RGBCOLOR(0x999999)).font(AutoFont(15));
    //.append(kIfNull(_ProjectYear)).color(RGBCOLOR(0xFB3F33)).font(AutoBlodFont(15));
    // CGFloat offsetY = (AutoBlodFont(15).pointSize - AutoFont(8).pointSize) / 2.0;
    // roadBuild.appendBackgroundColor([NSString stringWithFormat:@"%@", kIfNull(_ProjectYear)], AutoFont(8), RGBCOLOR(0xCE6F17), RGBCOLOR(0xFFF4F4), 0, -offsetY);
    
    _scopeLab.attributedText = [roadBuild commit];
    
    
//    _lock = [[NSLock alloc] init];
//    ATLockEXE00(_lock, ^{
//
//    });
//
//    ATLockEXE10(_lock, ^ATBlock{
//        return [self infoCallback];
//    });
    
    //判断 App是否开启定位权限
    [[AuthorizationManager defaultManager] requestAuthorizationWithAuthorizationType:AuthorizationTypeMapWhenInUseOrMapAlways authorizedHandler:^{
        NSLog(@" =================== ");
        
    } unAuthorizedHandler:^{

        //  NSLog(@"Not granted:%@", _authDataArray[indexPath.row]);
        [NSObject at_showAlertViewWithTitle:@"提示" message:@"此功能,需要App访问你的位置！\n否则无法正常使用此功能！" confirmTitle:@"开启" cancelTitle:@"取消" confirmAction:^{
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                    
                }];
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
#pragma clang diagnostic pop
            }
            
        } cancelAction:^{
        }];
    }];
}

//- (ATBlock)infoCallback{
//    return ^{
//        [self callback:^{
//            NSLog(@"");
//            NSLog(@"");
//            NSLog(@"");
//            NSLog(@"");
//        }];
//    };
//}

- (void)callback:(void (^)(void))block{
    if (!block) {
        return;
    }
    block();
}


@end

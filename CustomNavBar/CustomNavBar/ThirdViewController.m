//
//  ThirdViewController.m
//  CustomNavBar
//
//  Created by apple on 2022/6/19.
//

#import "ThirdViewController.h"

@interface ThirdViewController ()

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (UIColor *)barColor {
    return [UIColor clearColor];
}

- (NSDictionary*)titleStyle {
    
    return @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
}

- (UIColor*)barTintColor {
    
    return [UIColor whiteColor];
}

- (BOOL)isTransparent {
    
    return YES;
    
}

- (UIImage *)shadowImage {
    return [UIImage new];
}

- (UIColor *)shadowColor {
    return [UIColor clearColor];
}

- (UIImage*)backImage {
    return [[UIImage imageNamed:@"backward_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIImage*)backImageMask {
    return [[UIImage imageNamed:@"backward_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end

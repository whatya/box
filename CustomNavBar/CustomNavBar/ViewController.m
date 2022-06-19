//
//  ViewController.m
//  CustomNavBar
//
//  Created by apple on 2022/6/19.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UINavigationBarAppearance *appearance;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self customNavbarStyle];
}

- (void)customNavbarStyle {
    
    // 隐藏返回按钮文字
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    // 设置反复按钮
    [self.navigationController.navigationBar setBackIndicatorImage:[self backImage]];
    
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:[self backImageMask]];
    
    self.navigationController.navigationBar.tintColor = [self barTintColor];
    
    self.navigationController.navigationBar.titleTextAttributes = [self titleStyle];

    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[self barColor]] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.shadowImage = [self shadowImage];
    
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance setBackIndicatorImage:[self backImage] transitionMaskImage:[self backImageMask]];
        [self isTransparent] ? [appearance configureWithTransparentBackground] : [appearance configureWithOpaqueBackground];
        appearance.titleTextAttributes = [self titleStyle];
        [appearance setBackgroundImage:[self imageWithColor:[self barColor]]];
        appearance.shadowColor = [self shadowColor];
        appearance.shadowImage = [self shadowImage];
        
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = self.navigationController.navigationBar.standardAppearance;
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (NSDictionary*)titleStyle {
    
    return @{NSForegroundColorAttributeName: [UIColor blackColor]};
    
}

- (UIColor*)barColor {
    
    return [UIColor clearColor];
    
}

- (UIImage*)shadowImage {
    
    if (@available(iOS 15.0, *)) {
        
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        return appearance.shadowImage;
        
    } else {
        
        UINavigationBar *navigationBar = [[UINavigationBar alloc] init];
        return navigationBar.shadowImage;
    }
}

- (UIColor*)shadowColor {
    
    if (@available(iOS 15.0, *)) {
        
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        return appearance.shadowColor;
        
    } else {
        
        return [UIColor clearColor];
    }
}

- (UIColor*)barTintColor {
    
    return [UIColor blackColor];
    
}

- (BOOL)isTransparent {
    return NO;
}

- (UIImage*)backImage {
    return [[UIImage imageNamed:@"backward_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIImage*)backImageMask {
    return [[UIImage imageNamed:@"backward_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


@end

#import "ViewController.h"
#import "WebView.h"
#import "PressDetectableImage.h"

@interface ViewController ()
 
@end
 
@implementation ViewController
 
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.shadowImage
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"httpServer"];
     NSURL *pathURL = [NSURL fileURLWithPath:filePath];
    
    NSString *url = @"https://whatya.github.io/box/";
    
    WebView *view = [[WebView alloc]initWithFrame:self.view.bounds];
    view.url = url;
    
    view.longBlock = ^(BOOL haveErWeiMa, NSString * _Nonnull qrCodeString, UIImage * _Nonnull image) {
        if (haveErWeiMa)
        {
//            view.url = qrCodeString;
//
//            view.canNotQRcode = YES;
            
            [self alertText:qrCodeString];
        }
    };
    [self.view addSubview:view];
    
    PressDetectableImage *img = [[PressDetectableImage alloc] initWithFrame:CGRectMake(50, 50, 300, 300)];
    img.image = [UIImage imageNamed:@"QR_text"];
    img.backgroundColor = [UIColor redColor];
    [self.view addSubview:img];
    
    PressDetectableImage *img2 = [[PressDetectableImage alloc] initWithFrame:CGRectMake(50, 350, 300, 300)];
    img2.image = [UIImage imageNamed:@"QR_baidu"];
    img2.backgroundColor = [UIColor redColor];
    [self.view addSubview:img2];
}
 
#pragma mark ————————— 弹框 —————————————
-(void)alertText:(NSString *)text
{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"识别图中二维码" message:nil preferredStyle:UIAlertControllerStyleAlert];
 
    [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消");
        
    }]];
 
//    __weak typeof (self)weakSelf = self;
    [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
        NSURL *url = [NSURL URLWithString:text];
        // Safari打开
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
        
    }]];
 
    [self presentViewController:alertC animated:YES completion:nil];
}
 
@end

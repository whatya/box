//
//  PressDetectableImage.m
//  WebCodeDetector
//
//  Created by apple on 2022/6/18.
//

#import "PressDetectableImage.h"
#import <WebKit/WebKit.h>

@interface PressDetectableImage()<UIGestureRecognizerDelegate>

@property(nonatomic,strong) UILongPressGestureRecognizer *longTap;

@end

@implementation PressDetectableImage

#pragma mark -- 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:self.longTap];
    }
    return self;
}

#pragma mark -- 长按手势初始化
-(UILongPressGestureRecognizer *)longTap{
    if (!_longTap)
    {
        _longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
        _longTap.minimumPressDuration = 0.2;
        _longTap.delegate = self;
    }
    return _longTap;
}

#pragma mark -- 手势处理代理
- (void)handleLongTap: (UIGestureRecognizer*)longTap {
    // 防止连续多次调用， 只处理第一次长按识别事件
    if (longTap.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    // 提示保存或识别二维码
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self saveToAblum];
    }];
    UIAlertAction *detectAction = [UIAlertAction actionWithTitle:@"识别二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self detect];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];

    [alert addAction:saveAction];
    [alert addAction:detectAction];
    [alert addAction:cancelAction];
    
    [[self currentViewController] presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 获取父控制器
- (UIViewController *)currentViewController {

    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

#pragma mark -- 保存到相册
- (void)saveToAblum {
    if (self.image) {
        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    } else {
        [self showTip:@"图片获取失败"];
    }
}

#pragma mark -- 相片存相册结果代理
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *tip = error ? @"保存失败" : @"已保存到相册";
    [self showTip:tip];
}

#pragma mark -- tip提示
- (void)showTip:(NSString*)tip {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:tip message:nil preferredStyle:UIAlertControllerStyleAlert];
    [[self currentViewController] presentViewController:alert animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

#pragma mark -- 提取二维码
- (void)detect {
    if (!self.image) {
        [self showTip:@"图片信息提取失败"];
        return;
    }
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:self.image.CGImage]];
    NSString *qrCodeString = [(CIQRCodeFeature*)features.lastObject messageString];
    if (!qrCodeString || qrCodeString.length == 0) {
        [self showTip:@"图片信息提取失败"];
        return;
    }
    // 如果是链接， 打开外部浏览器
    if ([qrCodeString hasPrefix:@"http://"] || [qrCodeString hasPrefix:@"https://"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:qrCodeString]
                                           options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@NO}
                                 completionHandler:nil];
    }
    // 其他情况webview居中显示
    else {
        PlainTextViewerVC *vc = [PlainTextViewerVC new];
        vc.inputString = qrCodeString;
        [[self currentViewController].navigationController pushViewController:vc animated:YES];
    }
    
}

@end

@interface PlainTextViewerVC()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSString *htmlTemplet;

@end

@implementation PlainTextViewerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    if (self.inputString) {
        NSString *tempString = [self.htmlTemplet stringByReplacingOccurrencesOfString:@"##content##" withString:self.inputString];
        self.title = self.inputString;
        [self.webView loadHTMLString:tempString baseURL:nil];
    }
}

- (void)setupUI {
    self.htmlTemplet = @"<html><head><style>body {background-color: white;}#box {width: 100%;height: 100%;padding: 20px;display: flex;justify-content: center;align-items: center;font-size: 60px;white-space:normal;word-break:break-all;word-wrap:break-word;}</style></head><body><div id='box'>##content##</div></body></html>";
    [self.view addSubview:self.webView];
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    }
    return _webView;
}
@end

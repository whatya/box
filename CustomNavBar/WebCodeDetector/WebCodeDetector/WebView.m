//
//  WebView.m
//  WebCodeDetector
//
//  Created by apple on 2022/6/9.
//

#import "WebView.h"
#import <WebKit/WebKit.h>
 
@interface WebView ()
<
WKNavigationDelegate,
WKUIDelegate,
UIGestureRecognizerDelegate
>
@property(nonatomic,strong)UIImage *saveImage;
 
@property(nonatomic,strong) UILongPressGestureRecognizer *longPress;
 
@end
 
@implementation WebView
 
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contentMode = UIViewContentModeRedraw;
        self.opaque = YES;
        self.UIDelegate =self;
        self.navigationDelegate = self;
        self.allowsBackForwardNavigationGestures = YES;
        self.canNotQRcode = NO;
    }
    return self;
}
 
- (void)setCanNotQRcode:(BOOL)canNotQRcode
{
    _canNotQRcode = canNotQRcode;
    if (_canNotQRcode == YES)
    {
        [self removeGestureRecognizer:self.longPress];
    }
    else
    {
        [self addGestureRecognizer:self.longPress];
    }
}
 
-(void)setUrl:(NSString *)url
{
    _url = url;
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}
 
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
 
#pragma mark ————————— 禁止弹出菜单JS代码 —————————————
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    // 禁止弹出菜单JS代码
    NSString *jsString = @"document.documentElement.style.webkitTouchCallout = 'none';";
    
    NSString *jsString2 = @"document.documentElement.style.webkitUserSelect = 'none';";
    
    if (_canNotQRcode == YES)
    {
        jsString = @"document.documentElement.style.webkitTouchCallout = 'default';";
        jsString2 = @"document.documentElement.style.webkitUserSelect = 'default';";
    }
 
//    document.documentElement.style.webkitTouchCallout ='none'; //禁止弹出菜单 default
//    document.documentElement.style.webkitUserSelect = 'none'; //禁止选中 default
    
    [self setJsCodeFromJsString:jsString block:nil];
    
    [self setJsCodeFromJsString:jsString2 block:nil];
}
 
#pragma mark ————————— 系统调用js方法封装 —————————————
-(void)setJsCodeFromJsString:(NSString *)jsString block:(void (^ _Nullable)(id _Nullable ids, NSError * _Nullable error))block
{
    [self evaluateJavaScript:jsString completionHandler:block];
}
 
#pragma mark ————————— 长按 —————————————
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender{
    if (sender.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    CGPoint touchPoint = [sender locationInView:self];
    // 获取长按位置对应的图片url的JS代码
    NSString *imgJS = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x * 2.0, touchPoint.y * 2.0];
    __weak typeof(self) weakSelf = self;
    [self setJsCodeFromJsString:imgJS block:^(id _Nullable ids, NSError * _Nullable error) {
        if (ids) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:ids]];
            UIImage *image = [UIImage imageWithData:data];
            if (!image) {
                NSLog(@"读取图片失败");
                return;
            }
            _saveImage = image;
            [weakSelf isHaveQRcodeFromImage:image block:^(BOOL ishave, NSString *qrCodeString) {
                
                if (weakSelf.longBlock)
                {
                    weakSelf.longBlock(ishave,qrCodeString,image);
                }
            }];
        }
    }];
}
 
#pragma mark ————————— 判断有无二维码并识别二维码 —————————————
- (void)isHaveQRcodeFromImage:(UIImage *)img block:(void(^)(BOOL ishave,NSString *qrCodeString))block
{
    UIImage *image = [self imageFromInsetEdge:UIEdgeInsetsMake(-20, -20, -20, -20) color:[UIColor lightGrayColor] iamge:img];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    BOOL isHave ;
    NSString *qrCodeString = nil;
    if (features.count >= 1)
    {
        CIQRCodeFeature *feature = features.firstObject;
        qrCodeString = [feature.messageString copy];
        NSLog(@"二维码信息:%@", qrCodeString);
        isHave = YES;
    }
    else
    {
        NSLog(@"无可识别的二维码");
        isHave = NO;
    }
    block(isHave,qrCodeString);
}
 
- (UIImage *)imageFromInsetEdge:(UIEdgeInsets)insets color:(UIColor *)color iamge:(UIImage *)iamge
{
    CGSize size = iamge.size;
    size.width -= insets.left + insets.right;
    size.height -= insets.top + insets.bottom;
    if (size.width <= 0 || size.height <= 0) {
        return nil;
    }
    CGRect rect = CGRectMake(-insets.left, -insets.top, iamge.size.width, iamge.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, iamge.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (color) {
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CGPathAddRect(path, NULL, rect);
        CGContextAddPath(context, path);
        CGContextEOFillPath(context);
        CGPathRelease(path);
    }
    [iamge drawInRect:rect];
    UIImage *insetEdgedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return insetEdgedImage;
}
-(UILongPressGestureRecognizer *)longPress{
    if (!_longPress)
    {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPress.minimumPressDuration = 0.2;
        longPress.delegate = self;
        _longPress = longPress;
    }
    return _longPress;
}
#pragma mark ————————— 相片存相册 —————————————
-(void)saveImage:(UIImage *)image
{
    if (image)
    {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    else
    {
        UIImageWriteToSavedPhotosAlbum(_saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}
 
#pragma mark ————————— 相片存相册结果代理 —————————————
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *message;
    if (error)
    {
        message = @"图片保存失败";
    }
    else
    {
        message = @"图片保存成功";
    }
    NSLog(@"%@", message);
}
 
@end

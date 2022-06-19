//
//  WebView.h
//  WebCodeDetector
//
//  Created by apple on 2022/6/9.
//

#import <WebKit/WebKit.h>
 
NS_ASSUME_NONNULL_BEGIN
typedef  void((^LongBlock)(BOOL haveErWeiMa,NSString *qrCodeString,UIImage *image));
@interface WebView : WKWebView
 
/// 加载地址
@property(nonatomic,strong)NSString *url;
 
/// 回调
@property(nonatomic,copy)LongBlock longBlock;
 
 
/// 图片保存
/// @param image image description
-(void)saveImage:(UIImage *)image;
 
 
/// 不可识别二维码吗？ 默认NO
@property(nonatomic,assign)BOOL canNotQRcode;
 
@end
 
NS_ASSUME_NONNULL_END

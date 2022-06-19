//
//  ViewController.h
//  CustomNavBar
//
//  Created by apple on 2022/6/19.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (UIColor*)barColor;

- (NSDictionary*)titleStyle;

- (UIColor*)barTintColor;

- (BOOL)isTransparent;

- (UIImage*)shadowImage;

- (UIColor*)shadowColor;

- (UIImage*)backImage;

- (UIImage*)backImageMask;

@end


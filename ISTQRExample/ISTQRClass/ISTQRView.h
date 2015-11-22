//
//  ISTQRView.h
//  ISTQRExample
//
//  Created by Jone on 15/11/21.
//  Copyright © 2015年 Jone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ISTQRViewDelegate <NSObject>

@end

@interface ISTQRView : UIView

@property (nonatomic, assign) CGSize  clearAreaSize;
@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

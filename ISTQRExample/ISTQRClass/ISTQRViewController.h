//
//  ISTQRViewController.h
//  ISTQRExample
//
//  Created by Jone on 15/11/22.
//  Copyright © 2015年 Jone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^QRResultBlock) (NSString *result);

@class ISTQRViewController;
@protocol ISTQRViewControllerDeletage <NSObject>

- (void)QRViewControlelr:(ISTQRViewController *)QRViewController didFinishScan:(NSString *)scanResult;;

@end

@interface ISTQRViewController : UIViewController

@property (nonatomic, weak) id<ISTQRViewControllerDeletage> delegate;

@end

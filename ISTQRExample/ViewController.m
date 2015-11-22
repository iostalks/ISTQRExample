//
//  ViewController.m
//  ISTQRExample
//
//  Created by Jone on 15/11/21.
//  Copyright © 2015年 Jone. All rights reserved.
//

#import "ViewController.h"
#import "ISTQRViewController.h"

@interface ViewController ()<ISTQRViewControllerDeletage>

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)openAction:(id)sender
{
    ISTQRViewController *qrVC = [[ISTQRViewController alloc] init];
    qrVC.delegate = self;
    [self.navigationController pushViewController:qrVC animated:YES];
}

- (void)QRViewControlelr:(ISTQRViewController *)QRViewController didFinishScan:(NSString *)scanResult
{
    self.resultLabel.text = scanResult;
}

@end

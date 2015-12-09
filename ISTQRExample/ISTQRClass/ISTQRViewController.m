//
//  ISTQRViewController.m
//  ISTQRExample
//
//  Created by Jone on 15/11/22.
//  Copyright © 2015年 Jone. All rights reserved.
//

#import "ISTQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ISTQRView.h"

typedef NS_ENUM( NSInteger, ISTCamSetupResult ) {
    ISTCamSetupResultSuccess,
    ISTCamSetupResultCameraNotAuthorized,
    ISTCamSetupResultSessionConfigurationFailed
};

CGFloat const kISTClearAreaWidth = 250.0;
static const char * kISTScanQueueName = "kISTScanQueueName";

@interface ISTQRViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) ISTQRView *qrView;
@property (nonatomic, strong) UIButton  *torchBtn;
@property (nonatomic) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic) AVCaptureMetadataOutput *captureMetadataOutput;
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic) ISTCamSetupResult setupResult;

@end

@implementation ISTQRViewController

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"条码/二维码扫描", @"ISTTitleKey");
    
    [self configNavi];
    
    [self configQRView];
    
    // 检查设别授权状态，Video类型必选，Audio类型可选
    [self checkAuthorizationStatus];
    
     [self setupCaptureSession];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self startScan];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopScan];
}

- (void)viewWillLayoutSubviews
{
    CGFloat screenWidth  = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    self.torchBtn.frame  = (CGRect){0, 0, 46, 46};
    self.qrView.frame    = (CGRect){0, 0, screenWidth, screenHeight};
    self.qrView.clearAreaSize = (CGSize){kISTClearAreaWidth, kISTClearAreaWidth};
}

#pragma mark - Configure views

- (void)configNavi
{
    self.torchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.torchBtn setTitleColor:[UIColor colorWithRed:0.148 green:0.749 blue:0.217 alpha:1.000] forState:UIControlStateNormal];
    [self.torchBtn setTitle:@"ON" forState:UIControlStateNormal];
    [self.torchBtn setTitle:@"OFF" forState:UIControlStateSelected];
    [self.torchBtn addTarget:self
                 action:@selector(openTorchBtnOnTouched:)
       forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *torchButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.torchBtn];
    self.navigationItem.rightBarButtonItem = torchButtonItem;
}

- (void)configQRView
{
    self.qrView = [[ISTQRView alloc] init];
    self.qrView.backgroundColor = [UIColor clearColor];
    
    [self.qrView.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.view addSubview:self.qrView];
    
}

#pragma mark - Setup

- (void)checkAuthorizationStatus
{
    switch ( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio])
    {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                if ( ! granted ) {
                    self.setupResult = ISTCamSetupResultCameraNotAuthorized;
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:
        {
            // 已授权
            break;
        }
        default: {
            self.setupResult = ISTCamSetupResultCameraNotAuthorized;
            break;
        }
    }
}

- (void)setupCaptureSession
{
        if (self.setupResult != ISTCamSetupResultSuccess) {
            return;
        }
        
        NSError * error;
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // metadata input
        _captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (!_captureDeviceInput) {
            [self showAlertViewWithMessage:[error localizedDescription]];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        // session
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        if ([_captureSession canAddInput:_captureDeviceInput]) {
            [_captureSession addInput:_captureDeviceInput];
        }
        
        AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        if ([_captureSession canAddOutput:captureMetadataOutput]) {
            [_captureSession addOutput:captureMetadataOutput];
        }
        
        // create output dispatch queue.
        dispatch_queue_t dispatchQueue;
        dispatchQueue = dispatch_queue_create(kISTScanQueueName, NULL);
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
        
        // setup metadata type
        [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeEAN13Code,
                                                        AVMetadataObjectTypeEAN8Code,
                                                        AVMetadataObjectTypeCode128Code,
                                                        AVMetadataObjectTypeQRCode]];
    
}

- (void)startScan
{
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        _videoPreviewLayer.frame = [UIScreen mainScreen].bounds;
        _videoPreviewLayer.videoGravity = AVLayerVideoGravityResize;
        [self.view.layer insertSublayer:_videoPreviewLayer atIndex:0];
        
        [_captureSession startRunning];
}

- (void)stopScan
{
        [_captureSession stopRunning];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            // 必须释放displayLink
            [self.qrView.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            self.qrView = nil;
            
        });
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
                                                                 fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        [self stopScan];
        
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result = metadataObj.stringValue;
        
        [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:result waitUntilDone:NO];
    }
}

- (void)reportScanResult:(NSString *)result
{
    if ([_delegate respondsToSelector:@selector(QRViewControlelr:didFinishScan:)]) {
        [_delegate QRViewControlelr:self didFinishScan:result];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - Torch on/off action

- (void)openTorchBtnOnTouched:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        
        [device lockForConfiguration:nil];
        if (sender.selected) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        
        [device unlockForConfiguration];
    }
}

#pragma mark - Alert view

- (void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Prompt" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


@end

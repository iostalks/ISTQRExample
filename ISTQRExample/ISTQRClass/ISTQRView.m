//
//  ISTQRView.m
//  ISTQRExample
//
//  Created by Jone on 15/11/21.
//  Copyright © 2015年 Jone. All rights reserved.
//

#import "ISTQRView.h"

#define IST_SCREEN_BOUNDS  [[UIScreen mainScreen] bounds]

@interface ISTQRView()

@property (nonatomic, strong) UIImageView *qrLineImageView;
//@property (nonatomic, strong) CADisplayLink *displayLink;

@end


@implementation ISTQRView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
         [self commonInitialize];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInitialize];
    }
    
    return self;
}

- (void)layoutSubviews
{
    self.qrLineImageView.center = self.center;
    CGFloat lineWidth = 220;
    CGFloat lineOrigin_x = self.center.x - lineWidth / 2;
    CGFloat lineOrigin_y = self.center.y - _clearAreaSize.width / 2;
    
    self.qrLineImageView.frame = (CGRect){lineOrigin_x, lineOrigin_y, lineWidth, 5};
}

- (void)commonInitialize
{
    [self initializeQRLine];

    __weak __typeof (self) weakSelf = self;
    self.displayLink = [CADisplayLink displayLinkWithTarget:weakSelf
                                                   selector:@selector(displayLinkAction)];
//    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)initializeQRLine
{
    self.qrLineImageView = [[UIImageView alloc] init];
    self.qrLineImageView.image = [UIImage imageNamed:@"ist_qr_line"];
    [self addSubview:self.qrLineImageView];
}

#pragma mark - Action

- (void)displayLinkAction
{
    CGRect lineFrame = _qrLineImageView.frame;
    CGFloat ending_y = self.center.y + _qrLineImageView.frame.size.width / 2;
    if (_qrLineImageView.frame.origin.y > ending_y) {
        lineFrame.origin.y = self.center.y - _clearAreaSize.width / 2;
    }

    lineFrame.origin.y ++;
    _qrLineImageView.frame = lineFrame;
    
    NSLog(@"%f****%f",_qrLineImageView.frame.origin.y,lineFrame.origin.y);
}

#pragma mark - Draw layer

- (void)drawRect:(CGRect)rect
{
    CGFloat clearRectOriginX = CGRectGetWidth(IST_SCREEN_BOUNDS) / 2 - _clearAreaSize.width / 2;
    CGFloat clearRectOriginY = CGRectGetHeight(IST_SCREEN_BOUNDS) / 2 - _clearAreaSize.height / 2;
    CGRect clearDrawRect = (CGRect){clearRectOriginX, clearRectOriginY, _clearAreaSize};
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self drawFillScreenRectWithContext:ctx];
    [self drawCenterClearRect:clearDrawRect context:ctx];
    [self drawCenterClearRect:clearDrawRect context:ctx];
//    [self drawCornerLineRect:clearDrawRect context:ctx];
    [self drawFourCornerLineRect:clearDrawRect context:ctx];
}

/**
 *  fill screen with hud
 */
- (void)drawFillScreenRectWithContext:(CGContextRef)ctx
{
    CGContextSetRGBFillColor(ctx, 40 / 255.0,40 / 255.0,40 / 255.0,0.5);
    CGContextFillRect(ctx, IST_SCREEN_BOUNDS);
}

/**
 *  clear the middle area
 */
- (void)drawCenterClearRect:(CGRect)rect context:(CGContextRef)ctx
{
    CGContextClearRect(ctx, rect);
}

/**
 *
 */
- (void)drawCornerLineRect:(CGRect)rect context:(CGContextRef)ctx
{
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 1);
    CGContextSetLineWidth(ctx, 0.8);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}

/**
 *  draw four corner
 */
- (void)drawFourCornerLineRect:(CGRect)rect context:(CGContextRef)ctx
{
    
    CGContextSetLineWidth(ctx, 2);
    CGContextSetRGBStrokeColor(ctx, 83 /255.0, 239/255.0, 111/255.0, 1); //绿色
    
    CGFloat rect_x     = rect.origin.x;
    CGFloat rect_y     = rect.origin.y;
    CGFloat rect_w     = rect.size.width;
    CGFloat rect_h     = rect.size.height;
    CGFloat lineLenth = 15.0;
    CGFloat offset    = 0.7;

    // top left corner
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect_x + offset, rect_y),
        CGPointMake(rect_x + offset , rect_y + lineLenth)
    };
    
    CGPoint poinsTopLeftB[] = {
        CGPointMake(rect_x, rect_y + offset),
        CGPointMake(rect_x + lineLenth, rect_y + offset)};
    
    [self drawLineFromPoint:poinsTopLeftA toPointB:poinsTopLeftB ctx:ctx];
    
    
    // bottom left corner
    CGPoint poinsBottomLeftA[] = {
        CGPointMake(rect_x + offset, rect_y + rect_h - lineLenth),
        CGPointMake(rect_x + offset, rect_y + rect_h)
    };
    
    CGPoint poinsBottomLeftB[] = {
        CGPointMake(rect_x , rect_y + rect_h - offset),
        CGPointMake(rect_x + offset + lineLenth, rect_y + rect_h - offset)
    };
    
    [self drawLineFromPoint:poinsBottomLeftA toPointB:poinsBottomLeftB ctx:ctx];
    
    
    // top right corner
    CGPoint poinsTopRightA[] = {
        CGPointMake(rect_x + rect_w - lineLenth, rect_y + offset),
        CGPointMake(rect_x + rect_w, rect_y + offset)
    };
    
    CGPoint poinsTopRightB[] = {
        CGPointMake(rect_x + rect_w - offset, rect_y),
        CGPointMake(rect_x + rect_w - offset, rect_y + lineLenth + offset)
    };
    
    [self drawLineFromPoint:poinsTopRightA toPointB:poinsTopRightB ctx:ctx];
    
    // bottom right corner
    CGPoint poinsBottomRightA[] = {
        CGPointMake(rect_x + rect_w - offset, rect_y + rect_h - lineLenth),
        CGPointMake(rect_x + rect_w - offset, rect_y + rect_h)
    };
    
    CGPoint poinsBottomRightB[] = {
        CGPointMake(rect_x + rect_w - 15 , rect_y + rect_h - offset),
        CGPointMake(rect_x + rect_w, rect_y + rect_h - offset)
    };
    
    [self drawLineFromPoint:poinsBottomRightA toPointB:poinsBottomRightB ctx:ctx];

    
    CGContextStrokePath(ctx);
}

- (void)drawLineFromPoint:(CGPoint[])pointA toPointB:(CGPoint[])pointB ctx:(CGContextRef)ctx
{
    CGFloat lineWidth = 2.0;
    CGContextAddLines(ctx, pointA, lineWidth);
    CGContextAddLines(ctx, pointB, lineWidth);
}

#pragma mark -

- (NSMutableArray *)changeUIColorToRGB:(UIColor *)color
{
    size_t  n = CGColorGetNumberOfComponents(color.CGColor);
    const CGFloat rgba = *CGColorGetComponents(color.CGColor);
    NSMutableArray *resultArr = [NSMutableArray arrayWithCapacity:n];
    for (int i = 0; i < n; i++)
    {
        [resultArr addObject:[NSNumber numberWithFloat:rgba]];
    }
    return resultArr;
}
@end

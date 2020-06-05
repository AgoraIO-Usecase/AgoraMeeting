//
//  ScaleView.m
//  VideoConference
//
//  Created by SRS on 2020/5/25.
//  Copyright © 2020 agora. All rights reserved.
//

#import "ScaleView.h"
#import "UIViewAdditions.h"

#define BOUNDCE_DURATION 0.3f

@interface ScaleView()

@property (nonatomic, weak) UIView *hostView;

@end

@implementation ScaleView
- (void)awakeFromNib {
    [super awakeFromNib];

//    UIView *vv = [[UIView alloc] initWithFrame: self.bounds];
//    [self addSubview:vv];
//    self.contentView = vv;
//    self.hostView = vv;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//        [self initView];
//    });
}

- (void)initView {
    self.contentView.frame = self.bounds;
    [self addGestureRecognizers];
}

// register all gestures
- (void) addGestureRecognizers
{
    // add pinch gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self addGestureRecognizer:pinchGestureRecognizer];
    
    // add pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

- (void)pinchView:(UIPinchGestureRecognizer *)pinch {
    CGFloat screenScale = UIScreen.mainScreen.scale;
    if (screenScale < 3 && MIN(kScreenWidth, kScreenHeight) < 400) {
        CGFloat scale = pinch.scale - 1;
        
        CGFloat constantX = self.hostView.width + self.width * scale;
        CGFloat constantY = self.hostView.height + self.height * scale;

        // scale must small than 3
        self.hostView.width = MIN(constantX, self.width * 2);
        self.hostView.height = MIN(constantY, self.height * 2);
        
        if (self.hostView.width < 0) {
            [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
                self.hostView.width = 0;
                self.hostView.height = 0;
            }];
        }
    } else {
        CGFloat scale = pinch.scale;
        if(pinch.view == nil){
            return;
        }
        CGAffineTransform currentTransform = pinch.view.transform;
        CGFloat transformScale = 3;
        if(currentTransform.a * scale < 3){
            transformScale = currentTransform.a * scale;
        }
        
        pinch.view.transform = CGAffineTransformMakeScale(transformScale, transformScale);
        if(pinch.view.width < self.width){
            [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
                pinch.view.transform = CGAffineTransformIdentity;
            }];
        }
    }

    [self updateScaleView];
    pinch.scale = 1.0;
}

- (void)panView:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self];
    self.hostView.centerX += point.x;
    self.hostView.centerY += point.y;
    [self updateScaleView];
    [pan setTranslation:CGPointZero inView:self.superview];
}

- (void)updateScaleView {
    if (self.hostView.centerX + self.hostView.width / 2 < self.width) {
        self.hostView.centerX += self.width - (self.hostView.centerX + self.hostView.width / 2);
    }
    
    if (self.hostView.centerX - self.hostView.width / 2 > 0) {
        self.hostView.centerX -= self.hostView.centerX - self.hostView.width / 2;
    }
    
    if (self.hostView.centerY + self.hostView.height / 2 < self.height) {
        self.hostView.centerY += self.height - (self.hostView.centerY + self.hostView.height / 2);
    }
       
    if (self.hostView.centerY - self.hostView.height / 2 > 0) {
        self.hostView.centerY -= self.hostView.centerY - self.hostView.height / 2;
    }
}

@end

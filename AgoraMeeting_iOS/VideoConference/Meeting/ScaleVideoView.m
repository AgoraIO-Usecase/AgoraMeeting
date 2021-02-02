//
//  ScalView.m
//  ScaleDemo
//
//  Created by ZYP on 2021/1/29.
//

#import "ScaleVideoView.h"

@interface ScaleVideoView ()<UIScrollViewDelegate>

@property(nonatomic, strong)UIScrollView *scrollView;



@end

@implementation ScaleVideoView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.userInteractionEnabled = true;
    [self.scrollView addSubview:self.videoView];
    [self addSubview:self.scrollView];
}

/// 设置内容的大小
- (void)configContentSize:(CGSize)size {
    CGRect newFrame = CGRectMake(0, 0, size.width, size.height);
    self.scrollView.frame = newFrame;
    self.videoView.frame = newFrame;
    self.scrollView.contentSize = size;
}

#pragma mark -- 懒加载
-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 8;
        _scrollView.backgroundColor = UIColor.clearColor;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIView *)videoView {
    if (!_videoView) {
        _videoView = [UIView new];
        _videoView.backgroundColor = UIColor.clearColor;
    }
    return _videoView;
}

#pragma mark -- UIScrollViewDelegate

// 缩放后的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.videoView;
}

// 调整视图位置
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect frame = self.videoView.frame;
    
    frame.origin.y = (self.scrollView.frame.size.height - self.videoView.frame.size.height) > 0 ? (self.scrollView.frame.size.height - self.videoView.frame.size.height) * 0.5 : 0;
    frame.origin.x = (self.scrollView.frame.size.width - self.videoView.frame.size.width) > 0 ? (self.scrollView.frame.size.width - self.videoView.frame.size.width) * 0.5 : 0;
    self.videoView.frame = frame;
    
    self.scrollView.contentSize = CGSizeMake(self.videoView.frame.size.width, self.videoView.frame.size.height);
}




@end

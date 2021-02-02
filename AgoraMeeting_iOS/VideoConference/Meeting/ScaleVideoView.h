//
//  ScalView.h
//  ScaleDemo
//
//  Created by ZYP on 2021/1/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScaleVideoView : UIView

/// 设置内容的大小
- (void)configContentSize:(CGSize)size;
@property(nonatomic, strong)UIView *videoView;

@end

NS_ASSUME_NONNULL_END

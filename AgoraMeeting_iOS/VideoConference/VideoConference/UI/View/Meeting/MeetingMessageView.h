//
//  MessageView.h
//  VideoConference
//
//  Created by ZYP on 2021/1/5.
//  Copyright © 2021 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MeetingMessageModel;



@protocol MeetingMessageViewDelegate <NSObject>

- (void)messageViewDidTapButton:(MeetingMessageModel *_Nonnull)model;

@end

@protocol MeetingMessageViewUIDelegate <NSObject>

- (void)messageViewShouldUpdateSize:(CGSize)size;

@end


NS_ASSUME_NONNULL_BEGIN

@interface MeetingMessageView : UIView

@property (nonatomic, weak)id<MeetingMessageViewDelegate> delegate;
@property (nonatomic, weak)id<MeetingMessageViewUIDelegate> uiDelegate;

- (void)updateModels:(NSArray<MeetingMessageModel *> *)models;
- (void)setHiddenAnimate:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END

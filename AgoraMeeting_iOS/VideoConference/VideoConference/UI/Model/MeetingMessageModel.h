//
//  MessageInfo.h
//  VideoConference
//
//  Created by ZYP on 2021/1/6.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeetingMessageModel : NSObject

@property (nonatomic, copy)NSString * _Nullable name;
@property (nonatomic, copy)NSString *info;
/** 是否显示按钮 **/
@property (nonatomic, assign)BOOL showButton;
/** 按钮是否有效 **/
@property (nonatomic, assign)BOOL buttonEnable;
/** 剩余时间 **/
@property (nonatomic, assign)NSUInteger remianCount;

@property (nonatomic, strong)NSString *buttonTitle;

@property (nonatomic, assign)NSInteger typeValue;

@property (nonatomic, copy)NSString *targetUserId;

@property (nonatomic, assign)NSTimeInterval timeStamp;

@end

NS_ASSUME_NONNULL_END

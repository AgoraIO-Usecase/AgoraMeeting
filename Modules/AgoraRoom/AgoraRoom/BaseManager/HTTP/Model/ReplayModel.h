//
//  ReplayModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/3/3.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecordDetailsModel : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) NSInteger role;//1老师 2学生
@property (nonatomic, strong) NSString *url;

@end

@interface ReplayInfoModel : NSObject

@property (nonatomic, strong) NSString *recordId;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, assign) NSInteger status;

@property (nonatomic, strong) NSString *boardId;
@property (nonatomic, strong) NSString *boardToken;

@property (nonatomic, strong) NSArray<RecordDetailsModel*> *recordDetails;

@end


@interface ReplayModel : BaseModel

@property (nonatomic, strong) ReplayInfoModel *data;

@end

NS_ASSUME_NONNULL_END

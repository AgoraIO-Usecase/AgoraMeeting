//
//  ConfUserListModel.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/20.
//  Copyright © 2020 agora. All rights reserved.
//

#import "BaseModel.h"
#import "ConfUserListInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfUserListModel : BaseModel
@property (nonatomic, strong) ConfUserListInfoModel *data;
@end

NS_ASSUME_NONNULL_END

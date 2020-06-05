//
//  WhiteModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/4/16.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"
#import "WhiteInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WhiteModel : BaseModel

@property (nonatomic, strong) WhiteInfoModel *data;

@end

NS_ASSUME_NONNULL_END

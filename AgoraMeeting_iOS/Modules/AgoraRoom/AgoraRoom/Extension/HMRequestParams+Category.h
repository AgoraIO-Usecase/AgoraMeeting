//
//  HMRequestParams+Category.h
//  AgoraRoom
//
//  Created by ZYP on 2021/2/8.
//  Copyright © 2021 agora. All rights reserved.
//

#import "HMRequestParams.h"
@class ARConferenceEntryParams;

NS_ASSUME_NONNULL_BEGIN

@interface HMReqParamsAddRoom (Category)

+ (HMReqParamsAddRoom *)instanceWithEntryParams:(ARConferenceEntryParams *)entryParams;

@end

NS_ASSUME_NONNULL_END

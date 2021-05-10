//
//  HMRequestParams+Category.m
//  AgoraRoom
//
//  Created by ZYP on 2021/2/8.
//  Copyright © 2021 agora. All rights reserved.
//

#import "HMRequestParams.h"
#import "ARConferenceEntryParams.h"
#import "HMRequestParams+Category.h"

@implementation HMReqParamsAddRoom (Category)

+ (HMReqParamsAddRoom *)instanceWithEntryParams:(ARConferenceEntryParams *)entryParams {
    HMReqParamsAddRoom *params  = [HMReqParamsAddRoom new];
    params.userName = entryParams.userName;
    params.userId = entryParams.userUuid;
    params.password = entryParams.password;
    params.roomName = entryParams.roomName;
    params.roomId = entryParams.roomUuid;
    params.cameraAccess = entryParams.videoAccess;
    params.micAccess = entryParams.audioAccess;
    params.duration = 45*60;
    params.totalPeople = 1000;
    return params;
}

@end

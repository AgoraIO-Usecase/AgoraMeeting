//
//  URL.h
//  AgoraEdu
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HTTP_EDU_HOST_URL @"/edu/"
#define HTTP_MEET_HOST_URL @"/meeting/"

#define HTTP_BASE_URL @"https://api.agora.io/scenario/meeting"

#define HTTP_GET_CONFIG @"%@/v1/app/version"

// http: get app config
#define HTTP_LOG_PARAMS @"%@/v1/log/params"
// http: get app config
#define HTTP_OSS_STS @"%@/v1/log/sts"
// http: get app config
#define HTTP_OSS_STS_CALLBACK @"%@/v1/log/sts/callback"

// /conf/apps/{appId}/v1/room/entry
#define HTTP_ENTER_ROOM1 @"%@/v1/room/entry"
#define HTTP_ENTER_ROOM2 @"%@/apps/%@/v1/room/entry"

// /edu/apps/{appId}/v1/room/exit
#define HTTP_LEFT_ROOM @"%@/apps/%@/v1/room/%@/exit"
// /conf/apps/{appId}/v1/room/{roomId}/user/{userId}/exit
#define HTTP_CONF_LEFT_ROOM @"%@/apps/%@/v1/room/%@/user/%@/exit"

// http: get or update global state
// /edu/apps/{appId}/v1/room/{roomId}
#define HTTP_ROOM_INFO @"%@/apps/%@/v1/room/%@"

#warning You need to use your own backend service API
// http: get white board keys in room
// /edu/apps/{appId}/v1/room/{roomId}
#define HTTP_WHITE_ROOM_INFO @"%@/apps/%@/v1/room/%@/board"

// http: update room info
// /edu/apps/{appId}/v1/room/{roomId}
#define HTTP_UPDATE_ROOM_INFO @"%@/apps/%@/v1/room/%@"

// http: update user info
// /edu/apps/{appId}/v1/room/{roomId}/user/{userId}
#define HTTP_UPDATE_USER_INFO @"%@/apps/%@/v1/room/%@/user/%@"

// http: change host
// /conf/apps/{appId}/v1/room/{roomId}/user/{userId}/host
#define HTTP_CHANGE_HOST @"%@/apps/%@/v1/room/%@/user/%@/host"

// http: change board
// /conf/apps/{appId}/v1/room/{roomId}/user/{userId}/board
#define HTTP_BOARD_STATE @"%@/apps/%@/v1/room/%@/user/%@/board"

// http: audience action
// /conf/apps/{appId}/v1/room/{roomId}/user/{userId}/audience/apply
#define HTTP_AUDIENCE_ACTION @"%@/apps/%@/v1/room/%@/user/%@/audience/apply"

// http: host action
// /conf/apps/{appId}/v1/room/{roomId}/user/{userId}/host/invite
#define HTTP_HOTS_ACTION @"%@/apps/%@/v1/room/%@/user/%@/host/invite"

// http: get userlist info
// /conf/apps/{appId}/v1/room/{roomId}/user/page
#define HTTP_USER_LIST_INFO @"%@/apps/%@/v1/room/%@/user/page"

// http: im
// /edu/apps/{appId}/v1/room/{roomId}/chat
#define HTTP_USER_INSTANT_MESSAGE @"%@/apps/%@/v1/room/%@/chat"

// http: covideo
// /edu/apps/{appId}/v1/room/{roomId}/covideo
#define HTTP_USER_COVIDEO @"%@/apps/%@/v1/room/%@/covideo"

// http: get replay info
// /edu/apps/{appId}/v1/room/{roomId}/record/{recordId}
#define HTTP_GET_REPLAY_INFO @"%@/apps/%@/v1/room/%@/record/%@"

// Error
typedef NS_ENUM(NSInteger, LocalAgoraErrorCode) {
    LocalAgoraErrorCodeCommon = 999,
};
#define LocalErrorDomain @"io.agora.AgoraRoom"
#define LocalError(errCode,reason) ([NSError errorWithDomain:LocalErrorDomain \
    code:(errCode) \
userInfo:@{NSLocalizedDescriptionKey:(reason)}])

// Localized
#define Localized(des) NSLocalizedString(des, nil)


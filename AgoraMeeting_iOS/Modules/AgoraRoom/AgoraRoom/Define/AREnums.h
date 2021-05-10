//
//  AREnums.h
//  VideoConference
//
//  Created by ZYP on 2021/1/11.
//  Copyright © 2021 agora. All rights reserved.
//

#ifndef AREnums_h
#define AREnums_h


typedef NS_ENUM(NSInteger, ARConsolePrintType) {
    ARConsolePrintTypeNone = 0,
    ARConsolePrintTypeDebug = 1,
    ARConsolePrintTypeInfo = 2,
    ARConsolePrintTypeWarning = 4,
    ARConsolePrintTypeError = 8,
    ARConsolePrintTypeAll = 15
};

/// 场景类型
typedef NS_ENUM(NSInteger, SceneType) {
    SceneTypeEducation      = 1,
    SceneTypeConference     = 2,
};


#endif /* AREnums_h */



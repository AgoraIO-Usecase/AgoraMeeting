//
//  Constant.h
//  ReplayAlignLib
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 agora. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#ifndef AgoraLogInfo
#define AgoraLogInfo(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#endif

#endif /* Constant_h */

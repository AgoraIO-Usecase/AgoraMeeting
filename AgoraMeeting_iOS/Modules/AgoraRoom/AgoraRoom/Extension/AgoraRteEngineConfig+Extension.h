//
//  AgoraRteEngineConfig+Extension.h
//  AgoraRoom
//
//  Created by ZYP on 2021/1/7.
//  Copyright © 2021 agora. All rights reserved.
//

#import <AgoraRte/AgoraRteObjects.h>
#import <Foundation/Foundation.h>

@class ARConferenceEntryParams;

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRteEngineConfig (Extension)

+ (AgoraRteEngineConfig *)instanceWithEntryparams:(ARConferenceEntryParams *)params;

@end

NS_ASSUME_NONNULL_END

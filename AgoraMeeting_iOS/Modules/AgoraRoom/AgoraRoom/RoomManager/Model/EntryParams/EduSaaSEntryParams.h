//
//  EduSaaSEntryParams.h
//  AgoraRoom
//
//  Created by SRS on 2020/5/18.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EntryParams.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduSaaSEntryParams : EntryParams

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) UserRoleType role;

@end

NS_ASSUME_NONNULL_END

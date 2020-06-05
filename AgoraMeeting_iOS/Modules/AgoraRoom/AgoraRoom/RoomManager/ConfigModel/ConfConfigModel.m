//
//  EduConfigModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/21.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "ConfConfigModel.h"

static ConfConfigModel *manager = nil;

@implementation ConfConfigModel

+ (instancetype)shareInstance {
    if(!manager){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [ConfConfigModel new];
        });
    }
    return manager;
}

// 防止使用alloc开辟空间
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if(!manager){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [super allocWithZone:zone];
        });
    }
    return manager;
}

@end

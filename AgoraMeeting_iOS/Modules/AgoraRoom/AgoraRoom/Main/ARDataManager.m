//
//  ARDataManager.m
//  AgoraRoom
//
//  Created by ZYP on 2021/1/7.
//  Copyright © 2021 agora. All rights reserved.
//

#import "ARDataManager.h"

static ARDataManager *manager = nil;

@implementation ARDataManager

+ (instancetype)share {
    if(!manager){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [ARDataManager new];
            manager.requsetQueue = dispatch_queue_create("com.agore.room.conferenceManager", DISPATCH_QUEUE_SERIAL);
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

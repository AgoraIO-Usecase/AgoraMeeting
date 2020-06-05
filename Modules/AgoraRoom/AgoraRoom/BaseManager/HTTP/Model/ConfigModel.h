//
//  ConfigModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/6.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseModel.h"
#import "MultiLanguageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfigInfoModel : NSObject

@property (nonatomic, strong) NSString* version;

@property (nonatomic, strong) NSString* oneToOneTeacherLimit;
@property (nonatomic, strong) NSString* smallClassTeacherLimit;
@property (nonatomic, strong) NSString* largeClassTeacherLimit;

@property (nonatomic, strong) NSString* oneToOneStudentLimit;
@property (nonatomic, strong) NSString* smallClassStudentLimit;
@property (nonatomic, strong) NSString* largeClassStudentLimit;

@property (nonatomic, strong) MultiLanguageModel* multiLanguage;

@end

@interface ConfigAllInfoModel : NSObject

@property (nonatomic, strong) NSString *appCode;
@property (nonatomic, assign) NSInteger osType;
@property (nonatomic, assign) NSInteger terminalType;
@property (nonatomic, strong) NSString *appVersion;
@property (nonatomic, strong) NSString *latestVersion;
@property (nonatomic, strong) NSString *appPackage;
@property (nonatomic, strong) NSString *upgradeDescription;
@property (nonatomic, assign) NSInteger forcedUpgrade;//1 no update 2update 3force update
@property (nonatomic, strong) NSString *upgradeUrl;
@property (nonatomic, assign) NSInteger reviewing;
@property (nonatomic, strong) NSString *apiHost;
@property (nonatomic, assign) NSInteger remindTimes;

@property (nonatomic, strong) ConfigInfoModel *configInfoModel;

@end


@interface ConfigModel : BaseModel

@property (nonatomic, strong) ConfigAllInfoModel* data;

@end

NS_ASSUME_NONNULL_END

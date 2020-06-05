//
//  ConfigModel.m
//  AgoraEducation
//
//  Created by SRS on 2020/1/6.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "ConfigModel.h"

@implementation ConfigInfoModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"oneToOneStudentLimit": @"1on1StudentLimit",
             @"oneToOneTeacherLimit": @"1on1TeacherLimit"};
}

+ (NSDictionary *)objectClassInArray {
    return @{@"multiLanguage" : [MultiLanguageModel class]};
}

@end

@implementation ConfigAllInfoModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"configInfoModel": @"config"};
}
@end


@implementation ConfigModel

@end



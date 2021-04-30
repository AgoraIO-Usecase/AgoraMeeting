//
//  SetCenterTextCell.m
//  VideoConference
//
//  Created by SRS on 2020/5/10.
//  Copyright © 2020 agora. All rights reserved.
//

#import "SetCenterTextCell.h"

@implementation SetCenterTextCell

- (void)setLoadingState:(BOOL)enable {
    [self.tipText setHidden:enable];
    enable ? [self.loading startAnimating] : [self.loading stopAnimating];
    [self.loading setHidden:!enable];
}

+ (NSString *)idf {
    return @"SetCenterTextCell";
}

+ (NSString *)nibName {
    return [SetCenterTextCell idf];
}

@end

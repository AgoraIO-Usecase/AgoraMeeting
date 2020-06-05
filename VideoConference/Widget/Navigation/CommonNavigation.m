//
//  CommonNavigation.m
//  VideoConference
//
//  Created by SRS on 2020/5/8.
//  Copyright © 2020 agora. All rights reserved.
//

#import "CommonNavigation.h"

@interface CommonNavigation()
@property (strong, nonatomic) IBOutlet CommonNavigation *navigation;
@end

@implementation CommonNavigation

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.navigation];
        [self.navigation equalTo:self];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (void)initView {

}

- (IBAction)onBackBtnClick:(id)sender {
    
    if(self.backBlock == nil){
        [VCManager popTopView];
    } else {
        self.backBlock();
    }
}

- (IBAction)onRightBtnClick:(id)sender {
    if(self.rightBlock != nil){
        self.rightBlock();
    }
}


@end

//
//  EEPageControlView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EEPageControlView.h"
#import "AgoraRoomManager.h"

@interface EEPageControlView()

@property (strong, nonatomic) IBOutlet UIView *pageControlView;
@property (weak, nonatomic) IBOutlet UILabel *pageCountLabel;
@property (nonatomic, assign) NSInteger sceneIndex;
@property (nonatomic, assign) NSInteger sceneCount;

@end

@implementation EEPageControlView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.pageControlView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.pageControlView.frame = self.bounds;
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
    self.layer.shadowColor = [UIColor colorWithHexString:@"000000"].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.f, 2.f);
    self.layer.shadowOpacity = 2.f;
    self.layer.shadowRadius = 4.f;
    self.layer.borderWidth = 1.f;
    self.layer.cornerRadius = 6.f;
    self.layer.masksToBounds = YES;
}

- (IBAction)buttonClick:(UIButton *)sender {
    if ([sender.restorationIdentifier isEqualToString:@"previousPage"]) {
        [self previousPage];
    } else if ([sender.restorationIdentifier isEqualToString:@"firstPage"]) {
        [self firstPage];
    } else if ([sender.restorationIdentifier isEqualToString:@"nextPage"]) {
        [self nextPage];
    } else if ([sender.restorationIdentifier isEqualToString:@"lastPage"]) {
        [self lastPage];
    }
}

#pragma mark EEPageControlDelegate
- (void)previousPage {
    if (self.sceneIndex > 0) {
        self.sceneIndex--;
        WEAK(self);
        [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
            [weakself.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(weakself.sceneIndex + 1), (long)weakself.sceneCount]];
        }];
    }
}

- (void)nextPage {
    if (self.sceneIndex < self.sceneCount - 1  && self.sceneCount > 0) {
        self.sceneIndex ++;
        
        WEAK(self);
        [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
            [weakself.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(weakself.sceneIndex + 1), (long)weakself.sceneCount]];
        }];
    }
}

- (void)lastPage {
    self.sceneIndex = self.sceneCount - 1;
    
    WEAK(self);
    [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
        [weakself.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(weakself.sceneIndex + 1), (long)weakself.sceneCount]];
    }];
}

- (void)firstPage {
    self.sceneIndex = 0;
    WEAK(self);
    [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
        [weakself.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(weakself.sceneIndex + 1), (long)weakself.sceneCount]];
    }];
}

-(void)setWhiteSceneIndex:(NSInteger)sceneIndex completionSuccessBlock:(void (^ _Nullable)(void ))successBlock {
    
    [AgoraRoomManager.shareManager.whiteManager setWhiteSceneIndex:sceneIndex completionHandler:^(BOOL success, NSError * _Nullable error) {
        if(success) {
            if(successBlock != nil){
                successBlock();
            }
        } else {
            AgoraLog(@"Set scene index err：%@", error);
        }
    }];
}


- (void)setSceneIndex:(NSInteger)sceneIndex sceneCount:(NSInteger)sceneCount {
    self.sceneIndex = sceneIndex;
    self.sceneCount = sceneCount;
    [self.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)(sceneIndex + 1), (long)sceneCount]];
}
@end

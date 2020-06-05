//
//  AllMuteAlertVC.m
//  VideoConference
//
//  Created by SRS on 2020/5/15.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AllMuteAlertVC.h"

@interface AllMuteAlertVC ()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;

@property (assign, nonatomic) BOOL isCheck;

@end

@implementation AllMuteAlertVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bgView.layer.cornerRadius = 4;
    self.bgView.layer.masksToBounds = YES;
    
    self.isCheck = NO;
}

- (IBAction)onCheckBoxClick:(id)sender {
    
    self.isCheck = !self.isCheck;
    //
    NSString *imgName = self.isCheck ? @"checkbox1" : @"checkbox0";
    UIImage *img = [UIImage imageNamed:imgName];
    [self.checkBtn setImage:img forState:UIControlStateNormal];
}

- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)onContinue:(id)sender {
    WEAK(self);
    [self dismissViewControllerAnimated:YES completion:^{
        if(weakself.block != nil){
            weakself.block(weakself.isCheck);
        }
    }];
}

@end

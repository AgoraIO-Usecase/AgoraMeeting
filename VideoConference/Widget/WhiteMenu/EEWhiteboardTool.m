//
//  EEWhiteboardTool.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EEWhiteboardTool.h"

@interface EEWhiteboardTool()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *whiteboardTool;

@property (weak, nonatomic) UIButton *selectButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint4;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint4;

@end

@implementation EEWhiteboardTool

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.whiteboardTool];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.whiteboardTool.frame = self.bounds;

    self.bgView.layer.cornerRadius = 8;
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.borderColor = [UIColor colorWithHexString:@"E9EFF4"].CGColor;
    self.bgView.layer.borderWidth = 1;
}

- (IBAction)clickEvent:(UIButton *)sender {
    if (self.selectButton != nil) {
         [self.selectButton setSelected:NO];
    }
    
    BOOL isSelected = self.selectButton.isSelected;
    self.selectButton = sender;
    [self.selectButton setSelected:!isSelected];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectWhiteTool:)]) {
        [self.delegate selectWhiteTool:sender.tag - 200];
    }
}

- (void)setDirectionPortrait: (BOOL)portrait {
    if(portrait) {
        self.topConstraint1.constant = 46;
        self.topConstraint2.constant = 88;
        self.topConstraint3.constant = 130;
        self.topConstraint4.constant = 172;
        
        self.leftConstraint1.constant = 4;
        self.leftConstraint2.constant = 4;
        self.leftConstraint3.constant = 4;
        self.leftConstraint4.constant = 4;
    } else {
        self.topConstraint1.constant = 4;
        self.topConstraint2.constant = 4;
        self.topConstraint3.constant = 4;
        self.topConstraint4.constant = 4;
        
        self.leftConstraint1.constant = 46;
        self.leftConstraint2.constant = 88;
        self.leftConstraint3.constant = 130;
        self.leftConstraint4.constant = 172;
    }
}

@end

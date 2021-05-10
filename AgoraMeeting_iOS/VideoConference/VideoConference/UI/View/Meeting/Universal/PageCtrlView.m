//
//  SpeakerPageCtrlView.m
//  VideoConference
//
//  Created by ZYP on 2020/12/30.
//  Copyright © 2020 agora. All rights reserved.
//

#import "PageCtrlView.h"
#import "NibInitProtocol.h"

@interface PageCtrlView ()<NibInitProtocol>

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageCtrl;

@end

@implementation PageCtrlView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = true;
    [self setcCurrentPage:0 andNumberOfPage:0];
}

- (void)setcCurrentPage:(NSInteger)currentPage andNumberOfPage:(NSInteger)numberOfPage
{
    if (currentPage == 0 && numberOfPage == 0) {
        [self setHidden:true];
        return;
    }
    
    if (currentPage == 0 && numberOfPage == 1) {
        [self setHidden:true];
        return;
    }
    
    if (numberOfPage <= 4) {//只显示pageCtrl
        [_numberLabel setHidden:true];
        [_pageCtrl setHidden:false];
        _pageCtrl.numberOfPages = numberOfPage;
        _pageCtrl.currentPage = currentPage;
        [self setHidden:false];
    }
    else {//只显示number
        [_numberLabel setHidden:false];
        [_pageCtrl setHidden:true];
        _numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", currentPage+1, numberOfPage];
        [self setHidden:false];
    }
}

- (NSInteger)getCurrentPage {
    return  _pageCtrl.currentPage;
}

+ (instancetype)instanceFromNib {
    NSString *className = NSStringFromClass(PageCtrlView.class);
    return [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil].firstObject;
}

@end

//
//  MessageView.m
//  VideoConference
//
//  Created by ZYP on 2021/1/5.
//  Copyright © 2021 agora. All rights reserved.
//

#import "MeetingMessageView.h"
#import "MeetingMessageCell.h"
#import "MeetingMessageModel.h"
#import "NSString+Size.h"

@interface MeetingMessageView ()<UITableViewDelegate, UITableViewDataSource, MeetingMessageCellDelegate> {
    NSMutableArray *_tempList;
    CGFloat _lastHeight, _lastWidth;
}

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSArray<MeetingMessageModel *> *list;

@end

@implementation MeetingMessageView


- (instancetype)init {
    self = [super init];
    if (self) {
        _tempList = @[].mutableCopy;
        _list = @[];
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self setup];
        [self layout];
    }
    return self;
}

- (void)layout {
    [self addSubview:_tableView];
    _tableView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [_tableView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [_tableView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
    ]];
}

- (void)setup {
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = UIColor.clearColor;
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    _tableView.scrollEnabled = false;
    _tableView.allowsSelection = false;
    _tableView.transform = CGAffineTransformMakeScale(1, -1);
}

#pragma public

- (void)addModel:(MeetingMessageModel *)model {
    if (_list.count >= 100) {
        [_tempList removeAllObjects];
        [_tempList addObjectsFromArray:@[_list[_list.count-1], _list[_list.count-2]]];
        _list = _tempList.copy;
        [_tableView reloadData];
    }
    
    [_tempList insertObject:model atIndex:0];
    self.list = _tempList.copy;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    if (self.list.count > 2) {
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    }
    if (self.list.count > 0) {
        [_tableView selectRowAtIndexPath:indexPath animated:true scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)updateModels:(NSArray<MeetingMessageModel *> *)models {
    CGFloat height = 0.0;
    CGFloat width = 0.0;
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    for (MeetingMessageModel *m in models) {
        CGFloat h = m.showButton ? 44+5 : 24+5;
        height = height + h + 3;
        
        CGSize nameSize = [m.name sizeWithString:m.name Font:[UIFont systemFontOfSize:9] maxSize:CGSizeMake(screenSize.width, 18)];
        CGSize infoSize = [m.info sizeWithString:m.info Font:[UIFont systemFontOfSize:9] maxSize:CGSizeMake(screenSize.width, 18)];
        
        CGFloat w = nameSize.width + infoSize.width + 20 + (m.showButton ? 90 : 10);
        width = MAX(width, w);
        width = MIN(width, screenSize.width);
    }
    if (_lastHeight != height || _lastWidth != width) {
        _lastHeight = height;
        _lastWidth = width;
        if ([self.uiDelegate respondsToSelector:@selector(messageViewShouldUpdateSize:)]) {
            [self.uiDelegate messageViewShouldUpdateSize:CGSizeMake(width, height)];
        }
    }
    self.list = models;
    [self.tableView reloadData];
}

- (void)setHiddenAnimate:(BOOL)hidden {
    if (self.isHidden == hidden) {
        return;
    }
    WEAK(self);
    self.alpha = hidden ? 0 : 1;
    [UIView animateWithDuration:0.25 animations:^{
        [weakself layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakself setHidden:hidden];
    }];
}

#pragma UITableViewDelegate & UITableViewDelegate

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MeetingMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeetingMessageCell"];
    if (cell == nil) {
        cell = [MeetingMessageCell new];
    }
    MeetingMessageModel *model = _list[indexPath.row];
    [cell setModel:model];
    [cell setIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MeetingMessageModel *model = _list[indexPath.row];
    return model.showButton ? 44+5 : 24+5;
}

#pragma MeetingMessageCellDelegate

- (void)meetingMessageCell:(MeetingMessageCell *)cell didTapButton:(MeetingMessageModel *)model {
    if ([_delegate respondsToSelector:@selector(messageViewDidTapButton:)]) {
        [_delegate messageViewDidTapButton:model];
    }
}

@end

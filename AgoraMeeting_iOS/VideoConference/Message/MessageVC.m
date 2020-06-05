//
//  MessageVC.m
//  VideoConference
//
//  Created by SRS on 2020/5/8.
//  Copyright © 2020 agora. All rights reserved.
//

#import "MessageVC.h"
#import "CommonNavigation.h"
#import "MessageCell.h"
#import "MessageSelfCell.h"
#import <IQKeyboardManager/IQKeyboardManager.h>

@interface MessageVC ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CommonNavigation *nav;
@property (weak, nonatomic) IBOutlet UIView *tfView;
@property (weak, nonatomic) IBOutlet UITextField *tf;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tfBottomConstraint;

@property (assign, nonatomic) NSInteger currentTimestamp;

@property (strong, nonatomic) NSMutableArray<MessageInfoModel *> *messageArray;

@end

@implementation MessageVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.nav.title.text = @"聊天";
    
    self.tfView.layer.borderWidth = 1;
    self.tfView.layer.borderColor = [UIColor colorWithHexString:@"CCCCCC"].CGColor;
    self.tfView.layer.cornerRadius = 2;

    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageCell" bundle:nil] forCellReuseIdentifier:@"MessageCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageSelfCell" bundle:nil] forCellReuseIdentifier:@"MessageSelfCell"];
    
    [self updateMessageView];
    [self addNotification];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(updateMessageView) name:NOTICENAME_MESSAGE_CHANGED object:nil];
}

- (void)updateMessageView {
    self.messageArray = AgoraRoomManager.shareManager.messageInfoModels;
    if(self.messageArray.count == 0) {
        self.currentTimestamp = 0;
    } else {
        self.currentTimestamp = self.messageArray.firstObject.timestamp;
        NSInteger index = 0;
        for (MessageInfoModel *model in self.messageArray) {
    
            if(index != 0){
                NSInteger timestamp = [self handelMessageTimestamp:model];
                model.timestamp = timestamp;
            }
            index++;

            NSInteger cellHeight = [self cellHeight:model];
            model.cellHeight = cellHeight;
        }
    }
    
    [self.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollTableViewToBottom];
    });
}

- (void)keyboardDidShow:(NSNotification *)notification {

    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottom = frame.size.height;
    self.tfBottomConstraint.constant = bottom;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollTableViewToBottom];
    });
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    self.tfBottomConstraint.constant = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    IQKeyboardManager.sharedManager.enable = NO;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    IQKeyboardManager.sharedManager.enable = YES;
}

- (IBAction)onClickSend {
    NSString *str = self.tf.text;
    [self sendMsg:str];
    self.tf.text = @"";
}

- (void)sendMsg:(NSString *)msg {
    if(msg.length == 0){
        return;
    }
    
    WEAK(self);
    ConferenceManager *manager = AgoraRoomManager.shareManager.conferenceManager;
    [manager sendMessageWithText:msg successBolck:^{
        
        MessageInfoModel *model = [MessageInfoModel new];
        model.userName = manager.ownModel.userName;
        model.message = msg;
        model.isSelfSend = YES;
        
        NSDate *datenow = [NSDate date];
        model.timestamp = [datenow timeIntervalSince1970] * 1000;
        [weakself addMessageModel:model];
        
    } completeFailBlock:^(NSError * _Nonnull error) {
        [weakself showToast:error.localizedDescription];
    }];
}

- (CGFloat)cellHeight:(MessageInfoModel *)model {

    CGFloat maxWidth = kScreenWidth - 9 - 54 - 24;
    CGFloat msgHeight = [self sizeWithString:model.message Font:[UIFont systemFontOfSize:16] maxSize: CGSizeMake(maxWidth, NSIntegerMax)].height;
    if(model.timestamp == 0){
        msgHeight -= 17;
    }
    
    if(model.isSelfSend) {
        return msgHeight + 60;
    } else {
        return msgHeight + 75;
    }
}

- (NSInteger)handelMessageTimestamp:(MessageInfoModel *)model {
    NSInteger timestamp = 0;
    
    // check
    NSInteger differ = model.timestamp - self.currentTimestamp;
    if(differ / 60 * 0.001 >= 2) {
        self.currentTimestamp = model.timestamp;
        timestamp = model.timestamp;
    } else {
        timestamp = 0;
    }
    
    return timestamp;
}

- (void)addMessageModel:(MessageInfoModel *)model {

    NSInteger timestamp = [self handelMessageTimestamp:model];
    model.timestamp = timestamp;
    
    NSInteger cellHeight = [self cellHeight:model];
    model.cellHeight = cellHeight;
    
    [self.messageArray addObject:model];
    [self.tableView reloadData];
    if (self.messageArray.count > 0) {
        [self.tableView scrollToRowAtIndexPath:
          [NSIndexPath indexPathForRow:[self.messageArray count] - 1 inSection:0] atScrollPosition: UITableViewScrollPositionBottom animated:NO];
    }
}

#pragma mark UITableViewDelegate, UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MessageInfoModel *model = [self.messageArray objectAtIndex:indexPath.row];
    if(!model.isSelfSend){
        MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
        [cell updateWithTime:model.timestamp message:model.message username:model.userName];
        return cell;
    } else {
        MessageSelfCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageSelfCell"];
        [cell updateWithTime:model.timestamp message:model.message];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageInfoModel *model = [self.messageArray objectAtIndex:indexPath.row];
    return model.cellHeight;
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString *content = textField.text;
    [self sendMsg:content];
    textField.text = @"";
    [textField resignFirstResponder];
    return NO;
}

- (void)scrollTableViewToBottom {
    if (self.messageArray.count > 0) {
        
        if (self.messageArray.count > 0) {
            [self.tableView scrollToRowAtIndexPath:
              [NSIndexPath indexPathForRow:[self.messageArray count] - 1 inSection:0] atScrollPosition: UITableViewScrollPositionBottom animated:NO];
        }
    }
}


- (CGSize)sizeWithString:(NSString *)string Font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

- (NSString *)convertTimeSecond:(NSInteger)timeSecond {
    NSString *theLastTime = nil;
    long second = timeSecond;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%02zd", second];
    } else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd", second/60, second%60];
    } else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", second/3600, second%3600/60, second%60];
    }
    return theLastTime;
}

@end

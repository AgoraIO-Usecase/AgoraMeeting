//
//  WhiteManager.m
//  WhiteModule
//
//  Created by SRS on 2020/4/15.
//  Copyright © 2020 agora. All rights reserved.
//

#import "WhiteManager.h"
#import <Whiteboard/Whiteboard.h>

#define WEAK(object) __weak typeof(object) weak##object = object

typedef NSString * WhiteApplianceKey NS_STRING_ENUM;
WhiteApplianceKey const WhiteAppliancePencil = @"pencil";
WhiteApplianceKey const WhiteApplianceSelector = @"selector";
WhiteApplianceKey const WhiteApplianceText = @"text";
WhiteApplianceKey const WhiteApplianceEraser = @"eraser";

@interface WhiteManager()<WhiteCommonCallbackDelegate, WhiteRoomCallbackDelegate>

@property (nonatomic, weak) id<WhiteManagerDelegate> whitePlayerDelegate;

@property (nonatomic, strong) WhiteSDK * _Nullable whiteSDK;
@property (nonatomic, strong) WhiteRoom * _Nullable room;
@property (nonatomic, strong) WhiteMemberState * _Nullable whiteMemberState;

@end

@implementation WhiteManager

+ (UIView *)createWhiteBoardView {
    WhiteBoardView *boardView = [[WhiteBoardView alloc] init];
    return boardView;
}

- (void)initWhiteSDK:(UIView *)boardView dataSourceDelegate:(id<WhiteManagerDelegate> _Nullable)whitePlayerDelegate {

    WhiteBoardView *whiteBoardView = (WhiteBoardView*)boardView;
    if(whiteBoardView){
        self.whiteSDK = [[WhiteSDK alloc] initWithWhiteBoardView: whiteBoardView config:[WhiteSdkConfiguration defaultConfig] commonCallbackDelegate:self];

        self.whitePlayerDelegate = whitePlayerDelegate;
    } else {
        NSAssert(1 == 0, @"boardView must be belong WhiteBoardView");
    }
}

- (void)joinWhiteRoomWithBoardId:(NSString*)boardId boardToken:(NSString*)boardToken whiteWriteModel:(BOOL)isWritable  completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock {

    WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:boardId roomToken:boardToken];
    roomConfig.isWritable = isWritable;

    WEAK(self);
    [self.whiteSDK joinRoomWithConfig:roomConfig callbacks:self completionHandler:^(BOOL success, WhiteRoom * _Nullable room, NSError * _Nullable error) {

        if(success) {
            weakself.room = room;
            weakself.whiteMemberState = [WhiteMemberState new];
            [weakself.room setMemberState:weakself.whiteMemberState];

            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil){
                failBlock(error);
            }
        }
    }];
}

- (void)setWritable:(BOOL)writable completionHandler:(void (^ _Nullable)(BOOL isWritable, NSError * _Nullable error))completionHandler {
    
    BOOL isWritable = [self.room isWritable];
    if(writable == isWritable) {
        if(completionHandler != nil){
            completionHandler(isWritable, nil);
        }
        return;
    }
    
    [self.room setWritable:writable completionHandler:completionHandler];
}

- (void)disableCameraTransform:(BOOL)disableCameraTransform {
    [self.room disableCameraTransform:disableCameraTransform];
}

- (void)disableWhiteDeviceInputs:(BOOL)disable {
    [self.room disableDeviceInputs:disable];
}

- (void)setWhiteStrokeColor:(NSArray<NSNumber *>*)strokeColor {
    self.whiteMemberState.strokeColor = strokeColor;
    [self.room setMemberState: self.whiteMemberState];
}

- (void)setWhiteApplianceName:(NSString *)applianceName {

    NSString *_applianceName = @"";
    if([applianceName isEqualToString:AppliancePencil]) {
        _applianceName = AppliancePencil;

    } else if([applianceName isEqualToString:ApplianceSelector]) {
        _applianceName = ApplianceSelector;

    } else if([applianceName isEqualToString:ApplianceText]) {
        _applianceName = ApplianceText;

    } else if([applianceName isEqualToString:ApplianceEraser]) {
        _applianceName = ApplianceEraser;
    } else {
        NSAssert(1 == 0, @"appliance name not exist");
        return;
    }

    self.whiteMemberState.currentApplianceName = _applianceName;
    [self.room setMemberState: self.whiteMemberState];
}

- (void)setWhiteMemberInput:(nonnull WhiteMemberState *)memberState {
    [self.room setMemberState: memberState];
}
- (void)refreshWhiteViewSize {
    [self.room refreshViewSize];
}
- (void)moveWhiteToContainer:(NSInteger)sceneIndex {
    WhiteSceneState *sceneState = self.room.sceneState;
    NSArray<WhiteScene *> *scenes = sceneState.scenes;
    WhiteScene *scene = scenes[sceneIndex];
    if (scene.ppt) {
        CGSize size = CGSizeMake(scene.ppt.width, scene.ppt.height);

        WhiteRectangleConfig *config = [[WhiteRectangleConfig alloc] initWithInitialPosition:size.width height:size.height];
        [self.room moveCameraToContainer:config];
    }
}

- (void)setWhiteSceneIndex:(NSUInteger)index completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler {
    [self.room setSceneIndex:index completionHandler:completionHandler];
}

- (void)currentWhiteScene:(void (^)(NSInteger sceneCount, NSInteger sceneIndex))completionBlock {

    WhiteSceneState *sceneState = self.room.sceneState;
    NSArray<WhiteScene *> *scenes = sceneState.scenes;
    NSInteger sceneIndex = sceneState.index;
    if(completionBlock != nil){
        completionBlock(scenes.count, sceneIndex);
    }
}

- (void)releaseWhiteResources {
    if(self.room != nil) {
        [self.room disconnect:nil];
    }

    self.room = nil;
    self.whiteSDK = nil;
}

- (void)dealloc {
    [self releaseWhiteResources];
}

#pragma mark WhiteRoomCallbackDelegate
/**
The RoomState property in the room will trigger this callback when it changes.
*/
- (void)fireRoomStateChanged:(WhiteRoomState *_Nullable)modifyState {
    if (modifyState.sceneState) {
        if([self.whitePlayerDelegate respondsToSelector:@selector(whiteRoomStateChanged)]) {
            [self.whitePlayerDelegate whiteRoomStateChanged];
        }
    }
}

#pragma mark WhiteCommonCallbackDelegate
/** 当sdk出现未捕获的全局错误时，会在此处对抛出 NSError 对象 */
- (void)throwError:(NSError *)error {
    if([self.whitePlayerDelegate respondsToSelector:@selector(whiteManagerError:)]) {
        [self.whitePlayerDelegate whiteManagerError: error];
    }
}

@end

//
//  WhiteManager.h
//  WhiteModule
//
//  Created by SRS on 2020/4/15.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WhiteManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface WhiteManager : NSObject

+ (UIView *)createWhiteBoardView;

- (void)initWhiteSDK:(UIView *)boardView dataSourceDelegate:(id<WhiteManagerDelegate> _Nullable)whitePlayerDelegate;
- (void)joinWhiteRoomWithBoardId:(NSString*)boardId boardToken:(NSString*)boardToken whiteWriteModel:(BOOL)isWritable  completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;

- (void)disableCameraTransform:(BOOL)disableCameraTransform;
- (void)disableWhiteDeviceInputs:(BOOL)disable;

- (void)setWritable:(BOOL)writable completionHandler:(void (^ _Nullable)(BOOL isWritable, NSError * _Nullable error))completionHandler;

- (void)setWhiteStrokeColor:(NSArray<NSNumber *>*)strokeColor;
- (void)setWhiteApplianceName:(NSString *)applianceName;

- (void)refreshWhiteViewSize;
- (void)moveWhiteToContainer:(NSInteger)sceneIndex;

- (void)setWhiteSceneIndex:(NSUInteger)index completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler;
- (void)currentWhiteScene:(void (^)(NSInteger sceneCount, NSInteger sceneIndex))completionBlock;

- (void)releaseWhiteResources;

@end

NS_ASSUME_NONNULL_END

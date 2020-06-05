//
//  WhiteManagerDelegate.h
//  WhiteModule
//
//  Created by SRS on 2020/4/15.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WhiteManagerDelegate <NSObject>

@optional

/**
 When an uncaught global error occurs in the SDK, an NSError object will be thrown here
 */
- (void)whiteManagerError:(NSError * _Nullable)error;

/**
The RoomState property in the room will trigger this callback when it changes.
*/
- (void)whiteRoomStateChanged;

@end

NS_ASSUME_NONNULL_END

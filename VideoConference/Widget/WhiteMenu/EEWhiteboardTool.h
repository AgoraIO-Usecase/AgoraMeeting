//
//  EEWhiteboardTool.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ToolType) {
    ToolTypeSelect          = 0,
    ToolTypePan,
    ToolTypeText,
    ToolTypeEraser,
    ToolTypeColor,
    ToolTypeAdd,
};

@protocol WhiteToolDelegate <NSObject>
- (void)selectWhiteTool:(ToolType)index;
@end
NS_ASSUME_NONNULL_BEGIN

@interface EEWhiteboardTool : UIView

@property (nonatomic, weak) id <WhiteToolDelegate> delegate;
- (void)setDirectionPortrait: (BOOL)portrait;

@end

NS_ASSUME_NONNULL_END

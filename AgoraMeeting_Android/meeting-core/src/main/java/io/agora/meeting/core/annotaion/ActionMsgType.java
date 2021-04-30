package io.agora.meeting.core.annotaion;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Description:
 *
 *
 * @since 2/18/21
 */
@IntDef({ActionMsgType.SCREEN_CHANGE,
        ActionMsgType.USER_APPROVE,
        ActionMsgType.ADMIN_MUTE_ALL,
        ActionMsgType.ACCESS_CHANGE,
        ActionMsgType.ADMIN_MUTE,
        ActionMsgType.ADMIN_CHANGE,
        ActionMsgType.USER_CHANGE,
        ActionMsgType.BOARD_CHANGE,
        ActionMsgType.BOARD_INTERACT,
        ActionMsgType.RECORD_CHANGE,
        ActionMsgType.ADMIN_KICK_OUT,
})
@Retention(RetentionPolicy.SOURCE)
public @interface ActionMsgType {
    // 房间内设备打开权限改变
    int ACCESS_CHANGE   = 1;

    // 屏幕共享状态改变
    int SCREEN_CHANGE   = 3;
    // 白板共享状态改变
    int BOARD_CHANGE    = 4;
    // 白板可交互成员改变
    int BOARD_INTERACT  = 5;
    // 录制状态变化
    int RECORD_CHANGE   = 6;

    // 用户打开设备申请
    int USER_APPROVE    = 7;
    // 用户状态改变--进房/退房
    int USER_CHANGE     = 8;

    // 主持人关闭所有人设备
    int ADMIN_MUTE_ALL  = 9;
    // 主持人关闭某人设备
    int ADMIN_MUTE      = 10;
    // 主持人角色成员改变
    int ADMIN_CHANGE    = 11;
    // 主持人踢掉了某人
    int ADMIN_KICK_OUT  = 12;

}

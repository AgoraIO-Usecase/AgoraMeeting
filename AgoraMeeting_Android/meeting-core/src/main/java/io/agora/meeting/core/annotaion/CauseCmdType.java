package io.agora.meeting.core.annotaion;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Description:
 *
 *
 * @since 3/25/21
 */
@IntDef({
        CauseCmdType.NONE,
        CauseCmdType.ALL_CAMERA_CLOSE,
        CauseCmdType.ALL_MIC_CLOSE,
        CauseCmdType.SINGLE_CAMERA_CLOSE,
        CauseCmdType.SINGLE_MIC_CLOSE,
        CauseCmdType.USER_PERMISSION_CHANGE,
        CauseCmdType.BOARD_START,
        CauseCmdType.BOARD_CLOSE,
        CauseCmdType.SCREEN_SHARE_START,
        CauseCmdType.SCREEN_SHARE_CLOSE,
        CauseCmdType.BOARD_UPDATE,
})
@Retention(RetentionPolicy.SOURCE)
public @interface CauseCmdType {
    // nothing change
    int NONE                                = -1;

    // cause in onStreamInfoUpdate
    int SCOPE_STREAM                        = 300;
    int ALL_CAMERA_CLOSE                    = SCOPE_STREAM;
    int ALL_MIC_CLOSE                       = SCOPE_STREAM + 1;
    int SINGLE_CAMERA_CLOSE                 = SCOPE_STREAM + 2;
    int SINGLE_MIC_CLOSE                    = SCOPE_STREAM + 3;

    // cause in onScenePropertiesChange userPermission
    int SCOPE_ROOM_PROPERTIES_PERMISSION    = 310;
    int USER_PERMISSION_CHANGE              = SCOPE_ROOM_PROPERTIES_PERMISSION;

    // cause in onScenePropertiesChange share
    int SCOPE_ROOM_PROPERTIES_SHARE         = 320;
    int BOARD_START                         = SCOPE_ROOM_PROPERTIES_SHARE;
    int BOARD_CLOSE                         = SCOPE_ROOM_PROPERTIES_SHARE + 1;
    int SCREEN_SHARE_START                  = SCOPE_ROOM_PROPERTIES_SHARE + 2;
    int SCREEN_SHARE_CLOSE                  = SCOPE_ROOM_PROPERTIES_SHARE + 3;

    // cause in onScenePropertiesChange board
    int SCOPE_ROOM_PROPERTIES_BOARD         = 2;
    int BOARD_UPDATE                        = SCOPE_ROOM_PROPERTIES_BOARD;
}

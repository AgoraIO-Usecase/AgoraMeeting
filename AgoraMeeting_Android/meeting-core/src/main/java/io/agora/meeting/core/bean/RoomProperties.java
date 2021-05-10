package io.agora.meeting.core.bean;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;

import java.util.List;
import java.util.Map;

import io.agora.meeting.core.annotaion.AccessType;
import io.agora.meeting.core.annotaion.Keep;
import io.agora.meeting.core.annotaion.ModuleState;
import io.agora.meeting.core.annotaion.ScheduleState;
import io.agora.meeting.core.annotaion.ShareType;
import io.agora.rte.AgoraRteStreamInfo;
import io.agora.rte.AgoraRteUserInfo;

/**
 * Description:
 *
 *
 * @since 2/14/21
 */
@Keep
public final class RoomProperties {
    public UserPermission userPermission;
    public RoomInfo roomInfo;
    public Share share;
    public Record record;
    public WhiteBoard board;
    public Processes processes;

    @SerializedName("schedule.state")
    @ScheduleState
    public int scheduleState;

    public boolean isMeetingEnded(){
        return scheduleState == ScheduleState.ENDED;
    }

    public boolean isScreenSharing(){
        return share != null && share.type == ShareType.SCREEN;
    }

    public boolean isBoardSharing(){
        return share != null && share.type == ShareType.BOARD
                && board != null && board.ownerInfo != null && board.info != null;
    }

    public String getBoardOwnerId(){
        if (board != null
                && board.ownerInfo != null) {
            return board.ownerInfo.getUserId();
        }
        return "";
    }

    public boolean canBoardInteract(@NonNull String userId){
        if(userId.equals(getBoardOwnerId())){
            return true;
        }
        if (board != null
                && board.state != null
                && board.state.grantUsers != null) {
            for (String uid : board.state.grantUsers) {
                if(userId.equals(uid)){
                    return true;
                }
            }
        }
        return false;
    }

    public String getScreenOwnerId(){
        if (share != null
                && share.screen != null
                && share.screen.ownerInfo != null) {
            return share.screen.ownerInfo.getUserId();
        }
        return "";
    }

    @Keep
    public static final class UserPermission{
        public boolean micAccess;
        public boolean cameraAccess;
    }

    @Keep
    public static final class RoomInfo{
        public String roomPassword;
        public String roomName;
        public String roomId;
    }

    @Keep
    public static final class Share {
        @ShareType
        public int type;

        public Screen screen;

    }

    @Keep
    public static final class Screen {
        public AgoraRteUserInfo ownerInfo;
        public AgoraRteStreamInfo streamInfo;
    }

    @Keep
    public static final class WhiteBoard{
        public WhiteBoardInfo info;
        public AgoraRteUserInfo ownerInfo; // 白板发起者
        public WhiteBoardState state;
    }

    @Keep
    public static final class WhiteBoardInfo{
        public String boardId;
        public String boardToken;
    }

    @Keep
    public static final class WhiteBoardState{
        public int follow;
        public List<String> grantUsers; // 拥有互动权限的人员列表
    }

    @Keep
    public static final class Record {
        @ModuleState
        public int state;

        public String recordId;
        public long recordingTime;
    }

    @Keep
    public static final class Processes{
        public Access micAccess;
        public Access cameraAccess;
    }

    @Keep
    public static final class Access{
        @AccessType
        public int type;
        public int maxWait;
        public int timeout;
    }

    public static RoomProperties parse(Map<String, Object> properties){
        Gson gson = new Gson();
        String json = gson.toJson(properties);
        return gson.fromJson(json, RoomProperties.class);
    }
}

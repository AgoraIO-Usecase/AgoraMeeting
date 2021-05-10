package io.agora.meeting.core.bean;

import java.util.Objects;

import io.agora.meeting.core.annotaion.ActionMsgType;
import io.agora.meeting.core.annotaion.ApproveAction;
import io.agora.meeting.core.annotaion.ApproveRequest;
import io.agora.meeting.core.annotaion.Device;
import io.agora.meeting.core.annotaion.Keep;
import io.agora.meeting.core.annotaion.ModuleState;
import io.agora.meeting.core.utils.TimeSyncUtil;

/**
 * Description:
 *
 *
 * @since 2/17/21
 */
@Keep
public abstract class ActionMessage {
    public final long timestamp;

    public String userId;
    public String userName;

    @ActionMsgType
    public final int type;

    public ActionMessage(int type){
        this.type = type;
        this.timestamp = TimeSyncUtil.getSyncCurrentTimeMillis();
    }

    @Keep
    public static final class Approve extends ActionMessage{
        @ApproveAction
        public int action;
        @ApproveRequest
        public String requestId;

        public int duration; // 申请有效时长，单位s

        public Approve(String userId, String userName, @ApproveAction int action,@ApproveRequest String requestId, int duration) {
            super(ActionMsgType.USER_APPROVE);
            this.userId = userId;
            this.userName = userName;
            this.action = action;
            this.requestId = requestId;
            this.duration = duration;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            if (!super.equals(o)) return false;

            Approve approve = (Approve) o;

            if (action != approve.action) return false;
            if (duration != approve.duration) return false;
            return Objects.equals(requestId, approve.requestId);
        }

        @Override
        public int hashCode() {
            int result = super.hashCode();
            result = 31 * result + action;
            result = 31 * result + (requestId != null ? requestId.hashCode() : 0);
            result = 31 * result + duration;
            return result;
        }
    }

    @Keep
    public static final class ScreenChange extends ActionMessage{
        @ModuleState
        public int state;

        public ScreenChange(String userId, String userName, @ModuleState int state) {
            super(ActionMsgType.SCREEN_CHANGE);
            this.userId = userId;
            this.userName = userName;
            this.state = state;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            if (!super.equals(o)) return false;

            ScreenChange that = (ScreenChange) o;

            return state == that.state;
        }

        @Override
        public int hashCode() {
            int result = super.hashCode();
            result = 31 * result + state;
            return result;
        }
    }

    @Keep
    public static final class AdminMuteAll extends ActionMessage{
        @Device
        public int device;

        public AdminMuteAll(String userId, String userName, @Device int device) {
            super(ActionMsgType.ADMIN_MUTE_ALL);
            this.userId = userId;
            this.userName = userName;
            this.device = device;
        }
    }

    @Keep
    public static final class Access extends ActionMessage {
        @Device
        public int device;
        @ModuleState
        public int state;

        public Access(@Device int device, @ModuleState int state){
            super(ActionMsgType.ACCESS_CHANGE);
            this.device = device;
            this.state = state;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            if (!super.equals(o)) return false;

            Access access = (Access) o;

            if (device != access.device) return false;
            return state == access.state;
        }

        @Override
        public int hashCode() {
            int result = super.hashCode();
            result = 31 * result + device;
            result = 31 * result + state;
            return result;
        }
    }

    @Keep
    public static final class AdminMute extends ActionMessage{
        public boolean isLocal;
        @Device
        public int device;

        public AdminMute(boolean isLocal,@Device int device){
            super(ActionMsgType.ADMIN_MUTE);
            this.isLocal = isLocal;
            this.device = device;
        }
    }

    @Keep
    public static final class AdminChange extends ActionMessage{

        public boolean isAbandon;

        public AdminChange(String userId, String userName){
            super(ActionMsgType.ADMIN_CHANGE);
            this.userId = userId;
            this.userName = userName;
        }
    }

    @Keep
    public static final class AdminKickOut extends ActionMessage{

        public AdminKickOut(String userId, String userName){
            super(ActionMsgType.ADMIN_KICK_OUT);
            this.userId = userId;
            this.userName = userName;
        }
    }

    @Keep
    public static final class RecordChange extends ActionMessage{
        @ModuleState
        public int state;

        public String url;

        public RecordChange() {
            super(ActionMsgType.RECORD_CHANGE);
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            if (!super.equals(o)) return false;

            RecordChange that = (RecordChange) o;

            if (state != that.state) return false;
            return Objects.equals(url, that.url);
        }

        @Override
        public int hashCode() {
            int result = super.hashCode();
            result = 31 * result + state;
            result = 31 * result + (url != null ? url.hashCode() : 0);
            return result;
        }
    }

    @Keep
    public static final class UserChange extends ActionMessage{
        @ModuleState
        public int state;

        public UserChange(String userId, String userName,@ModuleState int state){
            super(ActionMsgType.USER_CHANGE);
            this.userId = userId;
            this.userName = userName;
            this.state = state;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            if (!super.equals(o)) return false;

            UserChange that = (UserChange) o;

            return state == that.state;
        }

        @Override
        public int hashCode() {
            int result = super.hashCode();
            result = 31 * result + state;
            return result;
        }
    }

    @Keep
    public static final class BoardChange extends ActionMessage{
        @ModuleState
        public int state;

        public BoardChange(String userId, String userName, @ModuleState int state){
            super(ActionMsgType.BOARD_CHANGE);
            this.userId = userId;
            this.userName = userName;
            this.state = state;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            if (!super.equals(o)) return false;

            BoardChange that = (BoardChange) o;

            return state == that.state;
        }

        @Override
        public int hashCode() {
            int result = super.hashCode();
            result = 31 * result + state;
            return result;
        }
    }

    @Keep
    public static final class BoardInteract extends ActionMessage{
        @ModuleState
        public int state;

        public BoardInteract(String userId, String userName, @ModuleState int state){
            super(ActionMsgType.BOARD_INTERACT);
            this.userId = userId;
            this.userName = userName;
            this.state = state;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            if (!super.equals(o)) return false;

            BoardInteract that = (BoardInteract) o;

            return state == that.state;
        }

        @Override
        public int hashCode() {
            int result = super.hashCode();
            result = 31 * result + state;
            return result;
        }
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        ActionMessage that = (ActionMessage) o;

        if (timestamp != that.timestamp) return false;
        if (type != that.type) return false;
        if (!Objects.equals(userId, that.userId)) return false;
        return Objects.equals(userName, that.userName);
    }

    @Override
    public int hashCode() {
        int result = (int) (timestamp ^ (timestamp >>> 32));
        result = 31 * result + (userId != null ? userId.hashCode() : 0);
        result = 31 * result + (userName != null ? userName.hashCode() : 0);
        result = 31 * result + type;
        return result;
    }
}

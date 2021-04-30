package io.agora.meeting.core.bean;

import com.google.gson.JsonObject;

import io.agora.meeting.core.annotaion.ApproveAction;
import io.agora.meeting.core.annotaion.CmdType;
import io.agora.meeting.core.annotaion.Device;
import io.agora.meeting.core.annotaion.Keep;
import io.agora.rte.AgoraRteChatFromUser;

/**
 * Description:
 *
 *
 * @since 3/2/21
 */
@Keep
public class PeerMessage<T> {
    @CmdType
    public int cmd;

    public T data;

    public static final class Type extends PeerMessage<JsonObject> {}

    @Keep
    public static final class Approve extends PeerMessage<Approve.Data> {

        @Keep
        public static class Data{
            @ApproveAction
            public int action;

            public AgoraRteChatFromUser fromUser;
            public String processUuid;
        }
    }

    @Keep
    public static final class MuteAll extends PeerMessage<MuteAll.Data> {

        @Keep
        public static final class Data{
            @Device
            public int device;
        }

    }
}
